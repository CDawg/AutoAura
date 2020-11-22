--[==[
Copyright ©2020 Porthios of Myzrael

The contents of this addon, excluding third-party resources, are
copyrighted to Porthios with all rights reserved.
This addon is free to use and the authors hereby grants you the following rights:
1. You may make modifications to this addon for private use only, you
   may not publicize any portion of this addon.
2. Do not modify the name of this addon, including the addon folders.
3. This copyright notice shall be included in all copies or substantial
  portions of the Software.
All rights not explicitly addressed in this license are reserved by
the copyright holders.

fontstring = Frame:CreateFontString(["name" [, "layer" [, "inherits"]]])
https://wowwiki.fandom.com/wiki/UI_Object_UIDropDownMenu
https://www.wowinterface.com/forums/showthread.php?t=40444
-- notes: if unitid ~= "player" then return end
]==]--

app_global = "|cffDA70D6AutoAura: |r"
app_font   = "Fonts/ARIALN.ttf"
app_version= 1.210

print(app_global .. "Initializing v" .. app_version .. "...")

local function getPlayerInformation()
  player_name = UnitName("player")
  return player_name
end
local playerName = getPlayerInformation() .. "-" .. GetRealmName()

AANotification = {}
local function clearNotifications()
  AANotification:Hide()
end

local _GTime = 1
local function fadeNotification()
  _GTime = _GTime -0.060
  --print(_GTime)
  AANotification.text:SetTextColor(1,1,1,_GTime)
  if (_GTime <= 0.01) then
    _GTime = 1
    --print("clear")
    clearNotifications()
    return false
  end
  C_Timer.After(0.10, fadeNotification)
end

local function Notification(msg)
  AANotification:Show()
  AANotification.text:SetText(app_global .. msg)
  AANotification.text:SetTextColor(1,1,1,1)
  --_G[]
  C_Timer.After(5, function()
    fadeNotification()
  end)
end

local function CancelPlayerBuff(buffName, buffIndex)
  local i = 0
  if (UnitAffectingCombat('player')) then
    Notification("Unable to remove [" .. buffName .. "] during combat!")
  else
    Notification(buffName .. " removed!")
    CancelUnitBuff("player", buffIndex)
  end
end

local checkbox = {}

local buffList = {
  {"ARSalv",  "Blessing of Salvation", "Interface/Icons/Spell_Holy_GreaterBlessingofSalvation"},
  {"ARMight", "Blessing of Might",     "Interface/Icons/Spell_Holy_GreaterBlessingofKings"},
  {"ARSanc",  "Blessing of Sanctuary", "Interface/Icons/Spell_Holy_GreaterBlessingofSanctuary"},
  {"ARInt",   "Arcane Brilliance",     "Interface/Icons/Spell_Holy_ArcaneIntellect"},
  {"ARPoS",   "Prayer of Spirit",      "Interface/Icons/Spell_Holy_PrayerofSpirit"},
  {"ARThorns","Thorns",                "Interface/Icons/Spell_Nature_Thorns"},
}

--[==[
for k,v in pairs(buffList) do
  print(k .. " " .. v[1])
end
]==]--

local function handleAuras()
  local total = 1

  while UnitBuff("player", total) do
    local buff = UnitBuff("player", total)

    for k,v in pairs(buffList) do
      local localBuff = v[2]
      if (checkbox[v[1]]:GetChecked()) then
        if string.find(buff, localBuff) then
          CancelPlayerBuff(localBuff, total)
        end
      end
    end
    total = total + 1
  end
end

local AAFrame = CreateFrame("Frame")
AAFrame:RegisterEvent("ADDON_LOADED")
AAFrame:RegisterEvent("PLAYER_LOGOUT")
AAFrame:RegisterEvent("UNIT_AURA")
AAFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
AAFrame:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "AutoAura" then
    if AutoAura == nil then
      AutoAura = {}
    end

    if AutoAura[playerName] == nil then
      AutoAura[playerName] = {}
      print(app_global .. "Creating New Profile: " .. playerName)
    else
      print(app_global .. "Loading Profile: " .. playerName)
      setAutoAuraVars()
    end
  end

  if event == "UNIT_AURA" then
    handleAuras()
  end
  if event == "PLAYER_REGEN_ENABLED" then -- leaves combat for all
    handleAuras()
  end

end)

SLASH_AutoAura1 = "/AutoAura"
function SlashCmdList.AutoAura(msg)
  -- print("debug " .. AutoAura)
end

function setAutoAuraVars()
  for k,v in pairs(buffList) do
    if (AutoAura[playerName][v[1]]) then
      checkbox[v[1]]:SetChecked(true)
    end
  end
  if (AutoAura[playerName]["HideMMI"]) then
    checkbox["HideMMI"]:SetChecked(true)
  end
end

function saveAutoAuraVars()

  for k,v in pairs(buffList) do
    AutoAura[playerName][v[1]] = checkbox[v[1]]:GetChecked()
  end
  AutoAura[playerName]["HideMMI"] = checkbox["HideMMI"]:GetChecked()
end

local AAFrameMain = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
AAFrameMain:SetWidth(260)
AAFrameMain:SetHeight(300)
AAFrameMain:SetPoint("CENTER", 0, 0)
AAFrameMain:SetMovable(true)
AAFrameMain.text = AAFrameMain:CreateFontString(nil,"ARTWORK")
AAFrameMain.text:SetFont(app_font, 13, "OUTLINE")
AAFrameMain.text:SetPoint("TOPLEFT", AAFrameMain, "TOPLEFT", 10, -5)
AAFrameMain.text:SetText("|cffFF7D0AAUTO AURA " .. app_version)
AAFrameMain:Hide()
local AAProfileText = CreateFrame("Frame",nil, AAFrameMain)
AAProfileText:SetWidth(100)
AAProfileText:SetHeight(30)
AAProfileText:SetPoint("TOPLEFT", 10, -20)
AAProfileText.text=AAProfileText:CreateFontString(nil, "ARTWORK")
AAProfileText.text:SetFont(app_font, 14, "OUTLINE")
AAProfileText.text:SetPoint("TOPLEFT", 10, -20)
AAProfileText.text:SetText("Profile:")
local AAProfileChar = CreateFrame("Frame",nil, AAFrameMain)
AAProfileChar:SetWidth(100)
AAProfileChar:SetHeight(30)
AAProfileChar:SetPoint("TOPLEFT", 20, -30)
AAProfileChar.text=AAProfileChar:CreateFontString(nil, "ARTWORK")
AAProfileChar.text:SetFont(app_font, 14, "OUTLINE")
AAProfileChar.text:SetPoint("TOPLEFT", 20, -30)
AAProfileChar.text:SetText("|cffFF7D0A" .. UnitName("player") .. " [" .. GetRealmName() .. "]")
AANotification = CreateFrame("Frame", nil, UIParent)
AANotification:SetWidth(300)
AANotification:SetHeight(30)
AANotification:SetPoint("BOTTOMLEFT", 15, 350)
AANotification:SetFrameLevel(500)
AANotification.text = AANotification:CreateFontString(nil, "ARTWORK")
AANotification.text:SetFont(app_font, 15)
AANotification.text:SetPoint("TOPLEFT", 0, 0)
AANotification.text:SetText("")
AANotification.text:SetTextColor(1, 1, 1, 1)
AANotification:Hide()

function checkItem(checkID, checkName, icon, posY)
  local check_static = CreateFrame("CheckButton", nil, AAFrameMain, "ChatConfigCheckButtonTemplate")
  check_static:SetPoint("TOPLEFT", 30, posY)
  check_static.text = check_static:CreateFontString(nil,"ARTWORK")
  check_static.text:SetFont(app_font, 14, "OUTLINE")
  check_static.text:SetPoint("TOPLEFT", check_static, "TOPLEFT", 50, -5)
  check_static.text:SetText(checkName)
  -- check_static.tooltip = checkID
  local licon = check_static:CreateTexture(nil, "BACKGROUND", nil, -6)
  licon:SetTexture(icon)
  licon:SetSize(16, 16)
  licon:SetPoint("TOPLEFT", 30, -3)
  check_static:SetScript("OnClick",
    function()
     saveAutoAuraVars()
    end
  )
  checkbox[checkID] = check_static
end


local frameText = CreateFrame("Frame",nil, AAFrameMain)
frameText:SetWidth(100)
frameText:SetHeight(30)
frameText:SetPoint("TOPLEFT", 10, -50)
frameText.text=frameText:CreateFontString(nil, "ARTWORK")
frameText.text:SetFont(app_font, 14, "OUTLINE")
frameText.text:SetPoint("TOPLEFT", 10, -50)
frameText.text:SetText("Auto Remove:")

local checkPos_y = 100
for k,v in pairs(buffList) do
  checkPos_y = checkPos_y +20
  checkItem(v[1], v[2], v[3], -checkPos_y)
end

local function openWindow()
  AAFrameMain:Show()
end

local function closeWindow()
  AAFrameMain:Hide()
end

SlashCmdList["AutoAura"] = function(msg)
  openWindow()
end

local buttonMinimap = CreateFrame("Button", nil, Minimap)
buttonMinimap:SetFrameLevel(6)
buttonMinimap:SetSize(22, 22)
buttonMinimap:SetMovable(true)
buttonMinimap:SetNormalTexture("Interface/Icons/Spell_Holy_GreaterBlessingofSalvation")
buttonMinimap:SetPushedTexture("Interface/Icons/Spell_Holy_GreaterBlessingofSalvation")
buttonMinimap:SetHighlightTexture("Interface/Icons/Spell_Holy_GreaterBlessingofSalvation")

local myIconPos = 0

local function UpdateMapButton()
  local Xpoa, Ypoa = GetCursorPosition()
  local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
  Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
  Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
  myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
  buttonMinimap:ClearAllPoints()
  buttonMinimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 62 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 62)
end
buttonMinimap:RegisterForDrag("LeftButton")
buttonMinimap:SetScript("OnDragStart", function()
    buttonMinimap:StartMoving()
    buttonMinimap:SetScript("OnUpdate", UpdateMapButton)
end)
buttonMinimap:SetScript("OnDragStop", function()
    buttonMinimap:StopMovingOrSizing()
    buttonMinimap:SetScript("OnUpdate", nil)
    UpdateMapButton()
end)
buttonMinimap:ClearAllPoints()
buttonMinimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 62 - (80 * cos(myIconPos)),(80 * sin(myIconPos)) - 62)
buttonMinimap:SetScript("OnClick", function()
  openWindow()
end)
