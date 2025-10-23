# 🎯 S-PlayerPerformance

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![RedM](https://img.shields.io/badge/RedM-Compatible-red.svg)
![Open Source](https://img.shields.io/badge/Open%20Source-❤-orange.svg)

**Professional performance monitoring and analytics system for RedM servers**

[Features](#-features) • [Installation](#-installation) • [Configuration](#-configuration) • [Commands](#-commands) • [Contributing](#-contributing)

</div>

---

## 📋 Features

### Core Features
- ✅ **Real-time Monitoring** - Track ping, FPS, and memory usage
- ✅ **Discord Integration** - Automatic webhook notifications with rich embeds
- ✅ **In-game HUD** - Visual performance display with `/perfhud` command
- ✅ **Smart Thresholds** - Automatic detection of performance issues
- ✅ **Multi-language Support** - English, Turkish (easily extendable)

### Advanced Features
- 🚀 **Performance History** - Track historical data for each player
- 🚀 **Automatic Reports** - Periodic server-wide performance reports
- 🚀 **Alert Levels** - Categorized alerts (Critical, Warning, Info, Good)
- 🚀 **Average Statistics** - Per-player performance averages
- 🚀 **Admin Commands** - Comprehensive server performance overview
- 🚀 **Multiple Webhooks** - Different webhooks for different alert levels
- 🚀 **Spam Prevention** - Configurable minimum log intervals

---

## 🚀 Installation

### 1. Download
Clone or download this repository:
```bash
git clone https://github.com/samet-y/s-playerperformance.git
```

### 2. Install
Place the folder in your server's `resources` directory:
```
server/
└── resources/
    └── s-playerperformance/
        ├── client.lua
        ├── server.lua
        ├── config.lua
        └── fxmanifest.lua
```

### 3. Configure Discord Webhook
1. Open your Discord server
2. Go to Server Settings → Integrations → Webhooks
3. Create a new webhook
4. Copy the webhook URL

### 4. Edit Configuration
Open `config.lua` and set your webhook:
```lua
Config.PrimaryWebhook = "YOUR_DISCORD_WEBHOOK_URL_HERE"
```

### 5. Start Resource
Add to your `server.cfg`:
```cfg
ensure s-playerperformance
```

---

## ⚙️ Configuration

### Basic Settings

```lua
Config.Language = 'en'              -- 'en' or 'tr'
Config.Debug = false                -- Enable debug logs
Config.CheckInterval = 300000       -- Check every 5 minutes
Config.LogAllPlayers = false        -- Only log threshold violations
```

### Thresholds

```lua
Config.Thresholds = {
    ping = 150,  -- Log if ping is ABOVE this (ms)
    fps = 30     -- Log if FPS is BELOW this
}
```

### Alert Levels

```lua
Config.AlertLevels = {
    critical = { ping = 250, fps = 15 },  -- Red
    warning = { ping = 150, fps = 30 },   -- Orange
    info = { ping = 100, fps = 40 }       -- Blue
}
```

### Performance History

```lua
Config.SaveHistory = true     -- Save player performance history
Config.HistoryLimit = 50      -- Maximum records per player
```

### Automatic Reports

```lua
Config.AutoReports = {
    enabled = true,
    interval = 3600000,  -- Every 1 hour
    minPlayers = 5       -- Minimum players to send report
}
```

### HUD Settings

```lua
Config.HUD = {
    enabled = true,
    defaultVisible = false,
    position = { x = 0.01, y = 0.01 },
    scale = 0.35,
    showMemory = true
}
```

---

## 🎮 Commands

### Player Commands
| Command | Description | Usage |
|---------|-------------|-------|
| `/perfhud` | Toggle performance HUD | In-game |
| `/perfhistory` | View your performance history | Chat |

### Admin Commands (Console)
| Command | Description |
|---------|-------------|
| `perflog` | Request performance data from all players |
| `perftest` | Send test log (bypasses thresholds) |
| `perfadmin` | View all players' live performance |

---

## 📊 Discord Webhooks

### Single Webhook
Set `Config.PrimaryWebhook` for all alerts.

### Multiple Webhooks (Optional)
Use different channels for different alert levels:

```lua
Config.Webhooks = {
    critical = "https://discord.com/api/webhooks/...",  -- Critical alerts
    warning = "https://discord.com/api/webhooks/...",   -- Warnings
    info = "https://discord.com/api/webhooks/..."       -- Info & reports
}
```

---

## 🌍 Multi-language Support

### Supported Languages
- 🇬🇧 English (`en`)
- 🇹🇷 Turkish (`tr`)

### Adding a New Language

1. Open `config.lua`
2. Add your language to `Config.Translations`:

```lua
Config.Translations['es'] = {
    system_started = "Monitor de rendimiento iniciado!",
    -- ... add all translation keys
}
```

3. Set `Config.Language = 'es'`

---

## 🎨 Customization

### Change Embed Colors

```lua
-- In server/server.lua, GetAlertLevel function
return "critical", 15158332  -- Red (hex: 0xE74C3C)
return "warning", 15105570   -- Orange (hex: 0xE67E22)
return "info", 3447003       -- Blue (hex: 0x3498DB)
return "good", 3066993       -- Green (hex: 0x2ECC71)
```

### Adjust Performance Metrics

```lua
-- More strict thresholds
Config.Thresholds = { ping = 100, fps = 40 }

-- More lenient thresholds
Config.Thresholds = { ping = 200, fps = 20 }
```

---

## 🔧 Advanced Configuration

### Spam Prevention

```lua
Config.Advanced = {
    minLogInterval = 60,  -- Minimum seconds between logs for same player
}
```

### Webhook Timeout

```lua
Config.Advanced = {
    webhookTimeout = 10,  -- Timeout in seconds
}
```

---

## 📸 Screenshots

### Discord Alert Example

<img width="594" height="213" alt="image" src="https://github.com/user-attachments/assets/12953c63-e4d5-40e7-836f-b05bba8e07ba" />


### In-game HUD

<img width="431" height="181" alt="Screenshot 2025-10-24 023341" src="https://github.com/user-attachments/assets/2862529a-fe63-4e05-8272-ce3ab380be9c" />


---

## 🐛 Troubleshooting

### Discord logs not appearing

1. **Check webhook URL**
   ```lua
   Config.PrimaryWebhook = "YOUR_URL_HERE"
   ```

2. **Enable debug mode**
   ```lua
   Config.Debug = true
   ```

3. **Check thresholds**
   - Lower thresholds or set `Config.LogAllPlayers = true` for testing

4. **Test with command**
   ```
   perftest
   ```

### FPS showing as 0

1. Check F8 console for client errors
2. Restart the resource: `restart s-playerperformance`
3. Ensure `client.lua` is loaded correctly

### Commands not working

1. Verify resource is started: `ensure s-playerperformance`
2. Check `fxmanifest.lua` is correct
3. Restart server

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Areas for Contribution
- 🌍 Add more language translations
- 🎨 Improve Discord embed designs
- 🚀 Add new performance metrics
- 📱 Create web dashboard
- 🔌 Framework integrations (ESX, QBCore)

---

## 📝 Changelog

### [2.0.0] - 2025

#### Added
- Performance history tracking
- Automatic server reports
- Multi-level alert system
- Average performance statistics
- Admin overview commands
- Multiple webhook support
- Spam prevention
- Multi-language support
- Shared config system

#### Improved
- Code organization
- Performance optimization
- Documentation
- Error handling

### [1.0.0] - Initial Release
- Basic performance monitoring
- Discord webhook integration
- In-game HUD
- Threshold system

---

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Performance Monitor Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- RedM Community
- Discord.js for webhook inspiration
- All contributors and testers

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/samety/s-playerperformance/issues)
- **Discord**: [Join our Discord](https://discord.gg/f5AEmhuCmc)

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

---

<div align="center">

Made with ❤️ for the RedM Community

</div>
