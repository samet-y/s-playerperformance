fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'RedM Performance Monitor'
author 'huzurweriN'
description 'Open-source performance monitoring and Discord logging system for RedM'
version '2.0.0'
repository 'https://github.com/yourusername/redm-performance-monitor'

lua54 'yes'

-- Shared files
shared_scripts {
    'config.lua'
}

-- Server scripts
server_scripts {
    'server.lua'
}

-- Client scripts
client_scripts {
    'client.lua'
}