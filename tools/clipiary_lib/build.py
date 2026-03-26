from __future__ import annotations

import plistlib
import shlex
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from .common import Runner, ToolError, base_env, dist_dir, ensure_dir
from .env import get_env


@dataclass
class BuildResult:
    app_bundle: Path
    executable_path: Path
    configuration: str
    version: str
    signing_identity: str


def resolve_default_version(root: Path, runner: Runner) -> str:
    try:
        latest_tag = runner.read(["git", "-C", str(root), "describe", "--tags", "--abbrev=0"])
    except ToolError:
        return "0.0.0"
    if latest_tag.startswith("v"):
        return latest_tag[1:]
    if latest_tag:
        return latest_tag
    return "0.0.0"


def swift_build_env(root: Path, env: dict[str, str]) -> dict[str, str]:
    return base_env(
        {
            **env,
            "HOME": str(root / ".tmp-home"),
            "SWIFTPM_MODULECACHE_OVERRIDE": str(root / ".build/module-cache"),
            "CLANG_MODULE_CACHE_PATH": str(root / ".build/clang-module-cache"),
        }
    )


def build_app(
    root: Path,
    env: dict[str, str],
    runner: Runner,
    *,
    configuration: str,
    version_override: str | None = None,
) -> BuildResult:
    app_name = get_env(env, "CLIPIARY_APP_NAME", "Clipiary")
    bundle_id = get_env(env, "CLIPIARY_BUNDLE_ID", "dev.liamhess.clipiary")
    version = version_override or env.get("CLIPIARY_VERSION") or resolve_default_version(root, runner)
    signing_identity = env.get("CLIPIARY_CODESIGN_IDENTITY", "")
    codesign_flags = shlex.split(env.get("CLIPIARY_CODESIGN_FLAGS", ""))
    app_bundle = dist_dir(root) / f"{app_name}.app"
    contents_dir = app_bundle / "Contents"
    macos_dir = contents_dir / "MacOS"
    resources_dir = contents_dir / "Resources"
    icon_source = root / "Resources" / "AppIcon.icns"

    ensure_dir(root / ".tmp-home", dry_run=runner.dry_run)
    ensure_dir(root / ".build/module-cache", dry_run=runner.dry_run)
    ensure_dir(root / ".build/clang-module-cache", dry_run=runner.dry_run)
    ensure_dir(macos_dir, dry_run=runner.dry_run)
    ensure_dir(resources_dir, dry_run=runner.dry_run)

    swift_env = swift_build_env(root, env)
    runner.run(["/usr/bin/swift", "build", "--configuration", configuration], cwd=root, env=swift_env)
    bin_dir = runner.read(
        ["/usr/bin/swift", "build", "--configuration", configuration, "--show-bin-path"],
        cwd=root,
        env=swift_env,
    )
    executable_path = Path(bin_dir) / app_name
    if not runner.dry_run and not executable_path.exists():
        raise ToolError(f"Built executable not found at {executable_path}")

    bundle_executable = macos_dir / app_name
    print(f"copy {executable_path} -> {bundle_executable}")
    if not runner.dry_run:
        if bundle_executable.exists():
            bundle_executable.unlink()
        shutil.copy2(executable_path, bundle_executable)
        bundle_executable.chmod(0o755)

    # Add rpath so the executable can find frameworks in Contents/Frameworks/
    runner.run([
        "install_name_tool", "-add_rpath", "@executable_path/../Frameworks", str(bundle_executable)
    ])

    info_plist = {
        "CFBundleDevelopmentRegion": "en",
        "CFBundleDisplayName": app_name,
        "CFBundleExecutable": app_name,
        "CFBundleIdentifier": bundle_id,
        "CFBundleInfoDictionaryVersion": "6.0",
        "CFBundleName": app_name,
        "CFBundlePackageType": "APPL",
        "CFBundleShortVersionString": version,
        "CFBundleVersion": version,
        "LSMinimumSystemVersion": "14.0",
        "LSUIElement": True,
        "NSPrincipalClass": "NSApplication",
    }
    if icon_source.exists():
        info_plist["CFBundleIconFile"] = "AppIcon"

    sparkle_feed_url = env.get("CLIPIARY_APPCAST_URL", "")
    sparkle_public_key = env.get("CLIPIARY_SPARKLE_PUBLIC_KEY", "")
    if sparkle_feed_url:
        info_plist["SUFeedURL"] = sparkle_feed_url
    if sparkle_public_key:
        info_plist["SUPublicEDKey"] = sparkle_public_key

    info_plist_path = contents_dir / "Info.plist"
    print(f"write {info_plist_path}")
    if not runner.dry_run:
        with info_plist_path.open("wb") as handle:
            plistlib.dump(info_plist, handle, sort_keys=False)

    if icon_source.exists():
        target_icon = resources_dir / "AppIcon.icns"
        print(f"copy {icon_source} -> {target_icon}")
        if not runner.dry_run:
            shutil.copy2(icon_source, target_icon)

    _embed_sparkle_framework(root, contents_dir, configuration, swift_env, runner)

    sign_identity = signing_identity or "-"
    _codesign_bundle(app_bundle, sign_identity, codesign_flags, runner)

    return BuildResult(
        app_bundle=app_bundle,
        executable_path=bundle_executable,
        configuration=configuration,
        version=version,
        signing_identity=signing_identity or "-",
    )


def _find_sparkle_framework(root: Path, configuration: str, swift_env: dict[str, str]) -> Path | None:
    """Locate Sparkle.framework from SPM artifacts."""
    # Check the build products directory (placed there by SPM during linking)
    try:
        bin_dir = subprocess.check_output(
            ["/usr/bin/swift", "build", "--configuration", configuration, "--show-bin-path"],
            cwd=root,
            env=swift_env,
            text=True,
        ).strip()
        build_fw = Path(bin_dir) / "Sparkle.framework"
        if build_fw.exists():
            return build_fw
    except subprocess.CalledProcessError:
        pass
    # Fallback: xcframework extracted by SPM
    xcfw = root / ".build" / "artifacts" / "sparkle" / "Sparkle" / "Sparkle.xcframework" / "macos-arm64_x86_64" / "Sparkle.framework"
    if xcfw.exists():
        return xcfw
    return None


def _embed_sparkle_framework(
    root: Path,
    contents_dir: Path,
    configuration: str,
    swift_env: dict[str, str],
    runner: Runner,
) -> None:
    """Copy Sparkle.framework into Contents/Frameworks/, preserving symlinks."""
    fw_source = _find_sparkle_framework(root, configuration, swift_env)
    if fw_source is None:
        print("warning: Sparkle.framework not found in build artifacts, skipping embed")
        return

    frameworks_dir = contents_dir / "Frameworks"
    ensure_dir(frameworks_dir, dry_run=runner.dry_run)
    target_fw = frameworks_dir / "Sparkle.framework"
    print(f"copy {fw_source} -> {target_fw}")
    if not runner.dry_run:
        if target_fw.exists():
            shutil.rmtree(target_fw)
        # Use shutil.copytree with symlinks=True to preserve framework symlinks
        shutil.copytree(fw_source, target_fw, symlinks=True)


def _codesign_bundle(
    app_bundle: Path,
    identity: str,
    flags: list[str],
    runner: Runner,
) -> None:
    """Sign embedded frameworks individually, then sign the app bundle."""
    frameworks_dir = app_bundle / "Contents" / "Frameworks"
    if frameworks_dir.is_dir():
        for fw in sorted(frameworks_dir.iterdir()):
            if fw.suffix == ".framework" or fw.suffix == ".dylib":
                runner.run(["codesign", "--force", "--sign", identity, *flags, str(fw)])
    runner.run(["codesign", "--force", "--sign", identity, *flags, str(app_bundle)])
