fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'wiadros#0'

shared_scripts {'@ox_lib/init.lua', 'shared.lua'}

client_script 'client/client.lua'
server_script 'server/server.lua'

dependencies {
    'es_extended',
    'ox_lib',
}
