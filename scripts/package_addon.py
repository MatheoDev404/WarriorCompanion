#!/usr/bin/env python3
"""Construire un ZIP installable de l'addon, sans tests ni documents du dépôt.

Usage:
    python3 scripts/package_addon.py --check
    python3 scripts/package_addon.py --output dist/WarriorCompanionBuild.zip
"""
from __future__ import annotations

import argparse
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "Addon" / "WarriorCompanionBuild"
NAME = "WarriorCompanionBuild"
TOC = ADDON / f"{NAME}.toc"
REQUIRED = {"LICENSE-GUIDE.txt", "README.md"}


def inputs() -> list[Path]:
    if not TOC.is_file():
        raise ValueError(f"Fichier d'entrée introuvable : {TOC}")
    modules = []
    for line in TOC.read_text(encoding="utf-8").splitlines():
        filename = line.strip()
        if not filename or filename.startswith("#"):
            continue
        path = Path(filename)
        if path.is_absolute() or len(path.parts) != 1 or path.suffix != ".lua":
            raise ValueError(f"Chemin de module non autorisé dans le TOC : {filename}")
        if filename in modules:
            raise ValueError(f"Module en double dans le TOC : {filename}")
        modules.append(filename)

    discovered = {p.name for p in ADDON.glob("*.lua")}
    if not modules or discovered != set(modules):
        missing = sorted(set(modules) - discovered)
        orphan = sorted(discovered - set(modules))
        raise ValueError(f"Dépendances Lua incorrectes : absentes={missing}, orphelines={orphan}")
    missing_docs = [name for name in REQUIRED if not (ADDON / name).is_file()]
    if missing_docs:
        raise ValueError(f"Licence ou instructions manquantes : {missing_docs}")
    names = [f"{NAME}.toc", *modules, *sorted(REQUIRED)]
    return [ADDON / filename for filename in names]


def build(output: Path, sources: list[Path]) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(output, "w", compression=ZIP_DEFLATED, compresslevel=9) as archive:
        for path in sources:
            # Horodatage fixe pour produire exactement la même archive
            # à contenu égal (utile pour les tests et les vérifications).
            entry = ZipInfo(f"{NAME}/{path.name}", date_time=(2020, 1, 1, 0, 0, 0))
            entry.compress_type = ZIP_DEFLATED
            entry.external_attr = 0o644 << 16
            archive.writestr(entry, path.read_bytes(), compress_type=ZIP_DEFLATED, compresslevel=9)
    with ZipFile(output) as archive:
        names = archive.namelist()
        if len(names) != len(sources) or len(names) != len(set(names)):
            raise ValueError("Le ZIP contient des fichiers manquants ou en double.")
        if f"{NAME}/{NAME}.toc" not in names:
            raise ValueError("Le ZIP ne contient pas le .toc à la racine de l'addon.")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Valider sans créer de ZIP")
    parser.add_argument("--output", type=Path, help="Chemin du ZIP installable")
    args = parser.parse_args()
    sources = inputs()
    raw = sum(path.stat().st_size for path in sources)
    print(f"Addon validé : {len(sources)} fichiers, {raw} octets non compressés.")
    if args.check:
        return
    if not args.output:
        parser.error("--output requis pour créer l'archive (ou utiliser --check)")
    build(args.output, sources)
    print(f"Archive prête : {args.output} ({args.output.stat().st_size} octets).")


if __name__ == "__main__":
    main()
