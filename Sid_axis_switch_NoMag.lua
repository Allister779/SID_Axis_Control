-- This is a way to switch SID_AXIS based on the position of Aux1.  
-- SystemID paramenters should be set up before using this script.  

-- This script only updates the SID Axis.
-- It is based on SID_axis_switch_V2

local SCRIPT_NAME     = 'SID_AXIS_Switch'
local RUN_INTERVAL_MS = 1000
local RC_OPTION       = 300 -- Set up a 3-pos switch for Scripting1

-- User to set the specific axis for each switch postion.

-- SID_AXIS Values

--  0 None

--  1 Input Roll Angle
--  2 Input Pitch Angle
--  3 Input Yaw Angle

--  4 Recovery Roll Angle
--  5 Recovery Pitch Angle
--  6 Recovery Yaw Angle

--  7 Rate Roll
--  8 Rate Pitch
--  9 Rate Yaw

local AXIS_LOW        = 4  -- SID_AXIS with the switch in the low position

local AXIS_MID        = 5  -- SID_AXIS with the switch in the mid positoin

local AXIS_HIGH       = 6  -- SID_AXIS with the switch in the high position

local MAV_SEVERITY_EMERGENCY = 0
local MAV_SEVERITY_ALERT     = 1
local MAV_SEVERITY_CRITICAL	 = 2
local MAV_SEVERITY_ERROR     = 3
local MAV_SEVERITY_WARNING   = 4
local MAV_SEVERITY_NOTICE    = 5
local MAV_SEVERITY_INFO      = 6
local MAV_SEVERITY_DEBUG     = 7

local COPTER_MODE_SYSTEMID     = 25


-- wrapper for gcs:send_text()
local function gcs_msg(severity, txt)
    gcs:send_text(severity, string.format('%s: %s', SCRIPT_NAME, txt))
end

-- setup/initialization logic
local rc_chan = rc:find_channel_for_option(RC_OPTION)
local last_sw_pos = nil

-- Make sure that there is something set for SystemID parameters.
local SYStemID_AXIS = param:get('SID_AXIS')
if SYStemID_AXIS == 0 then
 gcs_msg(MAV_SEVERITY_ERROR, 'SystemID must be configured for this script.') return
else
    gcs_msg(MAV_SEVERITY_INFO, "SystemID is configured.")
end

function update()
    local sw_pos = rc_chan:get_aux_switch_pos()  -- returns 0, 1, or 2
    local current_mode = vehicle:get_mode()

    if sw_pos == last_sw_pos then return update, RUN_INTERVAL_MS end
 
    -- prevent changing of the SID_AXIS while in SystemID mode
    if current_mode == COPTER_MODE_SYSTEMID then
        gcs_msg(MAV_SEVERITY_ERROR, 'Cannot change SID_AXIS in SystemID Mode')
        return update, RUN_INTERVAL_MS
    end
 
    if sw_pos == 0 then
        param:set('SID_AXIS',AXIS_LOW)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s', AXIS_LOW))
    end

    if sw_pos == 1 then
        param:set('SID_AXIS',AXIS_MID)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s', AXIS_MID))
    end

    if sw_pos == 2 then
        param:set('SID_AXIS',AXIS_HIGH)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s', AXIS_HIGH))
    end

    last_sw_pos = sw_pos

    return update, RUN_INTERVAL_MS
end

gcs_msg(MAV_SEVERITY_INFO, 'Initialized.')

return update()
