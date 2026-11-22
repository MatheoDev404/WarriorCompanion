#!/usr/bin/env python3
"""Contrôles structurels sans dépendance externe. Ne remplace pas les tests Lua."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "Addon" / "WarriorCompanion"
toc = (ADDON / "WarriorCompanion.toc").read_text(encoding="utf-8")
entries = [line.strip() for line in toc.splitlines()
           if line.strip() and not line.strip().startswith("#")]
assert entries, "Aucun fichier dans le TOC"
assert len(entries) == len(set(entries)), "Fichier charge deux fois"
for name in entries:
    assert not name.startswith(("/", "\\")) and ".." not in name
    assert (ADDON / name).is_file(), f"Manquant dans le TOC: {name}"

core = (ADDON / "Core.lua").read_text(encoding="utf-8")
observer = (ADDON / "Observer.lua").read_text(encoding="utf-8")
advisor = (ADDON / "Advisor.lua").read_text(encoding="utf-8")
diagnostics = (ADDON / "Diagnostics.lua").read_text(encoding="utf-8")
dashboard = (ADDON / "Dashboard.lua").read_text(encoding="utf-8")
assert "WC:InitObserver()" in core
assert "WC:CreateDashboard()" in core
assert "function WC:XPPerHour()" in observer
assert "elapsed < 60" in observer
assert "self.inCombat" in advisor and "cooldownSeconds" in advisor
assert "not self:Profile().debug" in diagnostics
assert "maxEntries = 80" in diagnostics
assert '"/wc"' in core
assert "function WC:ToggleDashboard()" in dashboard
print("OK: structure TOC, modules et garde-fous de base")
