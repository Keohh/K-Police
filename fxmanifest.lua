fx_version 'cerulean'
game 'gta5'
lua54 'on'

description 'Custom Police System'
author 'Keo'

shared_script 'config.lua' 

ui_page 'web/build/index.html'

client_script { 
    'client/*.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
}
server_script 'server/*.lua'

shared_scripts {
    '@ox_lib/init.lua',
}

dependencies {
    'PolyZone'  -- Make sure you have PolyZone installed
}

files {
    'web/build/index.html',
    'web/build/asset-manifest.json',
    'web/build/static/js/*.js',
    'web/build/static/js/*.txt',
    'web/build/static/css/*.css',
}
