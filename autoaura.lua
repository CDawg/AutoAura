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

app_name = "AutoAura"
app_global = "|cffDA70D6" .. app_name .. ": |r"
app_version = "1.0.1b"
app_width = 300
app_height = 340
app_content_y = 10

DEFAULT_CHAT_FRAME:AddMessage (app_global .. "Initializing v" .. app_version .. "...");

function getPlayerInformation()
  player_name = UnitName("player")
  return player_name
end
playerName = getPlayerInformation() .. "-" .. GetRealmName()

function CancelPlayerBuff(buffName, buffIndex)
  local i = 0
  if (UnitAffectingCombat('player')) then
    DEFAULT_CHAT_FRAME:AddMessage (app_global .. "Unable to remove [" .. buffName .. "] during combat!");
  else
    -- CancelUnitBuff("player", buffIndex);
    if (ddNotify.text:GetText() == "Notify Me") then
      DEFAULT_CHAT_FRAME:AddMessage (app_global .. buffName .. " removed!");
    elseif (ddNotify.text:GetText() == "Notify Raid") then
      SendChatMessage(app_name .. ": " .. buffName .. " removed!", "RAID");
    end
    CancelUnitBuff("player", buffIndex);
  end
end

function chat_message(msg, channel)
  SendChatMessage(app_global .. msg, channel);
end

auraTimer = 1;
function handleAuras()
  local total = 1

  if (auraTimer == 1) then
    while UnitBuff("player", total) do
        local buff = UnitBuff("player", total)

        local localBuff = "Blessing of Salvation";
        if (checkbox["ARSalv"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Blessing of Might";
        if (checkbox["ARMight"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Blessing of Sanctuary";
        if (checkbox["ARSanc"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Arcane Brilliance";
        if (checkbox["ARInt"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Arcane Intellect";
        if (checkbox["ARInt"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Prayer of Spirit";
        if (checkbox["ARPoS"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
        local localBuff = "Thorns";
        if (checkbox["ARThorns"]:GetChecked()) then
          if string.find(buff, localBuff) then
            CancelPlayerBuff(localBuff, total)
          end
        end
      -- DEFAULT_CHAT_FRAME:AddMessage(app_global .. buff .. " index:" .. total); -- DEBUG
      total = total + 1
    end
  end
  auraTimer = auraTimer + 1
  if (auraTimer >= 3) then
    auraTimer = 1
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")

frame:SetScript("OnEvent", function(self, event, arg1)
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
  if event == "PLAYER_LEAVE_COMBAT" then -- leave combat melee
    handleAuras()
  end

end)

SLASH_AutoAura1 = "/AutoAura"
function SlashCmdList.AutoAura(msg)
  -- print("debug " .. AutoAura)
end

function setAutoAuraVars()
  if (AutoAura[playerName]["ARSalv"]) then
    checkbox["ARSalv"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARMight"]) then
    checkbox["ARMight"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARSanc"]) then
    checkbox["ARSanc"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARInt"]) then
    checkbox["ARInt"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARPoS"]) then
    checkbox["ARPoS"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARThorns"]) then
    checkbox["ARThorns"]:SetChecked(true);
  end
  if (AutoAura[playerName]["ARNotification"]) then
     ddNotify.text:SetText(AutoAura[playerName]["ARNotification"])
  end
end

function saveAutoAuraVars()
  AutoAura[playerName]["ARInt"] = checkbox["ARInt"]:GetChecked();
  AutoAura[playerName]["ARSalv"] = checkbox["ARSalv"]:GetChecked();
  AutoAura[playerName]["ARPoS"] = checkbox["ARPoS"]:GetChecked();
  AutoAura[playerName]["ARThorns"] = checkbox["ARThorns"]:GetChecked();
  AutoAura[playerName]["ARMight"] = checkbox["ARMight"]:GetChecked();
  AutoAura[playerName]["ARSanc"] = checkbox["ARSanc"]:GetChecked();
  AutoAura[playerName]["ARNotification"] = ddNotify.text:GetText()
end

raiderList = {}
function getRaiders()
  for i = 1, GetNumGroupMembers() do
    raiderList[i] = GetRaidRosterInfo(i);
  end
end

local frameMain = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset");
frameMain:SetWidth(app_width);
frameMain:SetHeight(app_height);
frameMain:SetPoint("CENTER", 0, 0);
frameMain:SetMovable(true);
frameMain.text = frameMain:CreateFontString(nil,"ARTWORK");
frameMain.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
frameMain.text:SetPoint("TOPLEFT", frameMain, "TOPLEFT", 10, -5);
frameMain.text:SetText("|cffFF7D0AAUTO AURA " .. app_version);
frameMain:Hide();

local profileText = CreateFrame("Frame",nil, frameMain)
profileText:SetWidth(100)
profileText:SetHeight(30)
profileText:SetPoint("TOPLEFT", 10, -20)
profileText.text=profileText:CreateFontString(nil, "ARTWORK")
profileText.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
profileText.text:SetPoint("TOPLEFT", 10, -20)
profileText.text:SetText("Profile:")

local profileChar = CreateFrame("Frame",nil, frameMain)
profileChar:SetWidth(100)
profileChar:SetHeight(30)
profileChar:SetPoint("TOPLEFT", 20, -30)
profileChar.text=profileChar:CreateFontString(nil, "ARTWORK")
profileChar.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
profileChar.text:SetPoint("TOPLEFT", 20, -30)
profileChar.text:SetText("|cffFF7D0A" .. UnitName("player") .. " [" .. GetRealmName() .. "]")

--[==[
function enableUI(thisFrame, thisFrameGlobal)
  thisFrameGlobal:SetTextColor(1, 1, 1, 1)
  thisFrame:SetEnabled(true)
end
function disableUI(thisFrame, thisFrameGlobal)
  thisFrameGlobal:SetTextColor(1, 1, 1, 0.4)
  thisFrame:SetEnabled(false)
end

function setAutoSalvChildrenUI()
  if (check_autoRemoveSalv:GetChecked()) then
    enableUI(check_autoSalvDuringCombat, check_autoSalvDuringCombat_GlobalNameText)
  else
    disableUI(check_autoSalvDuringCombat, check_autoSalvDuringCombat_GlobalNameText)
  end
end
]==]--

checkbox = {}
function checkItem(checkID, checkName, icon, posY)
  local check_static = CreateFrame("CheckButton", nil, frameMain, "ChatConfigCheckButtonTemplate");
  check_static:SetPoint("TOPLEFT", 30, posY)
  check_static.text = check_static:CreateFontString(nil,"ARTWORK");
  check_static.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE");
  check_static.text:SetPoint("TOPLEFT", check_static, "TOPLEFT", 50, -5);
  check_static.text:SetText(checkName);
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


local frameText = CreateFrame("Frame",nil, frameMain)
frameText:SetWidth(100)
frameText:SetHeight(30)
frameText:SetPoint("TOPLEFT", 10, -50)
frameText.text=frameText:CreateFontString(nil, "ARTWORK")
frameText.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
frameText.text:SetPoint("TOPLEFT", 10, -50)
frameText.text:SetText("Auto Remove:")

checkItem("ARSalv", "Blessing of Salvation", "Interface/Icons/Spell_Holy_GreaterBlessingofSalvation", -120)
checkItem("ARMight","Blessing of Might", "Interface/Icons/Spell_Holy_GreaterBlessingofKings", -140)
checkItem("ARSanc", "Blessing of Sanctuary", "Interface/Icons/Spell_Holy_GreaterBlessingofSanctuary", -160)
checkItem("ARInt",  "Intellect/Brilliance", "Interface/Icons/Spell_Holy_ArcaneIntellect", -180)
checkItem("ARPoS",  "Prayer of Spirit", "Interface/Icons/Spell_Holy_PrayerofSpirit", -200)
checkItem("ARThorns","Thorns", "Interface/Icons/Spell_Nature_Thorns", -220)

-- NOTIFICATIONS --
local frameText = CreateFrame("Frame",nil, frameMain)
frameText:SetWidth(100)
frameText:SetHeight(30)
frameText:SetPoint("TOPLEFT", 10, -130)
frameText.text=frameText:CreateFontString(nil, "ARTWORK")
frameText.text:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
frameText.text:SetPoint("TOPLEFT", 10, -130)
frameText.text:SetText("Notifications:")

local ddNotifyList={"Notify Me", "Notify Raid", "No Notifications"}
local posY = -280
ddNotify = CreateFrame("frame", nil, frameMain, "UIDropDownMenuTemplate")
ddNotify:SetPoint("TOPLEFT", 20, posY);
ddNotify.text = ddNotify:CreateFontString(nil,"ARTWORK");
ddNotify.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
ddNotify.text:SetPoint("TOPLEFT", ddNotify, "TOPLEFT", 25, -8);
ddNotify.text:SetText("Notify Me");
ddNotify.onClick = function(self, checked)
	-- print(app_global .. "Debug Notifications: " .. self.value)
  ddNotify.text:SetText(self.value)
  saveAutoAuraVars()
end

ddNotify.initialize = function(self, level)
	local info = UIDropDownMenu_CreateInfo()
  for ddKey, ddVal in pairs(ddNotifyList) do
    info.text = ddVal
  	info.value= ddVal
  	info.func = self.onClick
  	UIDropDownMenu_AddButton(info, level)
  end
end

function openWindow()
  frameMain:Show()
end

--[==[
self:RegisterEvent("PARTY_INVITE_REQUEST", "confirmPartyInvite")
function MyAddon:confirmPartyInvite(info, sender)
  if ( MyAddon:someTestOfSenderThatYouMakeUp(sender) ) then
    AcceptGroup();
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "closePopup")
  end
end

function MyAddon:closePopup()
  StaticPopup_Hide("PARTY_INVITE")
  self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
end
]==]--

function closeWindow()
  frameMain:Hide()
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
    buttonMinimap:StopMovingOrSizing();
    buttonMinimap:SetScript("OnUpdate", nil)
    UpdateMapButton();
end)
buttonMinimap:ClearAllPoints();
buttonMinimap:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 62 - (80 * cos(myIconPos)),(80 * sin(myIconPos)) - 62)
buttonMinimap:SetScript("OnClick", function()
  openWindow()
end)
