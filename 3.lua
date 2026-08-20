local function DisableHawkEye()
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local hawkEye = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
            if hawkEye then
                hawkEye.IsDuringHawkEyePatrol = function() return false end
                if hawkEye._nInitializeTimerID then
                    Game:ClearTimer(hawkEye._nInitializeTimerID)
                end
                hawkEye.ReportCheat = function() end
                hawkEye.SendReportTLog = function() end
                hawkEye._OnHawkSync = function() end
                hawkEye._OnHawkReportSuccess = function() end
                hawkEye._InitHawkEyePatrolSubsystem = function() end
            end
        end
    end)
end

--Disable HawkEye after 6 seconds (to ensure system is loaded)
later(6, DisableHawkEye)
