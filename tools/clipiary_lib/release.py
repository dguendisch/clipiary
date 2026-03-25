from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path

from .appcast import generate_appcast
from .build import build_app
from .cask import generate_cask
from .changelog import extract_version_notes
from .common import Runner, ToolError, dist_dir, remove_path, resolve_path, write_json, write_text
from .env import get_env


DRY_RUN_SHA256 = "0" * 64
DRY_RUN_ED_SIGNATURE = "DRY_RUN_SIGNATURE"


@dataclass
class ReleaseMetadata:
    version: str
    app_bundle: Path
    archive_path: Path
    sha256: str
    sha256_path: Path
    cask_path: Path
    release_notes_path: Path
    release_repo: str
    cask_token: str
    appcast_path: Path | None


def archive_name(env: dict[str, str], version: str) -> str:
    app_name = get_env(env, "CLIPIARY_APP_NAME", "Clipiary")
    return env.get("CLIPIARY_ARCHIVE_NAME", f"{app_name}-{version}.zip")


def zip_app(source_bundle: Path, output_path: Path, runner: Runner) -> None:
    runner.run(
        [
            "ditto",
            "-c",
            "-k",
            "--keepParent",
            "--sequesterRsrc",
            str(source_bundle),
            str(output_path),
        ]
    )


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_release(
    root: Path,
    env: dict[str, str],
    runner: Runner,
    *,
    version: str,
    metadata_out: Path | None = None,
) -> ReleaseMetadata:
    app_name = get_env(env, "CLIPIARY_APP_NAME", "Clipiary")
    release_repo = get_env(env, "CLIPIARY_RELEASE_REPO", "liamhess/clipiary")
    cask_token = get_env(env, "CLIPIARY_CASK_TOKEN", "clipiary")
    signing_identity = env.get("CLIPIARY_CODESIGN_IDENTITY", "")
    notary_apple_id = env.get("CLIPIARY_NOTARY_APPLE_ID", "")
    notary_team_id = env.get("CLIPIARY_NOTARY_TEAM_ID", "")
    notary_password = env.get("CLIPIARY_NOTARY_PASSWORD", "")
    output_dir = dist_dir(root)
    archive_path = output_dir / archive_name(env, version)
    notary_archive_path = output_dir / f"{app_name}-{version}-notarization.zip"
    release_notes_path = output_dir / f"{app_name}-{version}.release-notes.txt"
    sha256_path = output_dir / f"{app_name}-{version}.sha256"
    cask_path = resolve_path(root, env.get("CLIPIARY_CASK_OUTPUT_PATH")) or (output_dir / f"{cask_token}.rb")

    for path in (archive_path, notary_archive_path, release_notes_path, sha256_path, cask_path):
        remove_path(path, dry_run=runner.dry_run)

    build_env = env.copy()
    build_env["CLIPIARY_VERSION"] = version
    if signing_identity and not build_env.get("CLIPIARY_CODESIGN_FLAGS"):
        build_env["CLIPIARY_CODESIGN_FLAGS"] = "--timestamp --options runtime"

    build_result = build_app(
        root,
        build_env,
        runner,
        configuration="release",
        version_override=version,
    )

    if (
        signing_identity
        and notary_apple_id
        and notary_team_id
        and notary_password
    ):
        zip_app(build_result.app_bundle, notary_archive_path, runner)
        runner.run(
            [
                "xcrun",
                "notarytool",
                "submit",
                str(notary_archive_path),
                "--apple-id",
                notary_apple_id,
                "--team-id",
                notary_team_id,
                "--password",
                notary_password,
                "--wait",
            ]
        )
        runner.run(["xcrun", "stapler", "staple", str(build_result.app_bundle)])
        remove_path(notary_archive_path, dry_run=runner.dry_run)

    zip_app(build_result.app_bundle, archive_path, runner)
    sha256 = DRY_RUN_SHA256 if runner.dry_run else sha256_file(archive_path)
    write_text(sha256_path, sha256 + "\n", dry_run=runner.dry_run)
    generate_cask(env, version, sha256, cask_path, dry_run=runner.dry_run)

    release_notes = extract_version_notes(root, version)
    write_text(release_notes_path, release_notes, dry_run=runner.dry_run)

    appcast_path = _generate_sparkle_appcast(
        root=root,
        env=env,
        runner=runner,
        version=version,
        archive_path=archive_path,
        release_notes=release_notes,
        release_repo=release_repo,
        app_name=app_name,
        output_dir=output_dir,
    )

    metadata = ReleaseMetadata(
        version=version,
        app_bundle=build_result.app_bundle,
        archive_path=archive_path,
        sha256=sha256,
        sha256_path=sha256_path,
        cask_path=cask_path,
        release_notes_path=release_notes_path,
        release_repo=release_repo,
        cask_token=cask_token,
        appcast_path=appcast_path,
    )
    if metadata_out is not None:
        write_json(metadata_out, metadata, dry_run=runner.dry_run)
    return metadata


def _find_sign_update_tool(root: Path) -> Path | None:
    """Locate Sparkle's sign_update tool from SPM artifacts."""
    candidate = root / ".build" / "artifacts" / "sparkle" / "Sparkle" / "bin" / "sign_update"
    if candidate.exists():
        return candidate
    return None


def _generate_sparkle_appcast(
    *,
    root: Path,
    env: dict[str, str],
    runner: Runner,
    version: str,
    archive_path: Path,
    release_notes: str,
    release_repo: str,
    app_name: str,
    output_dir: Path,
) -> Path | None:
    """Sign the archive with Sparkle EdDSA and generate an appcast.xml."""
    sparkle_private_key = env.get("SPARKLE_PRIVATE_KEY", "")
    if not sparkle_private_key:
        print("SPARKLE_PRIVATE_KEY not set, skipping appcast generation")
        return None

    sign_tool = _find_sign_update_tool(root)
    if sign_tool is None:
        print("warning: sign_update tool not found, skipping appcast generation")
        return None

    if runner.dry_run:
        ed_signature = DRY_RUN_ED_SIGNATURE
        file_length = 0
    else:
        import subprocess as _sp

        result = _sp.run(
            [str(sign_tool), str(archive_path), "--ed-key-file", "-"],
            input=sparkle_private_key,
            capture_output=True,
            text=True,
            check=True,
        )
        print(f"{sign_tool} -> {result.stdout.strip()}")
        # sign_update outputs: sparkle:edSignature="..." length="..."
        parts = {}
        for part in result.stdout.strip().split():
            if "=" in part:
                key, _, value = part.partition("=")
                parts[key] = value.strip('"')
        ed_signature = parts.get("sparkle:edSignature", "")
        file_length = int(parts.get("length", archive_path.stat().st_size))

    archive_filename = archive_path.name
    download_url = f"https://github.com/{release_repo}/releases/download/v{version}/{archive_filename}"

    appcast_path = output_dir / "appcast.xml"
    generate_appcast(
        version=version,
        download_url=download_url,
        release_notes=release_notes,
        ed_signature=ed_signature,
        file_length=file_length,
        output_path=appcast_path,
        dry_run=runner.dry_run,
    )
    return appcast_path


def require_version(value: str | None) -> str:
    if not value:
        raise ToolError("A version is required")
    return value
