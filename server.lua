-- ============================================
-- RedM Performance Monitor by huzurweriN
-- Open Source Performance Monitoring System
-- License: MIT
-- ============================================

local serverStartTime = os.time()
local performanceHistory = {}
local lastLogTime = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetPlayerLicense(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, "license:") then
            return id
        end
    end
    return nil
end

local function GetPlayerSteam(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.match(id, "steam:") then
            return id
        end
    end
    return "Not Found"
end

local function CanLog(source)
    if not Config.Advanced.minLogInterval then return true end
    
    local license = GetPlayerLicense(source)
    if not license then return true end
    
    local currentTime = os.time()
    local lastTime = lastLogTime[license] or 0
    
    if currentTime - lastTime < Config.Advanced.minLogInterval then
        return false
    end
    
    lastLogTime[license] = currentTime
    return true
end

local function GetAlertLevel(ping, fps)
    if ping >= Config.AlertLevels.critical.ping or fps <= Config.AlertLevels.critical.fps then
        return "critical", 15158332
    elseif ping >= Config.AlertLevels.warning.ping or fps <= Config.AlertLevels.warning.fps then
        return "warning", 15105570
    elseif ping >= Config.AlertLevels.info.ping or fps <= Config.AlertLevels.info.fps then
        return "info", 3447003
    else
        return "good", 3066993
    end
end

-- ============================================
-- PERFORMANCE HISTORY FUNCTIONS
-- ============================================

local function SavePerformanceHistory(source, data)
    if not Config.SaveHistory then return end
    
    local license = GetPlayerLicense(source)
    if not license then return end
    
    if not performanceHistory[license] then
        performanceHistory[license] = {}
    end
    
    table.insert(performanceHistory[license], {
        timestamp = os.time(),
        ping = data.ping,
        fps = data.fps,
        memory = data.memory
    })
    
    if #performanceHistory[license] > Config.HistoryLimit then
        table.remove(performanceHistory[license], 1)
    end
end

local function GetAveragePerformance(source)
    local license = GetPlayerLicense(source)
    if not license or not performanceHistory[license] then
        return nil
    end
    
    local history = performanceHistory[license]
    local totalPing, totalFPS, totalMemory = 0, 0, 0
    local count = #history
    
    for _, record in ipairs(history) do
        totalPing = totalPing + record.ping
        totalFPS = totalFPS + record.fps
        totalMemory = totalMemory + record.memory
    end
    
    return {
        avgPing = math.floor(totalPing / count),
        avgFPS = math.floor(totalFPS / count),
        avgMemory = totalMemory / count,
        recordCount = count
    }
end

-- ============================================
-- DISCORD FUNCTIONS
-- ============================================

local function SendToDiscord(title, description, color, fields, alertLevel)
    local webhook = Config.PrimaryWebhook
    
    if alertLevel and Config.Webhooks[alertLevel] and Config.Webhooks[alertLevel] ~= "" then
        webhook = Config.Webhooks[alertLevel]
    end
    
    if webhook == "" or not webhook then
        if Config.Debug then
            print("[Performance Monitor] " .. Config.Translate('webhook_missing'))
        end
        return
    end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["type"] = "rich",
            ["color"] = color,
            ["fields"] = fields,
            ["footer"] = {
                ["text"] = "RedM Performance Monitor v2.0 | " .. os.date("%Y-%m-%d %H:%M:%S")
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers)
        if Config.Debug then
            if err == 200 or err == 204 then
                print("[Performance Monitor] " .. Config.Translate('discord_success'))
            else
                print("[Performance Monitor] " .. Config.Translate('discord_failed', err))
            end
        end
    end, 'POST', json.encode({
        username = "Performance Monitor",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- ============================================
-- EVENT HANDLERS
-- ============================================

RegisterServerEvent('performanceMonitor:requestPing')
AddEventHandler('performanceMonitor:requestPing', function()
    local _source = source
    local ping = GetPlayerPing(_source)
    TriggerClientEvent('performanceMonitor:receivePing', _source, ping)
end)

RegisterServerEvent('performanceMonitor:sendData')
AddEventHandler('performanceMonitor:sendData', function(data)
    local _source = source
    local playerName = GetPlayerName(_source)
    
    data.ping = GetPlayerPing(_source)
    
    if not CanLog(_source) then
        return
    end
    
    local steam = GetPlayerSteam(_source)
    local license = GetPlayerLicense(_source) or "Not Found"
    
    SavePerformanceHistory(_source, data)
    
    local shouldLog = Config.LogAllPlayers or 
                      (data.ping > Config.Thresholds.ping or data.fps < Config.Thresholds.fps)
    
    if shouldLog then
        local alertLevel, color = GetAlertLevel(data.ping, data.fps)
        local avgPerf = GetAveragePerformance(_source)
        
        local fields = {
            {
                ["name"] = "👤 " .. Config.Translate('embed_player'),
                ["value"] = playerName,
                ["inline"] = true
            },
            {
                ["name"] = "🆔 " .. Config.Translate('embed_steam_id'),
                ["value"] = steam,
                ["inline"] = true
            },
            {
                ["name"] = "📊 " .. Config.Translate('embed_server_id'),
                ["value"] = tostring(_source),
                ["inline"] = true
            },
            {
                ["name"] = "📡 " .. Config.Translate('embed_ping'),
                ["value"] = tostring(data.ping) .. " ms",
                ["inline"] = true
            },
            {
                ["name"] = "🎮 " .. Config.Translate('embed_fps'),
                ["value"] = tostring(data.fps),
                ["inline"] = true
            },
            {
                ["name"] = "💾 " .. Config.Translate('embed_memory'),
                ["value"] = string.format("%.2f MB", data.memory),
                ["inline"] = true
            }
        }
        
        if avgPerf and avgPerf.recordCount >= 3 then
            table.insert(fields, {
                ["name"] = "📈 " .. Config.Translate('embed_average'),
                ["value"] = string.format("Ping: %dms | FPS: %d | Memory: %.2fMB\n(%d records)", 
                    avgPerf.avgPing, avgPerf.avgFPS, avgPerf.avgMemory, avgPerf.recordCount),
                ["inline"] = false
            })
        end
        
        local description = "**" .. Config.Translate('embed_description') .. "**"
        
        if alertLevel == "critical" then
            description = description .. "\n🚨 **" .. Config.Translate('embed_critical') .. "**"
        elseif alertLevel == "warning" then
            description = description .. "\n⚠️ **" .. Config.Translate('embed_warning') .. "**"
        elseif alertLevel == "info" then
            description = description .. "\nℹ️ **" .. Config.Translate('embed_info') .. "**"
        end
        
        if data.ping > 200 then
            description = description .. "\n⚠️ " .. Config.Translate('high_ping_detected')
        end
        if data.fps < 30 then
            description = description .. "\n⚠️ " .. Config.Translate('low_fps_detected')
        end
        
        SendToDiscord(
            "🔍 " .. Config.Translate('embed_title'),
            description,
            color,
            fields,
            alertLevel
        )
    end
end)

-- ============================================
-- COMMANDS
-- ============================================

RegisterCommand('perflog', function(source, args)
    if source == 0 then
        print("[Performance Monitor] " .. Config.Translate('perflog_requested'))
        TriggerClientEvent('performanceMonitor:requestData', -1)
    else
        TriggerClientEvent('performanceMonitor:requestData', source)
    end
end, true)

RegisterCommand('perftest', function(source, args)
    if source == 0 then
        TriggerClientEvent('performanceMonitor:requestData', -1)
    else
        local oldLogAll = Config.LogAllPlayers
        Config.LogAllPlayers = true
        print("[Performance Monitor] " .. Config.Translate('perftest_running'))
        TriggerClientEvent('performanceMonitor:requestData', source)
        
        SetTimeout(2000, function()
            Config.LogAllPlayers = oldLogAll
        end)
    end
end, true)

RegisterCommand('perfhistory', function(source, args)
    if source == 0 then
        print("[Performance Monitor] This command is for players only!")
        return
    end
    
    local avgPerf = GetAveragePerformance(source)
    
    if not avgPerf then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"[Performance Monitor]", Config.Translate('perfhistory_none')}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"[Performance Monitor]", Config.Translate('perfhistory_result',
            avgPerf.avgPing, avgPerf.avgFPS, avgPerf.avgMemory, avgPerf.recordCount)}
    })
end, false)

RegisterCommand('perfadmin', function(source, args)
    if source ~= 0 then
        return
    end
    
    local players = GetPlayers()
    print("========================================")
    print("[Performance Monitor] " .. Config.Translate('admin_report_header'))
    print("========================================")
    print(string.format("%s: %d", Config.Translate('report_players'), #players))
    print("")
    
    for _, playerId in ipairs(players) do
        local playerName = GetPlayerName(playerId)
        local ping = GetPlayerPing(playerId)
        local avgPerf = GetAveragePerformance(playerId)
        
        if avgPerf then
            print(string.format("%s (ID: %s) - Ping: %dms | Avg FPS: %d | Records: %d",
                playerName, playerId, ping, avgPerf.avgFPS, avgPerf.recordCount))
        else
            print(string.format("%s (ID: %s) - Ping: %dms | %s",
                playerName, playerId, ping, Config.Translate('admin_no_data')))
        end
    end
    print("========================================")
end, true)

-- ============================================
-- AUTOMATIC SYSTEMS
-- ============================================

-- Automatic monitoring
CreateThread(function()
    while true do
        Wait(Config.CheckInterval)
        TriggerClientEvent('performanceMonitor:requestData', -1)
    end
end)

-- Automatic reports
CreateThread(function()
    if not Config.AutoReports.enabled then return end
    
    while true do
        Wait(Config.AutoReports.interval)
        
        local players = GetPlayers()
        if #players < Config.AutoReports.minPlayers then
            goto continue
        end
        
        local totalPing, totalFPS, totalMemory = 0, 0, 0
        local goodPerf, warningPerf, criticalPerf = 0, 0, 0
        local validPlayers = 0
        
        for _, playerId in ipairs(players) do
            local ping = GetPlayerPing(playerId)
            local avgPerf = GetAveragePerformance(playerId)
            
            if avgPerf then
                validPlayers = validPlayers + 1
                totalPing = totalPing + avgPerf.avgPing
                totalFPS = totalFPS + avgPerf.avgFPS
                totalMemory = totalMemory + avgPerf.avgMemory
                
                local level = GetAlertLevel(avgPerf.avgPing, avgPerf.avgFPS)
                if level == "critical" then
                    criticalPerf = criticalPerf + 1
                elseif level == "warning" then
                    warningPerf = warningPerf + 1
                else
                    goodPerf = goodPerf + 1
                end
            end
        end
        
        if validPlayers == 0 then goto continue end
        
        local avgPing = math.floor(totalPing / validPlayers)
        local avgFPS = math.floor(totalFPS / validPlayers)
        local avgMemory = totalMemory / validPlayers
        
        local fields = {
            {
                ["name"] = "👥 " .. Config.Translate('report_players'),
                ["value"] = tostring(#players),
                ["inline"] = true
            },
            {
                ["name"] = "📊 " .. Config.Translate('report_time'),
                ["value"] = os.date("%H:%M:%S"),
                ["inline"] = true
            },
            {
                ["name"] = "⏱️ " .. Config.Translate('report_uptime'),
                ["value"] = string.format("%.1f hours", (os.time() - serverStartTime) / 3600),
                ["inline"] = true
            },
            {
                ["name"] = "📡 " .. Config.Translate('report_avg_ping'),
                ["value"] = avgPing .. " ms",
                ["inline"] = true
            },
            {
                ["name"] = "🎮 " .. Config.Translate('report_avg_fps'),
                ["value"] = tostring(avgFPS),
                ["inline"] = true
            },
            {
                ["name"] = "💾 " .. Config.Translate('report_avg_memory'),
                ["value"] = string.format("%.2f MB", avgMemory),
                ["inline"] = true
            },
            {
                ["name"] = "✅ " .. Config.Translate('report_good'),
                ["value"] = tostring(goodPerf),
                ["inline"] = true
            },
            {
                ["name"] = "⚠️ " .. Config.Translate('report_warnings'),
                ["value"] = tostring(warningPerf),
                ["inline"] = true
            },
            {
                ["name"] = "🚨 " .. Config.Translate('report_critical'),
                ["value"] = tostring(criticalPerf),
                ["inline"] = true
            }
        }
        
        SendToDiscord(
            "📊 " .. Config.Translate('report_title'),
            "**" .. Config.Translate('report_description') .. "**",
            3447003,
            fields,
            "info"
        )
        
        ::continue::
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("========================================")
    print("[Performance Monitor v2.0] " .. Config.Translate('system_started'))
    print("========================================")
    print("Configuration:")
    print(string.format("  - Check Interval: %d seconds", Config.CheckInterval / 1000))
    print(string.format("  - Ping Threshold: %dms", Config.Thresholds.ping))
    print(string.format("  - FPS Threshold: %d", Config.Thresholds.fps))
    print(string.format("  - Log All Players: %s", tostring(Config.LogAllPlayers)))
    print(string.format("  - Save History: %s", tostring(Config.SaveHistory)))
    print(string.format("  - Language: %s", Config.Language))
    
    print("\nCommands:")
    print("  - perflog - Manual log request")
    print("  - perftest - Test log (bypasses threshold)")
    print("  - perfhistory - View personal history")
    print("  - perfadmin - View all players (admin)")
    
    if Config.AutoReports.enabled then
        print(string.format("\nAuto Reports: Enabled (Every %d minutes)", Config.AutoReports.interval / 60000))
    end
    
    if Config.PrimaryWebhook == "" or not Config.PrimaryWebhook then
        print("\n⚠️  WARNING: " .. Config.Translate('webhook_missing'))
    else
        print("\n✓ " .. Config.Translate('webhook_set'))
    end
    print("========================================")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print("[Performance Monitor] " .. Config.Translate('system_stopped'))
end)