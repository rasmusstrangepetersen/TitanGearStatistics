-- *** Version information
TITAN_GS_VERSION = "10.0.2";

-- *** Plugin identity
TITAN_GS_ID = "GearStat";
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

-- *** Variables 
tgsShowDebug = false;
TitanGS_FirstCycle = true;
TitanGS_TimeCounter = 0;
TITAN_GS_UPDATE_FREQUENCE = 1.5;
local updateFrame = CreateFrame("frame");

-- *** Tables is defined at the end of the file


-- **************************************************************************
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelGearStatButton_OnLoad(self)
  self.registry = {
    id = TITAN_GS_ID,
    category = "Information",
    version = TITAN_GS_VERSION,
    menuText = TITAN_GS_ID,
    buttonTextFunction = "TitanPanelGearStatButton_GetButtonText",
    tooltipTitle = TITAN_GS_TOOLTIP_TITLE,
    tooltipTextFunction = "TitanPanelGearStatButton_GetTooltipText",
    icon = "Interface\\Icons\\INV_Chest_Samurai",
    iconWidth = 16,
    controlVariables = {
      ShowIcon = true,
      ShowLabelText = true,
      ShowRegularText = true,
      ShowColoredText = true,
      DisplayOnRightSide = false,
    },
    savedVariables = {
      ShowIcon = 1,
      ShowLabelText = 1,
      ShowRegularText = 1,
      ShowColoredText = 1,
    }
  };

  self:RegisterEvent("PLAYER_LEAVING_WORLD");
  self:RegisterEvent("PLAYER_ENTERING_WORLD");

  updateFrame:SetScript("OnUpdate", TitanPanelGearStatButton_OnUpdate)
        
  tgsDebug("TitanPanelGearStat loaded", 0);
end

-- **************************************************************************
-- DESC : Debug function to print message to chat frame
-- VARS : Message = message to print to chat frame
-- **************************************************************************
function tgsDebug(Message, override)
   if (tgsShowDebug or override ==1) then
      DEFAULT_CHAT_FRAME:AddMessage("|c"..GS_colorRed.."Titan GS: " .. Message);
   end
end

-- **************************************************************************
-- DESC : This section will grab the events registered to the add on and act on them
-- **************************************************************************
function TitanPanelGearStatButton_OnEvent(self, event, a1, ...)
  tgsDebug("Received event: "..event, 0);

  if (event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_LEVEL_UP") then
    TitanPanelButton_UpdateButton(TITAN_GS_ID);
    TitanPanelButton_UpdateTooltip(self);
    return
  end

  if (event == "PLAYER_ENTERING_WORLD") then
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:RegisterEvent("PLAYER_LEVEL_UP");
    return;
  end
    
  if (event == "PLAYER_LEAVING_WORLD") then
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:UnregisterEvent("PLAYER_LEVEL_UP");
    return;
  end
end

-- **************************************************************************
-- DESC : update button text and dropdown list with gear
-- VARS : elapsed = how often do we update the button (events should be enough)
-- **************************************************************************
function TitanPanelGearStatButton_OnUpdate(self, elapsed)
  tgsDebug("Trying to update button, elapsed: "..TitanGS_TimeCounter, 0);
  
  TitanGS_TimeCounter = TitanGS_TimeCounter + 0.01

  if (TitanGS_TimeCounter >= TITAN_GS_UPDATE_FREQUENCE and TitanGS_FirstCycle == false) then
    tgsDebug("Trying to update button - second cycle - stop here, titanGearStat_TimeCounter: "..TitanGS_TimeCounter, 0);
    TitanPanelButton_UpdateButton(TITAN_GS_ID);
    TitanPanelButton_UpdateTooltip(self);
    TitanGS_TimeCounter = 0
    updateFrame:SetScript("OnUpdate", nil)
  end
  if ( TitanGS_TimeCounter >= TITAN_GS_UPDATE_FREQUENCE and TitanGS_FirstCycle == true) then
    TitanGS_FirstCycle = false
    tgsDebug("Trying to update button - first cycle, titanGearStat_TimeCounter: "..TitanGS_TimeCounter, 0);
  end
end

-- **************************************************************************
-- DESC : Open main UI on left click
-- **************************************************************************
function TitanPanelGearStatButton_OnClick(self, button)
  tgsDebug("Entering TitanPanelGearStatButton_OnClick, button: "..button, 0);

  if (button == "LeftButton") then
    GS_CharFrame_Toggle();
  end
end

-- **************************************************************************
-- DESC : Update Titan Panel button text
-- VARS : id = plugin id
-- **************************************************************************
function TitanPanelGearStatButton_GetButtonText(id)
  tgsDebug("Entering TitanPanelGSButton_GetButtonText, ShowRegularText", 0);
  
  out = ""

  if (TitanGetVar(TITAN_GS_ID,"ShowRegularText")) then
    out = TitanPanelGS_GetScore(TitanGetVar(TITAN_GS_ID,"ShowColoredText"))
  end
  
  return TITAN_GS_LABEL_TEXT, out
end

-- **************************************************************************
-- DESC : Return the players current gear score as formatted text
-- VARS : inColor, if 1 then return the text in right colour
-- **************************************************************************
function TitanPanelGS_GetScore(inColor)
  if(GS.currentPlayer.averageItemLevel == 0) then
    GS_UpdatePlayer("player", 1);
  end
  
--  local averageItemScore = "i"..format("%.0f", GS.currentPlayer.averageItemLevel).." ("..format("%.0f", GS.currentPlayer.averageItemScore)..")"
  local averageItemScore = "i"..format("%.0f", GS.currentPlayer.averageItemLevel)

  if(inColor) then
    local color = TitanPanelGS_GetColorByScore(GS.currentPlayer.playerLevel, GS.currentPlayer.averageItemLevel);
    averageItemScore = "|c"..color..averageItemScore
  end
  
  return averageItemScore
end

-- **************************************************************************
-- DESC : Returns the colour that matches the averageItemLevel for the players own level
-- **************************************************************************
function TitanPanelGS_GetColorByScore(playerLevel, averageItemLevel) 
  local color = GS_colorBlue; -- Unknown, light blue

  tgsDebug("|c"..color.."get color from: "..averageItemLevel.." - player level: "..playerLevel, 0);

  -- Shadowland
  if(playerLevel < TITAN_GS_MIN_LEVEL_DRAGONFLIGHT) then
    for index in ipairs(TITAN_GS_ITEM_ILVL_LOW_LIMITS_SHADOWLAND) do
      if(averageItemLevel > TITAN_GS_ITEM_ILVL_LOW_LIMITS_SHADOWLAND[index].value) then
        color = ITEM_RARITY[index].color
      end
    end
  -- Dragonflight
--  elseif(playerLevel >= TITAN_GS_MIN_LEVEL_DRAGONFLIGHT and playerLevel < TITAN_GS_MIN_LEVEL_FUTURE) then
 else
    for index in ipairs(TITAN_GS_ITEM_ILVL_LOW_LIMITS_DRAGONFLIGHT) do
      if(averageItemLevel > TITAN_GS_ITEM_ILVL_LOW_LIMITS_DRAGONFLIGHT[index].value) then
        color = ITEM_RARITY[index].color
      end
    end
  end

  tgsDebug("|c"..color.."color found", 0);

  return color;
end 

-- **************************************************************************
-- DESC : Update tooltip text
-- **************************************************************************
function TitanPanelGearStatButton_GetTooltipText()
  tgsDebug("Entering: TitanPanelGearStatButton_GetTooltipText", 0);

  TitanPanelButton_UpdateButton(TITAN_GS_ID);
  TitanPanelButton_UpdateTooltip(self);

  out = TitanPanelGS_GetPlayerGear()
  out = out.."\n".."|c"..GS_colorBlue..TITAN_GS_GEAR_CLICK

  return out;
end

-- **************************************************************************
-- DESC : Return the players current gear with itemLevel and score as formatted text
-- **************************************************************************
function TitanPanelGS_GetPlayerGear()
  tgsDebug("Returning player gear", 0);

  text = ""
  local iName = ""
  
  for index in ipairs(GS_GEARLIST) do 
    GS_GEARLIST[index].id = GetInventorySlotInfo(GS_GEARLIST[index].name);
    local slotLink = GetInventoryItemLink(UnitName("player"), GS_GEARLIST[index].id);
    if (slotLink ~= nil) then
      local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType = GetItemInfo(slotLink);
      local itemScore = 0;
      iName = itemName;
      if(GS_GEARLIST[index].minLevel > 0 and itemLink) then
        if (GS_isLegionArtifactWeapon(GS_GEARLIST[index].desc, iName)==0) then
          text = text..GS_GEARLIST[index].desc..": "..GS.currentPlayer.itemList[GS_GEARLIST[index].name].itemLink
          local missingEnchantsAndGems = GS.currentPlayer.itemList[GS_GEARLIST[index].name].itemMissingText;
          itemLevel = GS.currentPlayer.itemList[GS_GEARLIST[index].name].itemLevel
          local itemScore = GS.currentPlayer.itemList[GS_GEARLIST[index].name].itemScore
          local levelColor = GS.currentPlayer.itemList[GS_GEARLIST[index].name].levelColor
    
          text = text.."\t".."|c"..levelColor..missingEnchantsAndGems;
          text = text.." i"..itemLevel.." ("..format("%.0f", itemScore)..")"
          text = text.."\n";
        end
      end
    else
      -- Don't write "empty offhand slot", if two hand weapon is equipped and don't write empty tabard and shirt
      if((not (GS_GEARLIST[index].desc == GS_OFFHAND and GS.currentPlayer.twoHandWeapon == true)) and GS_GEARLIST[index].minLevel <= GS.currentPlayer.playerLevel) then
        if (GS_isLegionArtifactWeapon(GS_GEARLIST[index].desc, iName)==0 and GS_GEARLIST[index].minLevel > 0) then
          text = text..GS_GEARLIST[index].desc..": ".."|c"..GS_colorGrey..TITAN_GS_NO.." "..GS_GEARLIST[index].desc.." "..TITAN_GS_EQUIPPED
          text = text.."\n"
        end
      end
    end
  end
--  text = text.." ".."\t"..TITAN_GS_AVERAGE..": i"..format("%.0f", GS.currentPlayer.averageItemLevel);
  text = text.." ".."\t"..TITAN_GS_AVERAGE..": i"..format("%.0f", GS.currentPlayer.averageItemLevel).." ("..format("%.0f", GS.currentPlayer.averageItemScore)..")";
--  text = text.."\n ".."\t"..TITAN_GS_TOTAL..": i"..format("%.0f", GS.currentPlayer.totalItemLevel).." ("..format("%.0f", GS.currentPlayer.totalItemScore)..")";

  return text
end

-- **************************************************************************
-- DESC : Right click menu in titanbar
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareGearStatMenu()
  tgsDebug("Preparing rightclick menu", 0);
  
  
  -- level 1
  TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_GS_ID].menuText);

  TitanPanelRightClickMenu_AddSpacer();
  TitanPanelRightClickMenu_AddToggleIcon(TITAN_GS_ID);
  TitanPanelRightClickMenu_AddToggleLabelText(TITAN_GS_ID);
  TitanPanelRightClickMenu_AddToggleColoredText(TITAN_GS_ID);
  TitanPanelRightClickMenu_AddSpacer();
  TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_GS_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

-- **************************************************************************
-- DESC : Tables used to decide which color the titanbar text should have
-- **************************************************************************

TITAN_GS_MIN_LEVEL_SHADOWLAND = 1
TITAN_GS_MIN_LEVEL_DRAGONFLIGHT = 61
  
TITAN_GS_ITEM_ILVL_LOW_LIMITS_SHADOWLAND = { -- Levels reset 1-60
  { name = GS_POOR,      value = 1 },
  { name = GS_COMMON,    value = 90},
  { name = GS_UNCOMMON,  value = 128},
  { name = GS_RARE,      value = 158}, -- Achievement Superior
  { name = GS_EPIC,      value = 183}, -- Achievement Epic
  { name = GS_LEGENDARY, value = 226},
  { name = GS_ARTIFACT,  value = 226},
}
TITAN_GS_ITEM_ILVL_LOW_LIMITS_DRAGONFLIGHT = { -- level 61-70
  { name = GS_POOR,      value = 158 },
  { name = GS_COMMON,    value = 183 },
  { name = GS_UNCOMMON,  value = 226 }, 
  { name = GS_RARE,      value = 346 }, -- superior achievement
  { name = GS_EPIC,      value = 372 }, -- epic achievement
  { name = GS_LEGENDARY, value = 400 },
  { name = GS_ARTIFACT,  value = 400 },
}
