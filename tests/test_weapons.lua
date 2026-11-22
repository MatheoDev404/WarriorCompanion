-- Surveilance armes guerrier Furie : pas de faux conseil sans type fiable.
local level, main, off = 33, 1234, nil
local mainLoc, offLoc="INVTYPE_WEAPON",nil
local secret=987654
function issecretvalue(v) return v==secret end
function UnitClass() return "Guerrier","WARRIOR" end
function UnitLevel() return level end
function GetInventoryItemID(unit, slot)
  assert(unit=="player")
  if slot==16 then return main elseif slot==17 then return off end
end
C_Item={
  GetItemInfoInstant=function(id)
    if id==main then return id,"Arme","Epee",mainLoc end
    if id==off then return id,"Arme","Epee",offLoc end
  end
}
local messages={}
local WC={metrics={deaths=0,xpGained=20},alerts={},inCombat=false,
  health={percent=90},combat={completed=0,average=nil},spellbook={learned={}}}
function WC:IsReadableNumber(v) return type(v)=="number" and v~=secret end
function WC:Trace() end
function WC:Print(s) messages[#messages+1]=s end
function WC:Now() return 100 end
function WC:GetCombatSummary() return self.combat end
function WC:Profile() return {showAlerts=true} end
assert(loadfile("Addon/WarriorCompanion/Weapons.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/FuryAdvisor.lua"))("WarriorCompanion",WC)
assert(loadfile("Addon/WarriorCompanion/Advisor.lua"))("WarriorCompanion",WC)
WC:InitWeaponObserver()
assert(WC.weapons.available and WC.weapons.main==main and WC.weapons.off==nil)
WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="fury-offhand-empty")
assert(WC.alerts[1].priority=="info" and WC.alerts[1].message:find("Si tu as appris",1,true))
WC:NotifyImportant()
assert(#messages==0,"no unsolicited chat")
WC:ShowWeaponStatus()
assert(messages[#messages]:find("DPS",1,true))

off=7777;offLoc="INVTYPE_WEAPONOFFHAND"
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==0,"dual weapons present")
offLoc="INVTYPE_SHIELD"
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==1 and WC.alerts[1].id=="fury-offhand-not-weapon")
offLoc="INVTYPE_HOLDABLE"
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==1,"offhand nonweapon")
mainLoc="INVTYPE_2HWEAPON"; off=nil
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==0,"two-handed weapon must not suggest offhand")
mainLoc="INVTYPE_WEAPON"; level=19
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==0,"below dual wield level")
level=33
mainLoc=nil
WC:ReadWeapons(); WC:UpdateAdvice()
assert(#WC.alerts==0,"missing item type must not trigger advice")
mainLoc="INVTYPE_WEAPON";main=secret
WC:ReadWeapons(); WC:UpdateAdvice()
assert(not WC.weapons.available and #WC.alerts==0,"protected item ID")
main=1234
C_Item=nil
WC:ReadWeapons(); WC:UpdateAdvice()
assert(WC.weapons.available and WC.weapons.mainType==nil and #WC.alerts==0)
GetInventoryItemID=function() error("API fail") end
WC:ReadWeapons(); WC:UpdateAdvice()
assert(not WC.weapons.available and #WC.alerts==0)
WC:ShowWeaponStatus()
assert(messages[#messages]:find("indisponibles",1,true))
GetInventoryItemID=nil
WC:ReadWeapons(); WC:UpdateAdvice()
assert(not WC.weapons.available and #WC.alerts==0)
print("OK: arme 1 main/2 mains, bouclier, niveau, secrets, API absentes, pas de faux DPS")
