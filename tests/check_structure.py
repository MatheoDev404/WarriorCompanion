from pathlib import Path

root=Path(__file__).resolve().parents[1]/"Addon"/"WarriorCompanionBuild"
assert root.is_dir(), "Le dossier du nouvel addon est absent"
toc=(root/"WarriorCompanionBuild.toc").read_text(encoding="utf-8")
lines=[line.strip() for line in toc.splitlines() if line.strip()]
modules=[line for line in lines if not line.startswith("#")]
assert modules==["Data.lua","TalentTrees.lua","Spellbook.lua","Planner.lua","CombatData.lua","UI.lua","Rotation.lua","Session.lua","CompactDashboard.lua","MinimapButton.lua","Core.lua"], modules
assert "## Interface: 16001" in toc
assert "## SavedVariables: WCBuildDB" in toc
assert "## Version: 0.3.7-test" in toc
assert set(modules)=={p.name for p in root.glob("*.lua")}
assert not list(root.glob("*.ttf")), "La police systeme WoW suffit, ne pas distribuer de police"
ui=(root/"UI.lua").read_text(encoding="utf-8")
assert "ARIALN.TTF" in ui, "Police sans serif WoW introuvable dans l'interface"
assert '"rotation","Rotation"' in ui
assert "GetItemIconByID" in ui
assert "TalentPointAt" in ui
core=(root/"Core.lua").read_text(encoding="utf-8")
assert 'LEARNED_SPELL_IN_TAB' not in core, "Evenement inconnu du client Forever"
assert "PLAYER_XP_UPDATE" in core and "PLAYER_MONEY" in core
assert "autostart on" in core and "minimap on" in core
compact=(root/"CompactDashboard.lua").read_text(encoding="utf-8")
assert 'f:SetSize(304,88)' in compact
assert 'compactPoint' in compact and 'compactMoneyParts' in compact
minimap=(root/"MinimapButton.lua").read_text(encoding="utf-8")
assert 'RightButton' in minimap and 'LeftButton' in minimap
assert 'B:ShowCompact()' in minimap and 'B:OpenFullDashboard()' in minimap
assert 'ToggleCompact()' not in minimap and 'ToggleDashboard()' not in minimap
assert 'MiniMap-TrackingBorder' in minimap
assert 'GetWidth' in minimap and 'GetHeight' in minimap
assert 'BattleShout' in minimap
assert 'OnSizeChanged' in minimap
assert 'GetRadius' not in minimap
session=(root/"Session.lua").read_text(encoding="utf-8")
assert 'issecretvalue' in session and 'function B:SafeNumber' in session
print("OK: Build Planner 0.3.7-test, manifest 11 modules, events valides et interface")
