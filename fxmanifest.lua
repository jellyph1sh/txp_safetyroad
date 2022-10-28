fx_version "cerulean"
game "gta5"

version "1.0"
description "Script with a menu to create a slowdown zone and set signs."
author "Time_XP"

client_scripts {
    "@NativeUILua_Reloaded/src/NativeUIReloaded.lua",
    "client/cl_safetyroad.lua"
}

server_script "server/sv_safetyroad.lua"

shared_script "shared/config.lua"

dependency "NativeUILua_Reloaded"
