fx_version 'adamant'
game 'gta5'
description 'Drugs by 4Slang'
author '4Slang#7113'

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'server/*',
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/*',
}

dependencies {
	'es_extended'
}
