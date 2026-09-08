local frame = CreateFrame("Frame", "WarmaneMercQueueFrame", UIParent)
frame:SetWidth(300)
frame:SetHeight(30)
frame:SetPoint("TOP", UIParent, "TOP", 0, -180)

-- Set up frame movement logic
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
    if not WarmaneMercQueueDB or not WarmaneMercQueueDB.locked then
        self:StartMoving()
    end
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Save frame position to SavedVariables
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    WarmaneMercQueueDB = WarmaneMercQueueDB or {}
    WarmaneMercQueueDB.position = { point, relativePoint, xOfs, yOfs }
end)

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("TOP", frame, "TOP", 0, 0)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local timerAccumulator = 0

local function FormatMillis(ms)
    local totalSeconds = math.floor((ms or 0) / 1000)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function UpdateQueueDisplay()
    local queueLines = {}

    for i = 1, MAX_BATTLEFIELD_QUEUES do
        local status, mapName, instanceID, minlevel, maxlevel, teamSize = GetBattlefieldStatus(i)
        if status == "queued" then
            local timeWaited = GetBattlefieldTimeWaited(i) or 0
            local timeFormatted = FormatMillis(timeWaited)

            -- Determine queue label (BG name or Arena Bracket)
            local queueLabel = mapName or "Queue"
            if teamSize and teamSize > 0 then
                if mapName == "Arena" or mapName == "All Arenas" or not mapName or mapName == "" then
                    queueLabel = "Arena " .. teamSize .. "v" .. teamSize
                else
                    queueLabel = mapName .. " " .. teamSize .. "v" .. teamSize
                end
            end

            -- Format individual queue line
            local line = ""
            if _G["MERCENARYMODE_ENABLED"] == true then
                line = "|cffffffff" .. queueLabel .. ": " .. timeFormatted .. "|r |cffff0000(Mercenary ON)|r"
            else
                line = "|cffffffff" .. queueLabel .. ": " .. timeFormatted .. "|r"
            end

            table.insert(queueLines, line)
        end
    end

    if #queueLines > 0 then
        text:SetText(table.concat(queueLines, "\n"))
        frame:SetHeight(#queueLines * 22)
        frame:Show()
    else
        frame:Hide()
    end
end

frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "WarmaneMercQueue" then
        WarmaneMercQueueDB = WarmaneMercQueueDB or { locked = false, scale = 1.0, alpha = 0.75 }
        frame:EnableMouse(not WarmaneMercQueueDB.locked)
        
        -- Restore saved settings
        frame:SetScale(WarmaneMercQueueDB.scale or 1.0)
        text:SetAlpha(WarmaneMercQueueDB.alpha or 0.75)

        if WarmaneMercQueueDB.position then
            local pos = WarmaneMercQueueDB.position
            frame:ClearAllPoints()
            frame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
        end
    else
        UpdateQueueDisplay()
    end
end)

frame:SetScript("OnUpdate", function(self, elapsed)
    timerAccumulator = timerAccumulator + elapsed
    if timerAccumulator >= 1 then
        timerAccumulator = 0
        if frame:IsShown() then
            UpdateQueueDisplay()
        end
    end
end)

-- Slash command handler (/wmq)
SLASH_WARMANEMERC1 = "/wmq"
SLASH_WARMANEMERC2 = "/mercqueue"
SlashCmdList["WARMANEMERC"] = function(msg)
    local cmd, arg = string.match(msg or "", "^(%S+)%s*(.-)$")
    cmd = string.lower(cmd or msg or "")
    arg = string.lower(arg or "")

    WarmaneMercQueueDB = WarmaneMercQueueDB or { locked = false, scale = 1.0, alpha = 0.75 }

    if cmd == "lock" then
        WarmaneMercQueueDB.locked = true
        frame:EnableMouse(false)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Frame position |cffff0000LOCKED|r.")
    elseif cmd == "unlock" then
        WarmaneMercQueueDB.locked = false
        frame:EnableMouse(true)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Frame position |cff00ff00UNLOCKED|r (drag to move).")
    elseif cmd == "scale" then
        local val = tonumber(arg)
        if val then
            if val > 10 then val = val / 100 end -- converts values like 120 or 150 to 1.2 or 1.5
            val = math.max(0.5, math.min(3.0, val))
            WarmaneMercQueueDB.scale = val
            frame:SetScale(val)
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Scale set to |cff00ff00" .. math.floor(val * 100) .. "%|r.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Usage: |cffffffff/wmq scale 1.2|r (or 120)")
        end
    elseif cmd == "alpha" then
        local val = tonumber(arg)
        if val then
            if val > 1 then val = val / 100 end -- converts values like 75 or 100 to 0.75 or 1.0
            val = math.max(0.1, math.min(1.0, val))
            WarmaneMercQueueDB.alpha = val
            text:SetAlpha(val)
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Alpha set to |cff00ff00" .. math.floor(val * 100) .. "%|r.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Usage: |cffffffff/wmq alpha 0.75|r (or 75)")
        end
    elseif cmd == "reset" then
        WarmaneMercQueueDB.position = nil
        WarmaneMercQueueDB.scale = 1.0
        WarmaneMercQueueDB.alpha = 0.75
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "TOP", 0, -180)
        frame:SetScale(1.0)
        text:SetAlpha(0.75)
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Reset to defaults (Center, 100% scale, 75% alpha).")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff9900[WMQ]|r Commands:")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffffffff/wmq lock|r or |cffffffff/wmq unlock|r")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffffffff/wmq scale <0.5-3.0>|r (e.g. /wmq scale 1.2 or 120)")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffffffff/wmq alpha <0.1-1.0>|r (e.g. /wmq alpha 0.75 or 75)")
        DEFAULT_CHAT_FRAME:AddMessage(" - |cffffffff/wmq reset|r")
    end
end