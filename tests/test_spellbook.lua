-- Observateur du grimoire, compatible Lua 5.1/5.4.
local time, token = 100, "WARRIOR"
local printed={}
local spells={"Charge","Coup heroique"}
local ranks={"Rang 1","Rang 1"}
local invalid = false
Enum={SpellBookSpellBank={Player=0}}
function UnitClass() return "Guerrier", token end
function issecretvalue(value) return value == 987654 end
C_SpellBook={
  GetNumSpellBookSkillLines=function() return 1 end,
  GetSpellBookSkillLineInfo=function(i)
    if invalid then return {itemIndexOffset=0,numSpellBookItems=999999} end
    return {itemIndexOffset=0,numSpellBookItems=#spells}
  end,
  GetSpellBookItemName=function(slot,bank)
    assert(bank==0)
    return spells[slot],ranks[slot]
  end,
}
local WC={metrics={deaths=0,xpGained=1},inCombat=false,
  health={percent=100},combat={completed=0,average=nil},alerts={}}
function WC:Now() return time end
function WC:Trace() end
function WC:Print(s) printed[#printed+1]=s end
function WC:IsReadableNumber(x) return type(x)=="number" and x~=987654 end
function WC:GetCombatSummary() return self.combat end
function WC:Profile() return {showAlerts=true} end
assert(loadfile("Addon/WarriorCompanion/Spellbook.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/FuryAdvisor.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/Advisor.lua"))("WarriorCompanion",WC)
WC:InitSpellbookObserver()
assert(WC.spellbook.known and #WC.spellbook.learned==0,"initialisation non consideree comme acquisition")
WC:UpdateAdvice()
assert(#WC.alerts==0)
spells[3]="Cri de guerre";ranks[3]="Rang 1"
WC:ObserveSpellbook()
assert(#WC.spellbook.learned==1)
WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="fury-new-spell")
assert(WC.alerts[1].priority=="info")
assert(WC.alerts[1].message:find("Cri de guerre",1,true))
WC:NotifyImportant()
assert(#printed==0,"pas d'alerte chat")
WC:ObserveSpellbook()
assert(#WC.spellbook.learned==1,"doublon ignore")
time=time+601
WC:UpdateAdvice()
assert(#WC.alerts==0,"alerte expiree")
spells[4]="Charge";ranks[4]="Rang 2"
WC:ObserveSpellbook()
assert(#WC.spellbook.learned==2)
assert(WC.spellbook.learned[2].name=="Charge (Rang 2)")
token="MAGE"
WC:UpdateAdvice()
assert(#WC.alerts==0,"classe differente")
token="WARRIOR"
invalid=true
assert(WC:ObserveSpellbook()==false)
assert(WC.spellbook.known==nil and #WC.spellbook.learned==0,"pas de baseline tronquee")
invalid=false
WC:ObserveSpellbook()
assert(#WC.spellbook.learned==0,"retour API = baseline")
C_SpellBook.GetSpellBookItemName=function() return 987654 end
assert(WC:ObserveSpellbook()==false,"valeur protegee")
C_SpellBook=nil
WC:ObserveSpellbook()
WC:ShowSpellbookStatus()
assert(printed[#printed]:find("indisponible",1,true))
Enum=nil
WC:InitSpellbookObserver()
assert(WC.spellbook.known==nil)
print("OK: C_SpellBook, rangs, apprentissages, absence doublons, seuil, API et secrets")
