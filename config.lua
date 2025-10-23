Config = {}

-- ============================================
-- GENERAL SETTINGS
-- ============================================

Config.Language = 'en' -- Available: 'en', 'tr', 'de', 'fr', 'es'
Config.Debug = false -- Enable debug mode (recommended: false for production)

-- ============================================
-- DISCORD WEBHOOK SETTINGS
-- ============================================

Config.PrimaryWebhook = "" -- Main Discord webhook URL (required)

-- Optional: Separate webhooks for different alert levels
Config.Webhooks = {
    critical = nil, -- Red alerts (critical performance issues)
    warning = nil,  -- Orange alerts (performance warnings)
    info = nil      -- Blue alerts (informational)
}

-- ============================================
-- MONITORING SETTINGS
-- ============================================

-- Automatic check interval in milliseconds
-- 60000 = 1 minute
-- 300000 = 5 minutes (recommended)
-- 600000 = 10 minutes
Config.CheckInterval = 300000

-- Log all players regardless of threshold
-- true = Log all players on every check
-- false = Only log players exceeding thresholds (recommended)
Config.LogAllPlayers = false

-- ============================================
-- PERFORMANCE THRESHOLDS
-- ============================================

-- Players exceeding these values will be logged
Config.Thresholds = {
    ping = 150, -- Milliseconds - Log if ABOVE this value
    fps = 30    -- Frames per second - Log if BELOW this value
}

-- ============================================
-- ALERT LEVELS
-- ============================================

-- Performance levels for color coding and categorization
Config.AlertLevels = {
    critical = { ping = 250, fps = 15 }, -- Red (15158332)
    warning = { ping = 150, fps = 30 },  -- Orange (15105570)
    info = { ping = 100, fps = 40 }      -- Blue (3447003)
}

-- ============================================
-- PERFORMANCE HISTORY
-- ============================================

-- Save performance history for each player
Config.SaveHistory = true

-- Maximum number of records per player
-- Higher values = More memory usage
Config.HistoryLimit = 50

-- ============================================
-- AUTOMATIC REPORTS
-- ============================================

Config.AutoReports = {
    enabled = true,        -- Enable automatic server reports
    interval = 3600000,    -- Report interval in milliseconds (1 hour)
    minPlayers = 5         -- Minimum players required to send report
}

-- ============================================
-- HUD SETTINGS
-- ============================================

Config.HUD = {
    enabled = true,           -- Enable in-game HUD
    defaultVisible = false,   -- Show HUD by default when player joins
    position = {
        x = 0.01,            -- X position (0.0 to 1.0)
        y = 0.01             -- Y position (0.0 to 1.0)
    },
    scale = 0.35,            -- Text scale
    showMemory = true        -- Show memory usage in HUD
}

-- ============================================
-- ADVANCED SETTINGS
-- ============================================

Config.Advanced = {
    webhookTimeout = 10,        -- Webhook timeout in seconds
    minLogInterval = 60,        -- Minimum seconds between logs for same player (spam prevention)
    preciseFPS = false,         -- More accurate FPS calculation (slightly higher CPU usage)
    includeServerInfo = true,   -- Include server uptime in reports
    anonymizeData = false       -- Remove identifying information from logs
}

-- ============================================
-- ADMIN SETTINGS
-- ============================================

-- Admin groups that can use admin commands
Config.AdminGroups = {
    "admin",
    "moderator",
    "owner",
    "superadmin"
}

-- Steam IDs with admin permissions (optional)
Config.AdminSteamIDs = {
    -- "steam:110000xxxxxxxx"
}

-- ============================================
-- TRANSLATIONS
-- ============================================

Config.Translations = {
    ['en'] = {
        -- System messages
        system_started = "Performance Monitor started successfully!",
        system_stopped = "Performance Monitor stopped.",
        webhook_missing = "Discord webhook URL not configured!",
        webhook_set = "Discord webhook configured",
        
        -- Commands
        perflog_requested = "Performance data requested from all players",
        perftest_running = "Test log sent",
        perfhistory_none = "No performance history available yet.",
        perfhistory_result = "Average Performance: Ping: %dms | FPS: %d | Memory: %.2fMB | Records: %d",
        
        -- Notifications
        data_received = "Data received from player %s - Ping: %dms | FPS: %d | Memory: %.2fMB",
        threshold_not_met = "Threshold not met, log skipped",
        threshold_met = "Threshold exceeded! Sending log to Discord...",
        discord_success = "Successfully sent to Discord!",
        discord_failed = "Failed to send to Discord! Error code: %d",
        
        -- Discord embed
        embed_title = "Player Performance Analysis",
        embed_description = "Performance Report",
        embed_critical = "CRITICAL SITUATION!",
        embed_warning = "WARNING!",
        embed_info = "Information",
        
        embed_player = "Player",
        embed_steam_id = "Steam ID",
        embed_license_id = "License ID",
        embed_server_id = "Server ID",
        embed_ping = "Ping (MS)",
        embed_fps = "FPS",
        embed_memory = "Memory Usage",
        embed_average = "Average Performance",
        
        high_ping_detected = "High ping detected!",
        low_fps_detected = "Low FPS detected!",
        
        -- Server report
        report_title = "Server Performance Report",
        report_description = "Automatic Periodic Report",
        report_players = "Total Players",
        report_time = "Server Time",
        report_uptime = "Uptime",
        report_avg_ping = "Average Ping",
        report_avg_fps = "Average FPS",
        report_avg_memory = "Average Memory",
        report_good = "Good Performance",
        report_warnings = "Warning Level",
        report_critical = "Critical Level",
        
        -- Admin commands
        admin_report_header = "Server Performance Report",
        admin_no_data = "No data available",
        
        -- HUD
        hud_enabled = "Performance HUD enabled",
        hud_disabled = "Performance HUD disabled",
    },
    
    ['tr'] = {
        -- Sistem mesajları
        system_started = "Performans İzleyici başarıyla başlatıldı!",
        system_stopped = "Performans İzleyici durduruldu.",
        webhook_missing = "Discord webhook URL'si yapılandırılmamış!",
        webhook_set = "Discord webhook yapılandırıldı",
        
        -- Komutlar
        perflog_requested = "Tüm oyunculardan performans verisi istendi",
        perftest_running = "Test logu gönderildi",
        perfhistory_none = "Henüz performans geçmişi yok.",
        perfhistory_result = "Ortalama Performans: Ping: %dms | FPS: %d | Bellek: %.2fMB | Kayıt: %d",
        
        -- Bildirimler
        data_received = "%s oyuncusundan veri alındı - Ping: %dms | FPS: %d | Bellek: %.2fMB",
        threshold_not_met = "Eşik aşılmadı, log atlandı",
        threshold_met = "Eşik aşıldı! Discord'a log gönderiliyor...",
        discord_success = "Discord'a başarıyla gönderildi!",
        discord_failed = "Discord'a gönderilemedi! Hata kodu: %d",
        
        -- Discord embed
        embed_title = "Oyuncu Performans Analizi",
        embed_description = "Performans Raporu",
        embed_critical = "KRİTİK DURUM!",
        embed_warning = "UYARI!",
        embed_info = "Bilgilendirme",
        
        embed_player = "Oyuncu",
        embed_steam_id = "Steam ID",
        embed_license_id = "License ID",
        embed_server_id = "Server ID",
        embed_ping = "Ping (MS)",
        embed_fps = "FPS",
        embed_memory = "Bellek Kullanımı",
        embed_average = "Ortalama Performans",
        
        high_ping_detected = "Yüksek ping tespit edildi!",
        low_fps_detected = "Düşük FPS tespit edildi!",
        
        -- Sunucu raporu
        report_title = "Sunucu Performans Raporu",
        report_description = "Otomatik Periyodik Rapor",
        report_players = "Toplam Oyuncu",
        report_time = "Sunucu Saati",
        report_uptime = "Çalışma Süresi",
        report_avg_ping = "Ortalama Ping",
        report_avg_fps = "Ortalama FPS",
        report_avg_memory = "Ortalama Bellek",
        report_good = "İyi Performans",
        report_warnings = "Uyarı Seviyesi",
        report_critical = "Kritik Seviye",
        
        -- Admin komutları
        admin_report_header = "Sunucu Performans Raporu",
        admin_no_data = "Veri yok",
        
        -- HUD
        hud_enabled = "Performans HUD'u açıldı",
        hud_disabled = "Performans HUD'u kapatıldı",
    }
}

-- Helper function to get translation
function Config.Translate(key, ...)
    local lang = Config.Translations[Config.Language] or Config.Translations['en']
    local text = lang[key] or Config.Translations['en'][key] or key
    
    if ... then
        return string.format(text, ...)
    end
    
    return text
end