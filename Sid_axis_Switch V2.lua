-- This is a way to switch SID_AXIS based on the position of Aux1.  
-- SystemID paramenters should be set up before using this script.  
-- I've added some text.

local SCRIPT_NAME     = 'SID_AXIS_Switch'
local RUN_INTERVAL_MS = 1000
local RC_OPTION       = 300 -- Set up a 3-pos switch for Scripting1

-- User to set the specific axis and magnitutde for each switch postion.
local AXIS_LOW        = 4
local MAGNITUDE_LOW   = 5

local AXIS_MID        = 5
local MAGNITUDE_MID   = 5

local AXIS_HIGH       = 6
local MAGNITUDE_HIGH  = 5

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
        param:set('SID_MAGNITUDE',MAGNITUDE_LOW)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s, Mag %s', AXIS_LOW, MAGNITUDE_LOW))
    end

    if sw_pos == 1 then
        param:set('SID_AXIS',AXIS_MID)
        param:set('SID_MAGNITUDE',MAGNITUDE_MID)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s, Mag %s', AXIS_MID, MAGNITUDE_MID))
    end

    if sw_pos == 2 then
        param:set('SID_AXIS',AXIS_HIGH)
        param:set('SID_MAGNITUDE',MAGNITUDE_HIGH)
        gcs_msg(MAV_SEVERITY_INFO, string.format('Set Axis %s, Mag %s', AXIS_HIGH, MAGNITUDE_HIGH))
    end

    last_sw_pos = sw_pos

    return update, RUN_INTERVAL_MS
end

gcs_msg(MAV_SEVERITY_INFO, 'Initialized.')

return update()
