-- THIS FILE IS EXTRACTED BY @ OFFICIAL_NADEEM896211 TOOL
-- JOIN OVER TELEGRAM CHANNEL @ASSET_FINDER

local AntiCheat = {}

-- ============================================
-- 反举报系统
-- ============================================
local function InitializeAntiReport()
    pcall(function()
        local reportPaths = {
            "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem",
            "Client.Security.ClientReportPlayerSubsystem"
        }
        
        for _, path in ipairs(reportPaths) do
            local module = package.loaded[path] or (pcall(require, path) and require(path))
            if module then
                module.OnInit = function() end
                module._OnPlayerKilledOtherPlayer = function() end
                module._RecordFatalDamager = function() end
                module._OnDeathReplayDataWhenFatalDamaged = function() end
                module._RecordMurdererFromDeathReplayData = function() end
                module._RecordTeammatePlayerInfo = function() end
                module._OnBattleResult = function() end
                module._OnShowQuickReportMutualExclusiveUI = function() end
                module.GetFatalDamagerMap = function() return {} end
                module.GetCachedTeammateName2InfoMap = function() return {} end
                module.GetTeammateName2InfoMapDuringBattle = function() return {} end
                module.GetCurrentNotInTeamHistoricalTeammateMap = function() return {} end
                module.GetInTeamIndexFromHistoricalTeammateInfo = function() return -1 end
            end
        end
    end)

    pcall(function()
        local dsPaths = {
            "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem",
            "GameLua.Mod.BaseMod.Client.Security.DSReportPlayerSubsystem"
        }
        
        for _, path in ipairs(dsPaths) do
            local module = package.loaded[path] or (pcall(require, path) and require(path))
            if module then
                module.OnInit = function() end
                module._OnNearDeathOrRescued = function() end
                module._OnCharacterDied = function() end
                module._OnTeammateDamage = function() end
                module._OnPlayerSettlementStart = function() end
                module._AddKnockDownerToBattleResult = function() end
                module._AddKillerToBattleResult = function() end
                module._AddTeammateMurderToBattleResult = function() end
                module._AddFatalDamagerMapToBattleResult = function() end
                module._AddMLKillerUIDToBattleResult = function() end
                module._SaveHistoricalTeammateInfo = function() end
                module._RecordFatalDamager = function() end
                module._RecordTeammateMurderer = function() end
            end
        end
    end)

    pcall(function()
        local ReportPlayerUtils = require("GameLua.Mod.BaseMod.Common.Security.ReportPlayerUtils")
        if ReportPlayerUtils then
            ReportPlayerUtils.RecordFatalDamager = function() end
            ReportPlayerUtils.IsUsingHistoricalTeammateInfo = function() return false end
            ReportPlayerUtils.IsCharacterDeliverAI = function() return false end
        end
    end)

    pcall(function()
        local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
        if SecurityCommonUtils then
            SecurityCommonUtils.ExtractPlayerBasicInfo = function() return {} end
            SecurityCommonUtils.LogIf = function() return false end
        end
    end)

    pcall(function()
        local ClientQuickReportMaliciousTeammate = require("GameLua.Mod.BaseMod.Client.Security.ClientQuickReportMaliciousTeammate")
        if ClientQuickReportMaliciousTeammate then
            ClientQuickReportMaliciousTeammate.OnShowMutualExclusiveUI = function() end
            ClientQuickReportMaliciousTeammate.OnHideMutualExclusiveUI = function() end
        end
    end)
end

-- ============================================
-- 反截图/反日志系统
-- ============================================
local function InitializeLogBlocker()
    pcall(function()
        local ScreenshotMaker = import("ScreenshotMaker")
        if ScreenshotMaker then
            ScreenshotMaker.MakePicture = function() return "" end
            ScreenshotMaker.ReMakePicture = function() return "" end
            ScreenshotMaker.HasCaptured = function() return true end
        end
    end)

    pcall(function()
        local TLog = _G.TLog or package.loaded["TLog"]
        if TLog then
            TLog.Info = function() end
            TLog.Warning = function() end
            TLog.Error = function() end
            TLog.Debug = function() end
            TLog.Report = function() end
        end
    end)

    pcall(function()
        local CrashSight = _G.CrashSight or package.loaded["CrashSight"]
        if CrashSight then
            CrashSight.ReportException = function() end
            CrashSight.SetCustomData = function() end
            CrashSight.Log = function() end
        end
    end)

    pcall(function()
        local GameReportUtils = require("GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils")
        if GameReportUtils then
            GameReportUtils.BugglyPostExceptionFull = function() return false end
            GameReportUtils.CheckCanBugglyPostException = function() return false end
            GameReportUtils.ReplayReportData = function() end
            GameReportUtils.ReportGameException = function() end
        end
    end)

    pcall(function()
        local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
        if tlog_report_utils then
            tlog_report_utils.ReportTLogEvent = function() end
        end
    end)
end

-- ============================================
-- 反检测扫描器
-- ============================================
local function InitializeScannerBlocker()
    pcall(function()
        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        
        local AFKReportorSubsystem = SubsystemMgr and SubsystemMgr:Get("AFKReportorSubsystem")
        if AFKReportorSubsystem then
            AFKReportorSubsystem.PlayerHaveAction = function() end
            AFKReportorSubsystem.ReportAFK = function() end
        end
        
        local clientDataStatistcsSubsystem = SubsystemMgr and SubsystemMgr:Get("ClientDataStatistcsSubsystem")
        if clientDataStatistcsSubsystem then
            clientDataStatistcsSubsystem.StartToCheck = function() end
            clientDataStatistcsSubsystem.DelayCount = 0
            if clientDataStatistcsSubsystem.ReportPingDelayTimer then
                clientDataStatistcsSubsystem:RemoveGameTimer(clientDataStatistcsSubsystem.ReportPingDelayTimer)
                clientDataStatistcsSubsystem.ReportPingDelayTimer = nil
            end
        end
        
        local avatarExceptionSubsystem = SubsystemMgr and SubsystemMgr:Get("AvatarExceptionSubsystem")
        if avatarExceptionSubsystem then
            avatarExceptionSubsystem.ReportException = function() end
            avatarExceptionSubsystem.BindPlayerCharacter = function() end
            avatarExceptionSubsystem.CheckAvatarValid = function() return true end
        end
        
        local shootVerifySubSystemClient = SubsystemMgr and SubsystemMgr:Get("ShootVerifySubSystemClient")
        if shootVerifySubSystemClient then
            shootVerifySubSystemClient.ReportVerifyFail = function() end
            shootVerifySubSystemClient.OnVerifyFailed = function() end
        end
    end)

    pcall(function()
        local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
        if CreativeModeBlueprintLibrary then
            CreativeModeBlueprintLibrary.MD5HashByteArray = function() return "BYPASSED_MD5_HASH" end
            CreativeModeBlueprintLibrary.GetContentDiffData = function() return true, "BYPASSED" end
        end
    end)

    pcall(function()
        local AvatarExceptionPlayerInst = require("GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst")
        if AvatarExceptionPlayerInst then
            AvatarExceptionPlayerInst.CheckAvatarException = function() end
            AvatarExceptionPlayerInst.CheckAvatarExceptionOnce = function() end
            AvatarExceptionPlayerInst.ReportAvatarException = function() end
            AvatarExceptionPlayerInst.CheckSlotMeshVisible = function() return false end
            AvatarExceptionPlayerInst.CheckPawnVisible = function() return false end
            AvatarExceptionPlayerInst.CheckCanBugglyPostException = function() return false end
        end
    end)

    pcall(function()
        local TssSdk = _G.TssSdk or package.loaded["TssSdk"]
        if TssSdk then
            local onRecvData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data)
                if type(data) == "string" and (string.find(data, "report") or string.find(data, "exception")) then
                    return
                end
                if onRecvData then onRecvData(data) end
            end
            TssSdk.SendReportInfo = function() end
            TssSdk.ScanMemory = function() return true end
            TssSdk.IsEmulator = function() return false end
            TssSdk.GetTssSdkReportInfo = function() return "" end
        end
    end)
end

-- ============================================
-- 禁用HiggsBoson检测
-- ============================================
local function DisableHiggsBoson()
    pcall(function()
        local playerController = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if playerController and slua.isValid(playerController) then
            if playerController.HiggsBoson then
                playerController.HiggsBoson.bMHActive = false
                playerController.HiggsBoson.bCallPreReplication = false
            end
            if playerController.HiggsBosonComponent then
                playerController.HiggsBosonComponent.bMHActive = false
                playerController.HiggsBosonComponent:ControlMHActive(0)
            end
        end
    end)

    pcall(function()
        local HiggsBosonComponent = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HiggsBosonComponent and HiggsBosonComponent.StaticShowSecurityAlertInDev then
            HiggsBosonComponent.StaticShowSecurityAlertInDev = function() end
        end
    end)
end

-- ============================================
-- 游戏回调绕过
-- ============================================
local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks or _G.GameplayCallbacks.IsBypassed then
            return
        end
        
        local GC = _G.GameplayCallbacks
        local function nop() end
        local function emptyTable() return {} end
        
        GC.ReportAttackFlow = nop
        GC.ReportSecAttackFlow = nop
        GC.ReportHurtFlow = nop
        GC.ReportFireArms = nop
        GC.ReportVerifyInfoFlow = nop
        GC.ReportMrpcsFlow = nop
        GC.ReportPlayerBehavior = nop
        GC.ReportTeammatHurt = nop
        GC.ReportMisKillByTeammate = nop
        GC.ReportForbitPick = nop
        GC.ReportPlayerMoveRoute = nop
        GC.ReportPlayerPosition = nop
        GC.ReportVehicleMoveFlow = nop
        GC.ReportSecTgameMovingFlow = nop
        GC.ReportParachuteData = nop
        GC.SendTssSdkAntiDataToLobby = nop
        GC.SendDSErrorLogToLobby = nop
        GC.SendDSHawkEyePatrolLogToLobby = nop
        GC.ReportEquipmentFlow = nop
        GC.ReportAimFlow = nop
        GC.GetWeaponReport = emptyTable
        GC.GetOneWeaponReport = emptyTable
        GC.ReportPlayersPing = nop
        GC.ReportPlayerIP = nop
        GC.ReportCircleFlow = nop
        GC.ReportDSCircleFlow = nop
        GC.ReportJumpFlow = nop
        GC.SendSecTLog = nop
    end)
end

-- ============================================
-- 网络包拦截
-- ============================================
local function InitializePacketBlocker()
    pcall(function()
        if NetUtil and NetUtil.SendPacket and not NetUtil.IsBypassed then
            local sendPacket = NetUtil.SendPacket
            local blockedPackets = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportHurtFlow"]=1,
                ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportTeammateKillConfirmFlow"]=1,
                ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
                ["ReportSecTgameMovingFlow"]=1, ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1,
                ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["ReportJumpFlow"]=1,
                ["report_players_ping"]=1, ["report_player_ip"]=1, ["send_ugc_report_uni_mod_expose_req"]=1,
                ["send_ugc_report_uni_mod_interactive_req"]=1
            }
            
            NetUtil.SendPacket = function(packetName, ...)
                if blockedPackets[packetName] then return end
                return sendPacket(packetName, ...)
            end
            NetUtil.IsBypassed = true
        end
    end)
end

-- ============================================
-- 初始化所有反作弊
-- ============================================
local function InitializeAll()
    print("[AntiCheat] 正在初始化反作弊绕过系统...")
    
    InitializeAntiReport()
    InitializeLogBlocker()
    InitializeScannerBlocker()
    DisableHiggsBoson()
    InitializeGameplayBypass()
    InitializePacketBlocker()
    
    print("[AntiCheat] 反作弊绕过系统已激活！")
end

InitializeAll()

TssHostInfo="asia.csoversea.mbgame.anticheatexpert.com"
TssBuildInIpInfo="150.109.0.38,150.109.29.150,150.109.0.45,119.28.121.174"
TssCDNHostInfo="dl.listdl.com"
TssLocal=10
InitializeAll()