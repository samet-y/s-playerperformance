-- ============================================
-- RedM Performance Monitor by huzurweriN
-- Open Source Performance Monitoring System
-- License: MIT
-- ============================================

local performanceData = {
    ping = 0,
    fps = 0,
    memory = 0
}

local frameCount = 0
local lastFrameTime = GetGameTimer()
local currentFPS = 0
local showHUD = Config.HUD.defaultVisible

-- ============================================
-- FPS CALCULATION
-- ============================================

CreateThread(function()
    while true do
        Wait(0)
        frameCount = frameCount + 1
        
        local currentTime = GetGameTimer()
        if currentTime - lastFrameTime >= 1000 then
            currentFPS = frameCount
            frameCount = 0
            lastFrameTime = currentTime
        end
    end
end)

-- ============================================
-- DATA COLLECTION
-- ============================================

local function GetPerformanceData()
    performanceData.fps = currentFPS
    performanceData.memory = collectgarbage("count") / 1024
    performanceData.ping = 0
    
    return performanceData
end

-- ============================================
-- EVENT HANDLERS
-- ============================================

RegisterNetEvent('performanceMonitor:receivePing')
AddEventHandler('performanceMonitor:receivePing', function(ping)
    performanceData.ping = ping
end)

RegisterNetEvent('performanceMonitor:requestData')
AddEventHandler('performanceMonitor:requestData', function()
    TriggerServerEvent('performanceMonitor:requestPing')
    
    Wait(100)
    local data = GetPerformanceData()
    TriggerServerEvent('performanceMonitor:sendData', data)
end)

-- ============================================
-- AUTOMATIC DATA SENDING
-- ============================================

CreateThread(function()
    while true do
        Wait(Config.CheckInterval)
        TriggerServerEvent('performanceMonitor:requestPing')
        Wait(100)
        local data = GetPerformanceData()
        TriggerServerEvent('performanceMonitor:sendData', data)
    end
end)

-- ============================================
-- HUD SYSTEM
-- ============================================

RegisterCommand('perfhud', function()
    if not Config.HUD.enabled then return end
    
    showHUD = not showHUD
    
    local message = showHUD and Config.Translate('hud_enabled') or Config.Translate('hud_disabled')
    TriggerEvent('chat:addMessage', {
        args = {"[Performance Monitor]", message}
    })
end, false)

-- HUD Drawing
CreateThread(function()
    while true do
        Wait(0)
        
        if Config.HUD.enabled and showHUD then
            local data = performanceData
            
            local pingColor = {r = 0, g = 255, b = 0}
            if data.ping > Config.Thresholds.ping then
                pingColor = {r = 255, g = 165, b = 0}
            end
            if data.ping > Config.AlertLevels.critical.ping then
                pingColor = {r = 255, g = 0, b = 0}
            end
            
            local fpsColor = {r = 0, g = 255, b = 0}
            if data.fps < Config.Thresholds.fps then
                fpsColor = {r = 255, g = 165, b = 0}
            end
            if data.fps < Config.AlertLevels.critical.fps then
                fpsColor = {r = 255, g = 0, b = 0}
            end
            
            local function DrawText(text, x, y, r, g, b)
                local str = CreateVarString(10, "LITERAL_STRING", text)
                SetTextScale(Config.HUD.scale, Config.HUD.scale)
                SetTextColor(r, g, b, 255)
                SetTextCentre(false)
                SetTextDropshadow(1, 0, 0, 0, 255)
                SetTextFontForCurrentCommand(1)
                DisplayText(str, x, y)
            end
            
            local yOffset = Config.HUD.position.y
            
            DrawText(string.format("Ping: %d ms", data.ping), 
                Config.HUD.position.x, yOffset, pingColor.r, pingColor.g, pingColor.b)
            yOffset = yOffset + 0.03
            
            DrawText(string.format("FPS: %d", data.fps), 
                Config.HUD.position.x, yOffset, fpsColor.r, fpsColor.g, fpsColor.b)
            yOffset = yOffset + 0.03
            
            if Config.HUD.showMemory then
                DrawText(string.format("Memory: %.2f MB", data.memory), 
                    Config.HUD.position.x, yOffset, 255, 255, 255)
            end
        else
            Wait(500)
        end
    end
end)