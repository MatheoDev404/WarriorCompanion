#!/usr/bin/env python3
"""Régression : le ZIP d'installation est minimal, complet et reproductible."""
from pathlib import Path
from subprocess import check_call
from tempfile import TemporaryDirectory
from zipfile import ZipFile
import hashlib
import sys

repo = Path(__file__).resolve().parents[1]
toc = (repo / "Addon/WarriorCompanionBuild/WarriorCompanionBuild.toc")
modules = [
    line.strip() for line in toc.read_text(encoding="utf-8").splitlines()
    if line.strip() and not line.startswith("#")
]
expected = {
    "WarriorCompanionBuild/" + filename
    for filename in ["WarriorCompanionBuild.toc", *modules,
                     "README.md", "LICENSE-GUIDE.txt"]
}
with TemporaryDirectory() as temp:
    a = Path(temp) / "first.zip"
    b = Path(temp) / "second.zip"
    for archive in (a, b):
        check_call([sys.executable, str(repo / "scripts/package_addon.py"),
                    "--output", str(archive)], cwd=repo)
    assert a.read_bytes() == b.read_bytes(), "Le ZIP doit etre deterministe"
    assert len(a.read_bytes()) < 200_000, "Le paquet ne doit pas grossir anormalement"
    with ZipFile(a) as archive:
        names = archive.namelist()
        assert set(names) == expected, "Fichier inutile ou manquant dans le ZIP"
        assert len(names) == len(expected), "Archive avec fichiers doubles"
        assert all(name.startswith("WarriorCompanionBuild/") for name in names)
        assert not any(name.startswith(("tests/", "docs/", "scripts/")) for name in names)
        for name in names:
            assert archive.read(name), f"Fichier vide: {name}"
        license_text = archive.read("WarriorCompanionBuild/LICENSE-GUIDE.txt")
        assert b"Creative Commons" in license_text, "Licence source absente"
        data = archive.read("WarriorCompanionBuild/DetailedData30_40.lua")
        assert data.count(b"{text=") == 302, "302 etapes historiques incompletes"
    print(f"OK: ZIP installable, {len(expected)} fichiers, "
          f"{a.stat().st_size} octets, SHA256 {hashlib.sha256(a.read_bytes()).hexdigest()[:12]}")
