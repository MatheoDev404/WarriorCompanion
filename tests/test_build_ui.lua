-- Simulations de la nouvelle interface WoW (sans client graphique).
local function frame()
  local f={shown=true,handlers={}}
  function f:SetPoint(...) self.point={...} end
  function f:SetSize(w,h) self.width=w self.height=h end
  function f:SetScale(v) self.scale=v end
  function f:SetFrameStrata(v) self.strata=v end
  function f:SetMovable(v) end
  function f:EnableMouse(v) end
  function f:RegisterForDrag(v) end
  function f:SetClampedToScreen(v) end
  function f:StartMoving() end
  function f:StopMovingOrSizing() end
  function f:GetPoint() return "CENTER",UIParent,"CENTER",0,0 end
  function f:SetScript(k,fn) self.handlers[k]=fn end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:CreateTexture()
    local t={}
    function t:SetTexture(v) self.texture=v end
    function t:SetPoint(...) self.point={...} end
    function t:SetSize(w,h) self.width=w self.height=h end
    function t:SetVertexColor(...) self.color={...} end
    return t
  end
  function f:CreateFontString()
    local t={}
    function t:SetPoint(...) end
    function t:SetSize(w,h) end
    function t:SetJustifyH() end
    function t:SetJustifyV() end
    function t:SetText(v) self.text=v end
    function t:SetTextColor(...) self.color={...} end
    return t
  end
  return f
end
UIParent=frame()
function CreateFrame() return frame() end
function UnitLevel() return 34 end
local lastTooltipSpell
GameTooltip={
  SetOwner=function() end,
  SetSpellByID=function(_,id) lastTooltipSpell=id end,
  AddLine=function()end, Show=function()end, Hide=function()end,
}
local B={}
assert(loadfile("Addon/WarriorCompanionBuild/Data.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/Planner.lua"))("WarriorCompanionBuild",B)
assert(loadfile("Addon/WarriorCompanionBuild/UI.lua"))("WarriorCompanionBuild",B)
B:InitState()
assert(B:ValidateContent())
B:CreateUI()
assert(B.frame.width==760 and B.frame.scale==0.82)
assert(B.page=="talents" and B.pages.talents:IsShown())
assert(B.pages.talents.nodes["Bloodthirst"])
B.pages.talents.nodes["Bloodthirst"].handlers.OnEnter()
assert(lastTooltipSpell==23881,"tooltip de talent depuis le spellID")
B.pages.talents.nodes["Cruelty"].handlers.OnClick()
assert(B.selectedTalent=="Cruelty")
B:ShowPage("equipement")
assert(B.pages.equipement:IsShown() and not B.pages.talents:IsShown())
B.pages.equipement.items[6802].handlers.OnClick()
assert(B.selectedItem==6802)
B.pages.equipement.goto.handlers.OnClick()
assert(B.page=="parcours" and B.pages.parcours:IsShown())
assert(B:OrderedRoute()[B.routeIndex].step.id=="quest-scarlet")
assert(B.pages.parcours.zone.text:find("Monastere",1,true))
B:ShowPage("talents")
assert(B.pages.talents.nextLabel.text:find("Rafale",1,true))
B:SetPreview(60)
B:Refresh()
assert(B.pages.talents.nextLabel.text:find("termine",1,true))
B:ChangeScale(-0.08)
assert(B.frame.scale==0.74)
B:ReturnToReal()
B:Refresh()
assert(B.levelText.text:find("34",1,true))
print("OK: 3 tabs, spell tooltip, gear-to-route jump, level preview and compact scale")
