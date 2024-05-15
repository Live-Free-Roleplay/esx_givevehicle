fx_version 'adamant'

game 'gta5'

description 'Admins can give cars to players'

lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/tw.lua',
	'locales/en.lua',
  "fixDeleteVehicle.lua"
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_scripts {
	'client/main.lua'
}

dependency 'es_extended'