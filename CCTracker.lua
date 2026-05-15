ZO_CreateStringId("SI_BINDING_NAME_CCTRACKER_TOGGLE", "Toggle CC Tracker")

local ADDON_NAME = "CCTracker"
local CC_IMMUNITY_ID = 28301
local enabled = true

local function TargetHasCCImmunity()
    for i = 1, GetNumBuffs("reticleover") do
        local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
        if abilityId == CC_IMMUNITY_ID then return true end
    end
    return false
end

local function UpdateIndicator()
    if not enabled or not IsUnitInCombat("player") then
        CCTrackerContainer:SetHidden(true)
        return
    end

    local isPlayer = GetUnitType("reticleover") == UNIT_TYPE_PLAYER
    if not isPlayer then
        CCTrackerContainer:SetHidden(true)
        return
    end

    CCTrackerContainer:SetHidden(false)
    if TargetHasCCImmunity() then
        CCTrackerLabel:SetText("CC Immune")
        CCTrackerLabel:SetColor(1, 0.2, 0.2, 1)
    else
        CCTrackerLabel:SetText("Not CC Immune")
        CCTrackerLabel:SetColor(0.2, 1, 0.2, 1)
    end
end

function CCTracker_Toggle()
    enabled = not enabled
    UpdateIndicator()
end

local function OnCombatStateChanged(eventCode, inCombat)
    UpdateIndicator()
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag)
    UpdateIndicator()
end

local function OnTargetChanged()
    UpdateIndicator()
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    CCTrackerLabel:SetFont("EsoUI/Common/Fonts/Univers67.otf|36|thick-outline")

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
