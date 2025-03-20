local SCRIPT_NAME     = 'Landing_warning.lua'
local RUN_INTERVAL_MS = 1000

-- https://mavlink.io/en/messages/common.html#MAV_SEVERITY
local MAV_SEVERITY_EMERGENCY = 0
local MAV_SEVERITY_ALERT     = 1
local MAV_SEVERITY_CRITICAL	 = 2
local MAV_SEVERITY_ERROR     = 3
local MAV_SEVERITY_WARNING   = 4
local MAV_SEVERITY_NOTICE    = 5
local MAV_SEVERITY_INFO      = 6
local MAV_SEVERITY_DEBUG     = 7

-- https://mavlink.io/en/messages/ardupilotmega.html#COPTER_MODE
local COPTER_MODE_STABILIZE    =  0
local COPTER_MODE_ACRO         =  1
local COPTER_MODE_ALT_HOLD     =  2
local COPTER_MODE_AUTO         =  3
local COPTER_MODE_GUIDED       =  4
local COPTER_MODE_LOITER       =  5
local COPTER_MODE_RTL          =  6
local COPTER_MODE_CIRCLE       =  7
local COPTER_MODE_LAND         =  9
local COPTER_MODE_DRIFT        = 11
local COPTER_MODE_SPORT        = 13
local COPTER_MODE_FLIP         = 14
local COPTER_MODE_AUTOTUNE     = 15
local COPTER_MODE_POSHOLD      = 16
local COPTER_MODE_BRAKE        = 17
local COPTER_MODE_THROW        = 18
local COPTER_MODE_AVOID_ADSB   = 19
local COPTER_MODE_GUIDED_NOGPS = 20
local COPTER_MODE_SMART_RTL    = 21
local COPTER_MODE_FLOWHOLD     = 22
local COPTER_MODE_FOLLOW       = 23
local COPTER_MODE_ZIGZAG       = 24
local COPTER_MODE_SYSTEMID     = 25
local COPTER_MODE_AUTOROTATE   = 26
local COPTER_MODE_AUTO_RTL     = 27

-- wrapper for gcs:send_text()
local function gcs_msg(severity, txt)
    gcs:send_text(severity, string.format('%s: %s', SCRIPT_NAME, txt))
end

-- ! setup/initialization logic

local LOW_ALT = Parameter("LAND_ALT_LOW")

function update()

    if not arming:is_armed() then return update, RUN_INTERVAL_MS end

   local hagl = terrain:height_above_terrain(true)
    local lowalt = (LOW_ALT:get() /100) 
    if not vehicle:is_landing() then
        return update, RUN_INTERVAL_MS
    else
        gcs_msg(MAV_SEVERITY_INFO, 'Landing Now') 
        if hagl ~=nil then 
           -- gcs_msg(MAV_SEVERITY_INFO, string.format("HAGL: %0.1f meters",hagl ))
            if hagl < lowalt then
               --gcs_msg(MAV_SEVERITY_WARNING, 'Low landing altitude warning') 
            gcs:send_text(4,"Low Landing altitude warning")
            end
        end
        end

    return update, RUN_INTERVAL_MS
end

gcs_msg(MAV_SEVERITY_INFO, 'Initialized.')

return update()