local _,B=...
-- Sources detectees sur Forever (C_TradeSkillUI et C_Container), avec
-- repli manuel si le client ne fournit pas une valeur lisible.
local floor,min,max=math.floor,math.min,math.max
local function plain(v)
 if type(issecretvalue)=="function" then
  local ok,secret=pcall(issecretvalue,v)
  if not ok or secret then return nil end
 end
 return v
end
local function number(v)
 v=plain(v)
 if type(v)~="number" then return nil end
 local ok,valid=pcall(function()
  return v==v and v>=0 and v<100000000 and v==floor(v)
 end)
 return ok and valid and v or nil
end
local function attempt(fn,...)
 if type(fn)~="function" then return nil end
 local ok,a,b,c,d,e,f,g,h=pcall(fn,...)
 if not ok then return nil end
 return a,b,c,d,e,f,g,h
end
local function stamp()
 local t=number(attempt(GetServerTime)) or number(attempt(time))
 return t
end
local function matchSkill(name,id)
 if id==186 then return "mining" end
 if id==164 then return "smithing" end
 if type(name)~="string" then return nil end
 name=name:lower()
 if name:find("minage",1,true) or name:find("mining",1,true) then
  return "mining"
 end
 if name:find("forge",1,true) or name:find("blacksmith",1,true) then
  return "smithing"
 end
 return nil
end
function B:ProfessionsInit()
 if not self.db then return end
 if not self:GuideDefinition(self.db.activeGuide) then
  self.db.activeGuide="leveling"
 end
 if type(self.db.professionProgress)~="table" then
  self.db.professionProgress={}
 end
 if type(self.db.professionSkills)~="table" then
  self.db.professionSkills={}
 end
 if type(self.db.professionManual)~="table" then
  self.db.professionManual={}
 end
 if type(self.db.professionBank)~="table" then
  self.db.professionBank={items={},stale=true}
 end
 if type(self.db.professionRecipes)~="table" then
  self.db.professionRecipes={}
 end
end
function B:ActiveGuide()
 self:ProfessionsInit()
 return self.db and self.db.activeGuide or "leveling"
end
function B:SetActiveGuide(id)
 if not self:GuideDefinition(id) then return false end
 self:ProfessionsInit()
 if not self.db then return false end
 if self.db.activeGuide==id then return true end
 local old=self.db.activeGuide
 local progress=self.db.professionProgress
 if old then
  progress[old]=progress[old] or {}
  progress[old].scroll=self.routeScroll or 0
  progress[old].selected=self.routeSelectedId
 end
 self.db.activeGuide=id
 self.routeSelectedId=progress[id] and progress[id].selected or nil
 self.routeScroll=progress[id] and progress[id].scroll or 0
 self.routeForced=true
 return true
end
function B:SaveGuideSelection()
 if not self.db then return end
 local id=self:ActiveGuide()
 self.db.professionProgress[id]=self.db.professionProgress[id] or {}
 self.db.professionProgress[id].selected=self.routeSelectedId
 self.db.professionProgress[id].scroll=self.routeScroll or 0
end
function B:ProfessionSkill(key)
 self:ProfessionsInit()
 local stored=self.db and self.db.professionSkills[key]
 if type(stored)~="table" then return nil,nil,"indisponible" end
 local skill,limit=number(stored.value),number(stored.cap)
 return skill,limit,stored.source or "inconnu"
end
function B:SetProfessionManualSkill(key,value,cap)
 if not self.professionNames[key] then return false end
 value,cap=number(value),number(cap)
 if not value or not cap or cap<value or cap>300 then return false end
 self:ProfessionsInit()
 local current=self.db.professionSkills[key]
 if current and current.source=="jeu" then
  return false -- une valeur verifiee dans le client prime
 end
 self.db.professionSkills[key]={value=value,cap=cap,source="manuel"}
 return true
end
function B:ReadProfessionSkills()
 if type(GetProfessions)~="function" or
     type(GetProfessionInfo)~="function" or not self.db then
  return false
 end
 self:ProfessionsInit()
 local a,b,c,d,e,f=attempt(GetProfessions)
 local changed=false
 for _,index in pairs({a,b,c,d,e,f}) do
  index=number(index)
  if index then
   local name,_,rank,cap,_,_,line=attempt(GetProfessionInfo,index)
   local key=matchSkill(plain(name),number(line))
   rank,cap=number(rank),number(cap)
   if key and rank and cap and cap>=rank and cap<=300 then
    local old=self.db.professionSkills[key]
    if not old or old.value~=rank or old.cap~=cap or
        old.source~="jeu" then changed=true end
    self.db.professionSkills[key]={value=rank,cap=cap,
      source="jeu",when=stamp()}
   end
  end
 end
 return changed
end
local function slots(bag)
 local api=C_Container
 local n=api and attempt(api.GetContainerNumSlots,bag)
 if n==nil then n=attempt(GetContainerNumSlots,bag) end
 n=number(n)
 if not n or n>100 then return nil end
 return n
end
local function itemInSlot(bag,slot)
 local api=C_Container
 local info=api and attempt(api.GetContainerItemInfo,bag,slot)
 if type(info)=="table" then
  local id=number(info.itemID)
  local count=number(info.stackCount or info.quantity or info.count)
  if id and count then return id,count end
 end
 local id=api and number(attempt(api.GetContainerItemID,bag,slot))
 if not id then id=number(attempt(GetContainerItemID,bag,slot)) end
 if not id then return nil end
 local _,count=attempt(GetContainerItemInfo,bag,slot)
 count=number(count)
 return count and id or nil,count
end
local function scanContainers(ids)
 local items,known={},false
 for _,bag in ipairs(ids) do
  local n=slots(bag)
  if n and n>0 then
   known=true
   for slot=1,n do
    local id,count=itemInSlot(bag,slot)
    if id then items[id]=(items[id] or 0)+count end
   end
  end
 end
 return known and items or nil
end
function B:ReadProfessionBags()
 if not self.db then return false end
 self:ProfessionsInit()
 local data=scanContainers({0,1,2,3,4})
 if not data then
  self.professionBags=nil
  return false
 end
 self.professionBags=data
 return true
end
function B:ReadProfessionBank()
 if not self.db then return false end
 self:ProfessionsInit()
 if not self.professionBankOpen then return false end
 local data=scanContainers({-1,5,6,7,8,9,10,11})
 if not data then return false end
 self.db.professionBank={items=data,when=stamp(),stale=false}
 return true
end
function B:ProfessionStock(itemID,includeBank)
 local bags=self.professionBags
 local bagCount=bags and (bags[itemID] or 0) or nil
 local bank=self.db and self.db.professionBank
 local bankCount=nil
 if includeBank and bank and bank.stale==false and
     type(bank.items)=="table" then
  bankCount=number(bank.items[itemID]) or 0
 end
 -- Si les sacs sont illisibles, ne pas annoncer un manque certain.
 local total=bagCount and (bagCount+(bankCount or 0)) or nil
 return total,bagCount,bankCount,bank and bank.when
end
function B:ReadProfessionRecipes()
 if not self.db or type(C_TradeSkillUI)~="table" then return false end
 self:ProfessionsInit()
 local api=C_TradeSkillUI
 local base=attempt(api.GetBaseProfessionInfo)
 if type(base)~="table" then return false end
 local key=matchSkill(plain(base.professionName or base.name),
   number(base.professionID or base.skillLineID))
 if not key then return false end
 -- Une liste filtrée n'est PAS une preuve d'absence de recette.
 local ids=attempt(api.GetAllRecipeIDs)
 if type(ids)~="table" then
  ids=attempt(api.GetFilteredRecipeIDs)
 end
 if type(ids)~="table" then return false end
 local cache=self.db.professionRecipes[key] or {}
 local learned={}
 for _,id in ipairs(ids) do
  id=number(id)
  if id then
   local info=attempt(api.GetRecipeInfo,id)
   if type(info)=="table" and plain(info.learned)==true then
    local schematic=attempt(api.GetRecipeSchematic,id,false)
    local output=type(schematic)=="table" and
      number(schematic.outputItemID or
        (type(schematic.outputItemIDs)=="table" and
          schematic.outputItemIDs[1])) or nil
    local mats,complete={},true
    if type(schematic)=="table" and
       type(schematic.reagentSlotSchematics)=="table" then
     for _,slot in ipairs(schematic.reagentSlotSchematics) do
      local choices=type(slot)=="table" and slot.reagents
      if type(choices)~="table" or #choices~=1 then
       complete=false break
      end
      local id2=number(choices[1].itemID)
      local qty=number(slot.quantityRequired or
        choices[1].quantityRequired or choices[1].quantity)
      if not id2 or not qty or qty<1 then
       complete=false break
      end
      mats[#mats+1]={id2,qty}
     end
    else complete=false end
    learned[id]={id=id,name=plain(info.name),
      difficulty=number(info.relativeDifficulty),
      item=output,mats=complete and mats or nil}
   end
  end
 end
 cache.learned=learned
 cache.when=stamp()
 cache.source="jeu"
 self.db.professionRecipes[key]=cache
 return true
end
function B:ProfessionRecipeByItem(key,itemID)
 local cache=self.db and self.db.professionRecipes[key]
 local recipes=cache and cache.learned
 if type(recipes)~="table" then return nil end
 for _,r in pairs(recipes) do
  if r.item==itemID then return r end
 end
 return nil
end
function B:ReadProfessionEquipment()
 if not self.db or type(GetInventoryItemID)~="function" then return false end
 local equipped={}
 local read=0
 for slot=1,19 do
  local id=number(attempt(GetInventoryItemID,"player",slot))
  if id then equipped[slot]=id end
  read=read+1
 end
 self.professionEquipped=equipped
 self.db.professionEquipped={items=equipped,when=stamp()}
 return read==19
end
function B:ProfessionIsEquipped(itemID)
 local items=self.professionEquipped
 if not items then return nil end
 for _,id in pairs(items) do
  if id==itemID then return true end
 end
 return false
end
function B:RefreshProfessionObservations(event)
 if not self.db then return end
 self:ProfessionsInit()
 -- La banque ne reste pas considérée comme accessible après reconnexion.
 if event=="PLAYER_ENTERING_WORLD" then
  self.professionBankOpen=false
  self.db.professionBank.stale=true
 end
 self:ReadProfessionSkills()
 if event=="PLAYER_ENTERING_WORLD" or
     event=="PLAYER_EQUIPMENT_CHANGED" then
  self:ReadProfessionEquipment()
 end
 if event=="BANKFRAME_OPENED" then self.professionBankOpen=true end
 if event=="BANKFRAME_CLOSED" then self.professionBankOpen=false end
 if event=="BANKFRAME_OPENED" or event=="PLAYERBANKSLOTS_CHANGED" or
    event=="PLAYERBANKBAGSLOTS_CHANGED" then
  self:ReadProfessionBank()
 end
 if event=="BANKFRAME_CLOSED" and self.db.professionBank then
  self.db.professionBank.stale=true
 end
 if event=="PLAYER_ENTERING_WORLD" or event=="BAG_UPDATE_DELAYED" or
    event=="BANKFRAME_OPENED" or event=="BANKFRAME_CLOSED" then
  self:ReadProfessionBags()
 end
 if event=="TRADE_SKILL_SHOW" or event=="TRADE_SKILL_LIST_UPDATE" or
    event=="TRADE_SKILL_DATA_SOURCE_CHANGED" then
  self:ReadProfessionRecipes()
 end
end
