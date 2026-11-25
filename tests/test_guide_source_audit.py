"""Audit figé des 302 étapes importées : syntaxe, coordonnées et IDs.

Les 108 identifiants distincts ont été recoupés le 25-11-2026 avec
prezus/ForeverGuide/Data/VanillaQuestIDs.lua (export Forever).
Ce contrôle ne garantit PAS leurs conditions de quête, PNJ, faction ou
position réelle dans le client : les captures de jeu restent nécessaires.
"""
from pathlib import Path
import re

source = (Path(__file__).resolve().parents[1] /
          "Addon/WarriorCompanionBuild/DetailedData30_40.lua").read_text(encoding="utf-8")
verified_ids = {186,187,188,189,191,192,194,195,196,213,533,544,552,553,556,557,568,569,570,571,572,577,581,582,584,585,587,595,596,599,600,605,606,607,629,638,642,651,655,662,663,664,665,669,671,672,675,676,677,678,698,701,703,705,709,710,711,847,1104,1105,1175,1176,1177,1201,1202,1206,1218,1238,1239,1240,1251,1261,1268,1269,1270,1273,1321,1322,1361,1365,1366,1389,1393,1419,1420,1842,1844,2258,2843,4767,5381,5386,5501,5561,5581,5741,5762,5763,5821,5943,6027,6132,6134,6142,6143,6161,93225,98070}
quest_ids = [int(v) for v in re.findall(r"questID=(\d+)", source)]
assert len(quest_ids) == 217, "Une action de quête source a changé"
assert set(quest_ids) == verified_ids, "Nouvel ID ou ID source supprimé : revérifier"
assert source.count("{text=") == 302
assert source.count("B:RegisterGuidePack") == 14

waypoints = re.findall(r'zone="([^"]+)",x=([0-9.]+),y=([0-9.]+)', source)
assert len(waypoints) == 285, "Les coordonnées du guide source ont changé"
zones = {
    "Thousand Needles", "Hillsbrad Foothills", "Alterac Mountains",
    "Arathi Highlands", "Dustwallow Marsh", "Desolace",
    "Stranglethorn Vale", "Stonetalon Mountains", "Ashenvale",
    "Durotar", "The Barrens", "Thunder Bluff", "Badlands",
    "Swamp of Sorrows",
}
for zone, x, y in waypoints:
    assert zone in zones, "Zone sans mapID audité : " + zone
    assert 0 <= float(x) <= 100 and 0 <= float(y) <= 100, (zone, x, y)

print(f"OK: 302 étapes, 14 sections, {len(waypoints)} points dans 14 zones, "
      f"{len(quest_ids)} actions et {len(verified_ids)} IDs recoupés.")
