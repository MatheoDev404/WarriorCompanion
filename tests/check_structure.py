from pathlib import Path

root=Path(__file__).resolve().parents[1]/"Addon"/"WarriorCompanionBuild"
assert root.is_dir(), "Le dossier du nouvel addon est absent"
toc=(root/"WarriorCompanionBuild.toc").read_text(encoding="utf-8")
lines=[line.strip() for line in toc.splitlines() if line.strip()]
modules=[line for line in lines if not line.startswith("#")]
assert modules==["Data.lua","ProfessionData.lua","TalentTrees.lua","Spellbook.lua","Planner.lua","ProfessionRuntime.lua","ProfessionPlanner.lua","DetailedGuide.lua","DetailedData30_40.lua","AdaptiveRoute.lua","Compass.lua","CombatData.lua","UI.lua","ProfessionUI.lua","Rotation.lua","Session.lua","CompactDashboard.lua","MinimapButton.lua","Core.lua"], modules
assert "## Interface: 16001" in toc
assert "## SavedVariables: WCBuildDB" in toc
assert "## Version: 0.6.0-test" in toc
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
guide=(root/"DetailedData30_40.lua").read_text(encoding="utf-8")
assert guide.count("B:RegisterGuidePack")>=14
assert guide.count("{text=")==302, "Guide source 30-40 incomplet"
assert (root/"LICENSE-GUIDE.txt").exists(), "Licence du guide source manquante"
engine=(root/"DetailedGuide.lua").read_text(encoding="utf-8")
assert "function B:DetailedEntries" in engine
assert "function B:GuideSuggestedStep" in engine
adaptive=(root/"AdaptiveRoute.lua").read_text(encoding="utf-8")
assert "function B:AdaptiveSuggestedStep" in adaptive
assert "function B:AdaptiveEntries" in adaptive
assert "function B:AdaptiveSetMode" in adaptive
assert "function B:AdaptiveResume" in adaptive
data=(root/"ProfessionData.lua").read_text(encoding="utf-8")
assert "B.professionGuides" in data and "B.miningBands" in data
assert "B.smithingBands" in data and "B.smelting" in data
runtime=(root/"ProfessionRuntime.lua").read_text(encoding="utf-8")
assert "GetProfessionInfo" in runtime and "C_TradeSkillUI" in runtime
assert "ReadProfessionBank" in runtime and "ReadProfessionRecipes" in runtime
planner=(root/"ProfessionPlanner.lua").read_text(encoding="utf-8")
assert "ProfessionSupplyPlan" in planner
assert "ProfessionComboEntries" in planner
profui=(root/"ProfessionUI.lua").read_text(encoding="utf-8")
assert "page.guideSelector" in profui and "page.guideMenu" in profui
compass=(root/"Compass.lua").read_text(encoding="utf-8")
assert "GetWorldPosFromMapPos" in compass
assert "GetPlayerFacing" in compass
assert "issecretvalue" in compass
assert 'arrow:SetSize(68,68)' in compass, "Fleche principale 68 px"
assert 'f:EnableMouse(false)' in compass, "Clics transmis hors poignee"
assert 'f.dragHandle=drag' in compass, "HUD deplacable"
assert 'rect(f,' not in compass, "Le HUD ne doit pas avoir de fond opaque"
session=(root/"Session.lua").read_text(encoding="utf-8")
assert 'issecretvalue' in session and 'function B:SafeNumber' in session
print("OK: Build Planner 0.4.1-test, manifest 19 modules, events valides et interface")
