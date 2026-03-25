from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from xml.etree.ElementTree import Element, SubElement, tostring

from .common import write_text

SPARKLE_NS = "http://www.andymatuschak.org/xml-namespaces/sparkle"


def generate_appcast_entry(
    *,
    version: str,
    download_url: str,
    release_notes: str,
    ed_signature: str,
    file_length: int,
) -> Element:
    item = Element("item")
    SubElement(item, "title").text = f"Version {version}"
    SubElement(item, f"{{{SPARKLE_NS}}}version").text = version
    SubElement(item, f"{{{SPARKLE_NS}}}shortVersionString").text = version
    SubElement(item, "description").text = release_notes
    SubElement(item, "pubDate").text = datetime.now(timezone.utc).strftime(
        "%a, %d %b %Y %H:%M:%S %z"
    )
    enclosure = SubElement(item, "enclosure")
    enclosure.set("url", download_url)
    enclosure.set(f"{{{SPARKLE_NS}}}edSignature", ed_signature)
    enclosure.set("length", str(file_length))
    enclosure.set("type", "application/octet-stream")
    return item


def generate_appcast(
    *,
    version: str,
    download_url: str,
    release_notes: str,
    ed_signature: str,
    file_length: int,
    output_path: Path,
    dry_run: bool,
) -> None:
    rss = Element("rss")
    rss.set("version", "2.0")
    rss.set("xmlns:sparkle", SPARKLE_NS)
    channel = SubElement(rss, "channel")
    SubElement(channel, "title").text = "Clipiary"

    item = generate_appcast_entry(
        version=version,
        download_url=download_url,
        release_notes=release_notes,
        ed_signature=ed_signature,
        file_length=file_length,
    )
    channel.append(item)

    xml_bytes = tostring(rss, encoding="unicode", xml_declaration=False)
    content = f'<?xml version="1.0" encoding="utf-8"?>\n{xml_bytes}\n'
    write_text(output_path, content, dry_run=dry_run)
