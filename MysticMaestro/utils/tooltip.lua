﻿local MM = LibStub("AceAddon-3.0"):GetAddon("MysticMaestro")

local colors = {
  ["gold"] = "|cffffd700",
  ["green"] = "|cff00ff00",
  ["red"] = "|cffff0000",
  ["min"] = "|cff03fffb",
  ["med"] = "|cff00c25e",
  ["mean"] = "|cffc29e00",
  ["max"] = "|cffff0000",
  ["2"] = "|cff1eff00",
  ["3"] = "|cff0070dd",
  ["4"] = "|cffa335ee",
  ["5"] = "|cffff8000"
}

function MM:cTxt(text, color)
  return (colors[color] or "|cffffffff") .. text .. "|r"
end

local tGold = MM:cTxt("g","gold")

local function getNameAndID(input)
  local nameRE, idRE
  if type(input) == "number" then
    idRE = input
    nameRE = MM.RE_NAMES[input]
  else
    idRE = MM.RE_LOOKUP[input]
    nameRE = input
  end
  return nameRE, idRE
end

local function addLinesTooltip(tt, input)
  local name, reID = getNameAndID(input)
  local stats = MM.db.realm.RE_AH_STATISTICS[reID]["current"]
  local dataRE = MYSTIC_ENCHANTS[reID]
  local indicator
  if dataRE then
    mmText = MM:cTxt(dataRE.known and "Known " or "Unknown " , dataRE.known and "green" or "red")
    name = MM:cTxt(name, tostring(dataRE.quality))
    if dataRE.known then
      indicator = CreateTextureMarkup("Interface\\Icons\\ability_felarakkoa_feldetonation_green", 64, 64, 16, 16, 0, 1, 0, 1)
    else
      indicator = CreateTextureMarkup("Interface\\Icons\\ability_felarakkoa_feldetonation_red", 64, 64, 16, 16, 0, 1, 0, 1)
    end
    tt:AppendText("   "..indicator)
  end
  tt:AddDoubleLine("Mystic Maestro:",(mmText and mmText or ""),1,1,0)
  local demoString = MM:cTxt("Min","min").."("..MM:cTxt("Med","med").."/"..MM:cTxt("Mean","mean").."/"..MM:cTxt("Max","max")..")"
  tt:AddDoubleLine("RE: " ..name, (stats and demoString or "None Listed" ))
  if stats ~= nil then
    if stats.Last ~= nil then
      local ttMin = MM:round(stats.Min or 0.0)
      local ttMed = MM:round(stats.Med or 0.0)
      local ttMean = MM:round(stats.Mean or 0.0)
      local ttMax = MM:round(stats.Max or 0.0)
      local ttTotal = MM:round(stats.Total or 0.0)
      local ttListed = stats.Count or 0.0
      local ttStr = ""
      if stats.Total ~= stats.Count then
        ttStr = " of " .. stats.Total
      end
      tt:AddDoubleLine("("..ttListed..ttStr..") Market Value ("..MM:DaysAgoString(stats.Last)..")"
      , MM:cTxt(ttMin,"min")..tGold.." ("..MM:cTxt(ttMed,"med")..tGold.."/"..MM:cTxt(ttMean,"mean")..tGold.."/"..MM:cTxt(ttMax,"max")..tGold..")"
      , 1, 1, 0)
    end
    tt:AddDoubleLine("Gold per Mystic Orb"
    , MM:OrbValue(reID)
    , 1, 1, 0)
  end
  tt:AddLine(" ")
end

function MM:TooltipHandlerItem(tooltip)
  local enchant
  enchant = MM:MatchTooltipRE(tooltip)
  if enchant then
    addLinesTooltip(tooltip, enchant)
  end
end

function MM:TooltipHandlerSpell(tooltip)
  local enchant
  enchant = select(3 , tooltip:GetSpell())
  if MYSTIC_ENCHANTS[enchant] == nil then
    local swapID = MM.RE_ID[enchant]
    if swapID and MYSTIC_ENCHANTS[swapID] ~= nil then
      enchant = swapID
    else
      return
    end
  end
  if enchant then
    addLinesTooltip(tooltip, enchant)
  end
end
