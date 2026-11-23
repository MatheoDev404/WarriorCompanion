from pathlib import Path

root=Path(__file__).resolve().parents[1]/"Addon"/"WarriorCompanionBuild"
assert root.is_dir(), "Le dossier du nouvel addon est absent"
toc=(root/"WarriorCompanionBuild.toc").read_text(encoding="utf-8")
lines=[line.strip() for line in toc.splitlines() if line.strip()]
modules=[line for line in lines if not line.startswith("#")]
assert modules==["Data.lua","TalentTrees.lua","Spellbook.lua","Planner.lua","CombatData.lua","UI.lua","Rotation.lua","Core.lua"], modules
assert "## Interface: 16001" in toc
assert "## SavedVariables: WCBuildDB" in toc
assert "## Version: 0.3.0-test" in toc
assert set(modules)=={p.name for p in root.glob("*.lua")}
assert not list(root.glob("*.ttf")), "La police systeme WoW suffit, ne pas distribuer de police"
ui=(root/"UI.lua").read_text(encoding="utf-8")
assert "ARIALN.TTF" in ui, "Police sans serif WoW introuvable dans l'interface"
assert '"rotation","Rotation"' in ui
assert "GetItemIconByID" in ui
assert "TalentPointAt" in ui
print("OK: nouvel addon autonome 0.2.0-test, 4 modules UI/logique, police WoW et contenu du manifest")
