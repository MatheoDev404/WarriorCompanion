from pathlib import Path
import re

root = Path(__file__).resolve().parents[1] / "Addon" / "WarriorCompanion"
toc = (root / "WarriorCompanion.toc").read_text(encoding="utf-8").splitlines()
lines = [line.strip() for line in toc if line.strip()]
files = [line for line in lines if not line.startswith("#")]
assert files and files[0] == "Core.lua", "Core.lua doit initialiser l'addon"
assert len(files) == len(set(files)), "Entrée TOC en double"
sources = {path.relative_to(root).as_posix() for path in root.rglob("*.lua")}
assert set(files) == sources, f"Différence entre TOC et sources : {sources ^ set(files)}"
assert "## Interface: 16001" in lines, "Interface Forever attendue"
assert "## SavedVariables: WC_DB" in lines, "Options non persistées"

core = (root / "Core.lua").read_text(encoding="utf-8")
version = re.search(r'^WC\.version = "([^"]+)"$', core, re.MULTILINE)
assert version and f"## Version: {version[1]}" in lines, "Versions TOC et /wc status différentes"
print(f"OK: manifeste, version et {len(files)} modules Lua")
