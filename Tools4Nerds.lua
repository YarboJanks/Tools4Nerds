ZO_CreateStringId("SI_BINDING_NAME_TOOLS4NERDS_TOGGLE", "Toggle Tools 4 Nerds")

local ADDON_NAME = "Tools4Nerds"
local CC_IMMUNITY_ID = 28301
local CC_IMMUNITY_DURATION = 7
local POOL_SIZE = 10
local MARKER_DURATION = 700
local SPREAD_RADIUS = 60

local CC_RESULTS = {}

local enabled = true
local tickId = 0
local tickScheduled = false
local blockTimerId = 0
local ccImmuneTimes = {}
local debuffCount = 0
local debuffFlashTimeline

local sv
local accountSv

local SETTING_KEYS = { "fontSize", "showCC", "ccColor", "showBlock", "blockColor", "showCrit", "critSize", "critColor", "autoAccept", "showDebuffCount", "debuffCountColor", "debuffCountSize" }

local function CopySettings(from, to)
    for _, key in ipairs(SETTING_KEYS) do
        local v = from[key]
        to[key] = (type(v) == "table") and { r = v.r, g = v.g, b = v.b } or v
    end
end

local defaults = {
    fontSize         = 36,
    showCC           = true,
    ccColor          = { r = 1,   g = 0.2, b = 0.2 },
    showBlock        = true,
    blockColor       = { r = 1,   g = 0.8, b = 0   },
    showCrit         = true,
    critSize         = 25,
    critColor        = { r = 1,   g = 1,   b = 1   },
    autoAccept       = true,
    showDebuffCount  = true,
    debuffCountColor = { r = 0.8, g = 0.4, b = 1.0 },
    debuffCountSize  = 36,
}

local markerPool = {}

local function CreateMarkerPool()
    for i = 1, POOL_SIZE do
        local ctrl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_Marker" .. i, T4NCritContainer, CT_TEXTURE)
        ctrl:SetTexture("Tools4Nerds/marker.dds")
        ctrl:SetDrawLayer(DL_OVERLAY)
        ctrl:SetHidden(true)

        local timeline = ANIMATION_MANAGER:CreateTimeline()
        local alphaAnim = timeline:InsertAnimation(ANIMATION_ALPHA, ctrl, 0)
        alphaAnim:SetStartAlpha(1)
        alphaAnim:SetEndAlpha(0)
        alphaAnim:SetDuration(MARKER_DURATION)

        timeline:SetHandler("OnStop", function()
            ctrl:SetHidden(true)
            ctrl:SetAlpha(1)
            table.insert(markerPool, ctrl)
        end)

        ctrl.timeline = timeline
        table.insert(markerPool, ctrl)
    end
end

local function ShowMarker()
    local ctrl = table.remove(markerPool)
    if not ctrl then return end

    local sw = T4NCritContainer:GetWidth()
    local sh = T4NCritContainer:GetHeight()
    local x = (sw / 2) + math.random(-SPREAD_RADIUS, SPREAD_RADIUS)
    local y = (sh / 2) + math.random(-SPREAD_RADIUS, SPREAD_RADIUS)

    ctrl:SetDimensions(sv.critSize, sv.critSize)
    ctrl:SetColor(sv.critColor.r, sv.critColor.g, sv.critColor.b, 1)
    ctrl:ClearAnchors()
    ctrl:SetAnchor(CENTER, T4NCritContainer, TOPLEFT, x, y)
    ctrl:SetAlpha(1)
    ctrl:SetHidden(false)
    ctrl.timeline:PlayFromStart()
end

local function ApplySettings()
    local font = string.format("EsoUI/Common/Fonts/Univers67.otf|%d|thick-outline", sv.fontSize)
    T4NLabel:SetFont(font)
    T4NBlockLabel:SetFont(font)
    local debuffFont = string.format("EsoUI/Common/Fonts/Univers67.otf|%d|thick-outline", sv.debuffCountSize)
    T4NDebuffLabel:SetFont(debuffFont)
end

local function CountDebuffs()
    return debuffCount
end

local function SetDebuffWarning(active)
    if not debuffFlashTimeline then return end
    if active then
        if not debuffFlashTimeline:IsPlaying() then
            debuffFlashTimeline:PlayFromStart()
        end
    else
        debuffFlashTimeline:Stop()
        T4NDebuffContainer:SetAlpha(1)
    end
end

local function UpdateDebuffCounter()
    if not sv.showDebuffCount then
        T4NDebuffContainer:SetHidden(true)
        SetDebuffWarning(false)
        return
    end
    local hudActive = SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
    if not hudActive then
        T4NDebuffContainer:SetHidden(true)
        SetDebuffWarning(false)
        return
    end
    T4NDebuffLabel:SetText(tostring(CountDebuffs()))
    T4NDebuffLabel:SetColor(sv.debuffCountColor.r, sv.debuffCountColor.g, sv.debuffCountColor.b, 1)
    T4NDebuffContainer:SetHidden(false)
    SetDebuffWarning(CountDebuffs() >= 6)
end

local function ShowBlockIndicator()
    blockTimerId = blockTimerId + 1
    local myId = blockTimerId
    T4NBlockLabel:SetText("Blocking")
    T4NBlockLabel:SetColor(sv.blockColor.r, sv.blockColor.g, sv.blockColor.b, 1)
    T4NBlockContainer:SetHidden(false)
    zo_callLater(function()
        if blockTimerId == myId then
            T4NBlockContainer:SetHidden(true)
        end
    end, 1500)
end

local function ShowCCIndicator()
    T4NLabel:SetText(string.format("CC  %.1fs", CC_IMMUNITY_DURATION))
    T4NLabel:SetColor(sv.ccColor.r, sv.ccColor.g, sv.ccColor.b, 1)
    T4NCCContainer:SetHidden(false)
    zo_callLater(function()
        T4NCCContainer:SetHidden(true)
    end, 2000)
end

local function GetCCImmunityRemaining()
    for i = 1, GetNumBuffs("reticleover") do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
        if abilityId == CC_IMMUNITY_ID then
            return math.max(0, timeEnding - GetFrameTimeSeconds())
        end
    end
    local targetName = GetUnitName("reticleover"):gsub("%^.*", "")
    local expiry = ccImmuneTimes[targetName]
    if expiry and GetFrameTimeSeconds() < expiry then
        return expiry - GetFrameTimeSeconds()
    end
    return nil
end

local function UpdateIndicator()
    if not enabled or not IsUnitInCombat("player") then
        tickId = tickId + 1
        tickScheduled = false
        T4NCCContainer:SetHidden(true)
        T4NBlockContainer:SetHidden(true)
        return
    end

    local isPlayer = GetUnitType("reticleover") == UNIT_TYPE_PLAYER
    if not isPlayer then
        tickId = tickId + 1
        tickScheduled = false
        T4NCCContainer:SetHidden(true)
        T4NBlockContainer:SetHidden(true)
        return
    end

    if sv.showCC then
        local remaining = GetCCImmunityRemaining()
        if remaining and remaining > 0 then
            T4NLabel:SetText(string.format("CC  %.1fs", remaining))
            T4NLabel:SetColor(sv.ccColor.r, sv.ccColor.g, sv.ccColor.b, 1)
            T4NCCContainer:SetHidden(false)
        else
            T4NCCContainer:SetHidden(true)
        end
    else
        T4NCCContainer:SetHidden(true)
    end

    if not tickScheduled then
        tickScheduled = true
        local id = tickId
        local function Tick()
            if id ~= tickId then return end
            tickScheduled = false
            UpdateIndicator()
        end
        zo_callLater(Tick, 100)
    end
end

function Tools4Nerds_Toggle()
    enabled = not enabled
    UpdateIndicator()
end

local function RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end
    if LAM.util and LAM.util.RequestRefreshIfNeeded then
        local origRefresh = LAM.util.RequestRefreshIfNeeded
        LAM.util.RequestRefreshIfNeeded = function(control)
            if LAM.applyButton then origRefresh(control) end
        end
    end

    local panelData = {
        type               = "panel",
        name               = "|cCC00FFToo|c0088BBls|c00CCAA 4 |cCC0099Ne|cFF66AArds|r",
        displayName        = "|cCC00FFToo|c0088BBls|c00CCAA 4 |cCC0099Ne|cFF66AArds|r",
        author             = "|cBF00FF@Y|c8F39F2ar|c6073E6bo|c30ACD9Ja|c01E5CDnks|r",
        version            = "2.3.0",
    }

    local optionsData = {
        {
            type = "header",
            name = "General",
        },
        {
            type      = "button",
            name      = accountSv.syncAccount and "Account-Wide Sync: |c00FF00ON|r  (click to disable)" or "Account-Wide Sync: |cFF4444OFF|r  (click to enable)",
            tooltip   = "Use the same settings across all characters on this account. Clicking copies your current settings to the new scope.",
            reference = "T4NAccountSyncButton",
            func      = function()
                local old = sv
                if not accountSv.syncAccount then
                    CopySettings(old, accountSv)
                    accountSv.syncAccount = true
                    sv = accountSv
                else
                    CopySettings(old, Tools4NerdsSV)
                    accountSv.syncAccount = false
                    sv = Tools4NerdsSV
                end
                ApplySettings()
                if T4NAccountSyncButton and T4NAccountSyncButton.button then
                    local label = accountSv.syncAccount and "Account-Wide Sync: |c00FF00ON|r  (click to disable)" or "Account-Wide Sync: |cFF4444OFF|r  (click to enable)"
                    T4NAccountSyncButton.button:SetText(label)
                end
            end,
        },
        {
            type    = "slider",
            name    = "Text Size",
            tooltip = "Font size for CC and block indicator text.",
            min     = 12,
            max     = 72,
            step    = 1,
            getFunc = function() return sv.fontSize end,
            setFunc = function(value)
                sv.fontSize = value
                ApplySettings()
            end,
        },
        {
            type = "header",
            name = "CC Immunity",
        },
        {
            type    = "checkbox",
            name    = "Enable CC Immunity Tracking",
            tooltip = "Show a countdown when your target has CC immunity.",
            getFunc = function() return sv.showCC end,
            setFunc = function(value) sv.showCC = value end,
        },
        {
            type    = "colorpicker",
            name    = "CC Immunity Color",
            tooltip = "Color of the CC immunity countdown text.",
            getFunc = function() return sv.ccColor.r, sv.ccColor.g, sv.ccColor.b, 1 end,
            setFunc = function(r, g, b, a) sv.ccColor = { r = r, g = g, b = b } end,
        },
        {
            type    = "button",
            name    = "Test CC Indicator",
            tooltip = "Trigger a test CC immunity indicator.",
            func    = function() ShowCCIndicator() end,
        },
        {
            type = "header",
            name = "Block Status",
        },
        {
            type    = "checkbox",
            name    = "Enable Block Tracking",
            tooltip = "Briefly shows an indicator when your attack is blocked.",
            getFunc = function() return sv.showBlock end,
            setFunc = function(value) sv.showBlock = value end,
        },
        {
            type    = "colorpicker",
            name    = "Block Color",
            tooltip = "Color of the blocking indicator text.",
            getFunc = function() return sv.blockColor.r, sv.blockColor.g, sv.blockColor.b, 1 end,
            setFunc = function(r, g, b, a) sv.blockColor = { r = r, g = g, b = b } end,
        },
        {
            type    = "button",
            name    = "Test Block Indicator",
            tooltip = "Trigger a test block indicator.",
            func    = function() ShowBlockIndicator() end,
        },
        {
            type = "header",
            name = "Crit Hit Marker",
        },
        {
            type    = "checkbox",
            name    = "Enable Crit Hit Marker",
            tooltip = "Show an animated marker when you land a critical hit.",
            getFunc = function() return sv.showCrit end,
            setFunc = function(value) sv.showCrit = value end,
        },
        {
            type    = "slider",
            name    = "Marker Size",
            tooltip = "Size of the hit marker in pixels.",
            min     = 10,
            max     = 200,
            step    = 1,
            getFunc = function() return sv.critSize end,
            setFunc = function(value) sv.critSize = value end,
        },
        {
            type    = "colorpicker",
            name    = "Marker Color",
            tooltip = "Color tint applied to the hit marker. White = no tint.",
            getFunc = function() return sv.critColor.r, sv.critColor.g, sv.critColor.b, 1 end,
            setFunc = function(r, g, b, a) sv.critColor = { r = r, g = g, b = b } end,
        },
        {
            type    = "button",
            name    = "Test Marker",
            tooltip = "Trigger a test hit marker.",
            func    = function() ShowMarker() end,
        },
        {
            type = "header",
            name = "Debuff Counter",
        },
        {
            type    = "checkbox",
            name    = "Enable Debuff Counter",
            tooltip = "Show a live count of negative effects currently on you.",
            getFunc = function() return sv.showDebuffCount end,
            setFunc = function(value)
                sv.showDebuffCount = value
                UpdateDebuffCounter()
            end,
        },
        {
            type    = "colorpicker",
            name    = "Debuff Counter Color",
            tooltip = "Color of the debuff counter text.",
            getFunc = function() return sv.debuffCountColor.r, sv.debuffCountColor.g, sv.debuffCountColor.b, 1 end,
            setFunc = function(r, g, b, a)
                sv.debuffCountColor = { r = r, g = g, b = b }
                UpdateDebuffCounter()
            end,
        },
        {
            type    = "slider",
            name    = "Counter Size",
            tooltip = "Font size of the debuff counter.",
            min     = 12,
            max     = 72,
            step    = 1,
            getFunc = function() return sv.debuffCountSize end,
            setFunc = function(value)
                sv.debuffCountSize = value
                T4NDebuffLabel:SetFont(string.format("EsoUI/Common/Fonts/Univers67.otf|%d|thick-outline", value))
            end,
        },
        {
            type    = "button",
            name    = "Reset Position",
            tooltip = "Move the debuff counter back to its default screen position.",
            func    = function()
                sv.debuffCountPos = nil
                T4NDebuffContainer:ClearAnchors()
                T4NDebuffContainer:SetAnchor(CENTER, GuiRoot, CENTER, 200, 0)
            end,
        },
        {
            type    = "button",
            name    = "Test Debuff Counter",
            tooltip = "Show the debuff counter with the current count.",
            func    = function()
                T4NDebuffLabel:SetText(tostring(CountDebuffs()))
                T4NDebuffLabel:SetColor(sv.debuffCountColor.r, sv.debuffCountColor.g, sv.debuffCountColor.b, 1)
                T4NDebuffContainer:SetHidden(false)
                SetDebuffWarning(true)
            end,
        },
        {
            type = "header",
            name = "Queue",
        },
        {
            type    = "checkbox",
            name    = "Auto Accept Queue",
            tooltip = "Automatically accept dungeon and PvP queue pop-ups.",
            getFunc = function() return sv.autoAccept end,
            setFunc = function(value) sv.autoAccept = value end,
        },
        {
            type    = "button",
            name    = "Reset to Defaults",
            tooltip = "Reset all settings to default values.",
            func    = function()
                sv.fontSize         = defaults.fontSize
                sv.showCC           = defaults.showCC
                sv.ccColor          = { r = defaults.ccColor.r,          g = defaults.ccColor.g,          b = defaults.ccColor.b }
                sv.showBlock        = defaults.showBlock
                sv.blockColor       = { r = defaults.blockColor.r,       g = defaults.blockColor.g,       b = defaults.blockColor.b }
                sv.showCrit         = defaults.showCrit
                sv.critSize         = defaults.critSize
                sv.critColor        = { r = defaults.critColor.r,        g = defaults.critColor.g,        b = defaults.critColor.b }
                sv.autoAccept       = defaults.autoAccept
                sv.showDebuffCount  = defaults.showDebuffCount
                sv.debuffCountColor = { r = defaults.debuffCountColor.r, g = defaults.debuffCountColor.g, b = defaults.debuffCountColor.b }
                sv.debuffCountSize  = defaults.debuffCountSize
                sv.debuffCountPos   = nil
                T4NDebuffContainer:ClearAnchors()
                T4NDebuffContainer:SetAnchor(CENTER, GuiRoot, CENTER, 200, 0)
                ApplySettings()
                UpdateDebuffCounter()
                if LAM.RefreshPanel then LAM:RefreshPanel(ADDON_NAME .. "Panel") end
            end,
        },
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", optionsData)
end

local function OnActivityFinderStatusUpdate()
    if not sv.autoAccept then return end
    if GetActivityFinderStatus() == 4 then
        zo_callLater(function()
            AcceptLFGReadyCheckNotification()
        end, 200)
    end
end

local function OnCombatStateChanged() UpdateIndicator() end
local function OnEffectChanged()      UpdateIndicator() end

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName, targetType,
    hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)

    local cleanSource = sourceName:gsub("%^.*", "")
    if cleanSource ~= GetUnitName("player") then return end

    if result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE then
        if sv.showBlock then
            blockTimerId = blockTimerId + 1
            local myId = blockTimerId
            T4NBlockLabel:SetText("Blocking")
            T4NBlockLabel:SetColor(sv.blockColor.r, sv.blockColor.g, sv.blockColor.b, 1)
            T4NBlockContainer:SetHidden(false)
            zo_callLater(function()
                if blockTimerId == myId then
                    T4NBlockContainer:SetHidden(true)
                end
            end, 1500)
        end
    end

    if CC_RESULTS[result] then
        local cleanTarget = targetName:gsub("%^.*", "")
        ccImmuneTimes[cleanTarget] = GetFrameTimeSeconds() + CC_IMMUNITY_DURATION
    end

    if result == ACTION_RESULT_CRITICAL_DAMAGE then
        if sv.showCrit then
            ShowMarker()
        end
    end
end

local function OnTargetChanged()
    tickId = tickId + 1
    tickScheduled = false
    UpdateIndicator()
end

local function UpdateNameplateIndicator(unitTag)
    if not ZO_Nameplates or not ZO_Nameplates.nameplateObjects then return end
    local obj = ZO_Nameplates.nameplateObjects[unitTag]
    if not obj or not obj.control then return end

    local unitName = (GetUnitName(unitTag) or ""):gsub("%^.*", "")
    local expiry = ccImmuneTimes[unitName]
    local isImmune = expiry and (GetFrameTimeSeconds() < expiry)

    if not obj.control.t4nImmunityDot then
        local dot = WINDOW_MANAGER:CreateControl(nil, obj.control, CT_TEXTURE)
        dot:SetTexture("Tools4Nerds/marker.dds")
        dot:SetDimensions(16, 16)
        dot:SetAnchor(RIGHT, obj.control, LEFT, -6, 0)
        dot:SetDrawLayer(DL_OVERLAY)
        obj.control.t4nImmunityDot = dot
    end

    obj.control.t4nImmunityDot:SetHidden(not isImmune)
end

local function HookNameplates()
    if not ZO_Nameplates then return end
    ZO_PreHook(ZO_Nameplates, "UpdateNameplate", function(self, unitTag)
        UpdateNameplateIndicator(unitTag)
    end)
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    if ACTION_RESULT_STUNNED     then CC_RESULTS[ACTION_RESULT_STUNNED]     = true end
    if ACTION_RESULT_KNOCKBACK   then CC_RESULTS[ACTION_RESULT_KNOCKBACK]   = true end
    if ACTION_RESULT_KNOCKDOWN   then CC_RESULTS[ACTION_RESULT_KNOCKDOWN]   = true end
    if ACTION_RESULT_DISORIENTED then CC_RESULTS[ACTION_RESULT_DISORIENTED] = true end
    if ACTION_RESULT_FEARED      then CC_RESULTS[ACTION_RESULT_FEARED]      = true end
    if ACTION_RESULT_LEVITATED   then CC_RESULTS[ACTION_RESULT_LEVITATED]   = true end

    Tools4NerdsSV        = Tools4NerdsSV or {}
    Tools4NerdsAccountSV = Tools4NerdsAccountSV or {}
    accountSv = Tools4NerdsAccountSV
    if accountSv.syncAccount == nil then accountSv.syncAccount = false end

    sv = accountSv.syncAccount and accountSv or Tools4NerdsSV

    if sv.fontSize         == nil then sv.fontSize         = defaults.fontSize end
    if sv.showCC           == nil then sv.showCC           = defaults.showCC end
    if sv.ccColor          == nil then sv.ccColor          = { r = defaults.ccColor.r,          g = defaults.ccColor.g,          b = defaults.ccColor.b } end
    if sv.showBlock        == nil then sv.showBlock        = defaults.showBlock end
    if sv.blockColor       == nil then sv.blockColor       = { r = defaults.blockColor.r,       g = defaults.blockColor.g,       b = defaults.blockColor.b } end
    if sv.showCrit         == nil then sv.showCrit         = defaults.showCrit end
    if sv.critSize         == nil then sv.critSize         = defaults.critSize end
    if sv.critColor        == nil then sv.critColor        = { r = defaults.critColor.r,        g = defaults.critColor.g,        b = defaults.critColor.b } end
    if sv.autoAccept       == nil then sv.autoAccept       = defaults.autoAccept end
    if sv.showDebuffCount  == nil then sv.showDebuffCount  = defaults.showDebuffCount end
    if sv.debuffCountColor == nil then sv.debuffCountColor = { r = defaults.debuffCountColor.r, g = defaults.debuffCountColor.g, b = defaults.debuffCountColor.b } end
    if sv.debuffCountSize  == nil then sv.debuffCountSize  = defaults.debuffCountSize end

    ApplySettings()
    CreateMarkerPool()
    RegisterSettings()
    HookNameplates()

    -- set up debuff counter container (draggable, restore saved position)
    T4NDebuffContainer:SetResizeToFitDescendents(true)
    if sv.debuffCountPos then
        T4NDebuffContainer:ClearAnchors()
        T4NDebuffContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.debuffCountPos.x, sv.debuffCountPos.y)
    end
    T4NDebuffContainer:SetHandler("OnMoveStop", function()
        sv.debuffCountPos = { x = T4NDebuffContainer:GetLeft(), y = T4NDebuffContainer:GetTop() }
    end)
    UpdateDebuffCounter()

    -- flash for warning state (>= 6 debuffs)
    debuffFlashTimeline = ANIMATION_MANAGER:CreateTimeline()
    debuffFlashTimeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP)
    local flashOut = debuffFlashTimeline:InsertAnimation(ANIMATION_ALPHA, T4NDebuffContainer, 0)
    flashOut:SetStartAlpha(1)
    flashOut:SetEndAlpha(0.15)
    flashOut:SetDuration(200)
    local flashIn = debuffFlashTimeline:InsertAnimation(ANIMATION_ALPHA, T4NDebuffContainer, 200)
    flashIn:SetStartAlpha(0.15)
    flashIn:SetEndAlpha(1)
    flashIn:SetDuration(200)
    debuffFlashTimeline:SetHandler("OnStop", function()
        T4NDebuffContainer:SetAlpha(1)
    end)

    local function OnHUDSceneChange(oldState, newState)
        UpdateDebuffCounter()
    end
    local hudScene   = SCENE_MANAGER:GetScene("hud")
    local hudUIScene = SCENE_MANAGER:GetScene("hudui")
    if hudScene   then hudScene:RegisterCallback("StateChange",   OnHUDSceneChange) end
    if hudUIScene then hudUIScene:RegisterCallback("StateChange", OnHUDSceneChange) end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE,               OnCombatStateChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED,            OnTargetChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED,                    OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Debuff", EVENT_EFFECT_CHANGED,
        function(_, changeType, _, _, unitTag, _, _, _, _, _, effectType)
            if unitTag ~= "player" then return end
            if effectType ~= 2 then return end  -- 2 = debuff, confirmed from event data
            if changeType == 1 then             -- 1 = gained
                debuffCount = debuffCount + 1
            elseif changeType == 2 then         -- 2 = faded
                debuffCount = math.max(0, debuffCount - 1)
            end
            UpdateDebuffCounter()
        end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,                      OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVITY_FINDER_STATUS_UPDATE,     OnActivityFinderStatusUpdate)

    SLASH_COMMANDS["/t4n"] = function(args)
        if args == "debug" then
            local inCombat    = IsUnitInCombat("player")
            local unitType    = GetUnitType("reticleover")
            local isPlayer    = unitType == UNIT_TYPE_PLAYER
            local numBuffs    = GetNumBuffs("reticleover")
            local foundCC     = false
            local ccRemaining = nil
            for i = 1, numBuffs do
                local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("reticleover", i)
                if abilityId == CC_IMMUNITY_ID then
                    foundCC = true
                    ccRemaining = math.max(0, timeEnding - GetFrameTimeSeconds())
                end
            end
            local targetName = GetUnitName("reticleover"):gsub("%^.*", "")
            local expiry = ccImmuneTimes[targetName]
            local inferredRemaining = expiry and math.max(0, expiry - GetFrameTimeSeconds()) or nil
            local numDebuffs = CountDebuffs()
            d(string.format("[T4N] inCombat=%s | unitType=%d | isPlayer=%s | numBuffs=%d | numDebuffs=%d | buffCC=%s | buffRemaining=%s | inferredCC=%s | tickScheduled=%s",
                tostring(inCombat), unitType, tostring(isPlayer), numBuffs, numDebuffs, tostring(foundCC),
                ccRemaining and string.format("%.2f", ccRemaining) or "nil",
                inferredRemaining and string.format("%.2f", inferredRemaining) or "nil",
                tostring(tickScheduled)))
        elseif args == "debugfx" then
            local count = 0
            local limit = 15
            d(string.format("[T4N] Listening for next %d effect change events on any unit...", limit))
            EVENT_MANAGER:RegisterForEvent("T4NDebugFX", EVENT_EFFECT_CHANGED,
                function(_, changeType, effectSlot, effectName, unitTag, _, _, stackCount, _, buffType, effectType)
                    if count >= limit then
                        EVENT_MANAGER:UnregisterForEvent("T4NDebugFX", EVENT_EFFECT_CHANGED)
                        return
                    end
                    count = count + 1
                    d(string.format("[T4NFX %d] unit=%-12s change=%-3s buff=%-3s effect=%-3s slot=%s stack=%s name=%s",
                        count, tostring(unitTag), tostring(changeType), tostring(buffType), tostring(effectType), tostring(effectSlot), tostring(stackCount), tostring(effectName)))
                end)
            zo_callLater(function()
                EVENT_MANAGER:UnregisterForEvent("T4NDebugFX", EVENT_EFFECT_CHANGED)
                d("[T4N] debugfx stopped (timeout)")
            end, 30000)
        else
            d("[T4N] Commands: /t4n debug | /t4n debugfx")
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
