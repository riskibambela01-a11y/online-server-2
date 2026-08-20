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

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

do
    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if _G._WALLHACK_LOADED and _G._WALLHACK_PC == pc then return end
    _G._WALLHACK_LOADED = true
    _G._WALLHACK_PC = pc
end

local CONFIG = {
    ENABLE_INNER_GLOW = 0,
    MASK_R = 255,
    MASK_G = 0,
    MASK_B = 0,
    MASK_A = 255,
    BRIGHTNESS = 4,
    CHAR_SCALE = 0,
    ENEMY_SCALE = 0,
    WALL_CLIMB = 0,
    SPEED_HACK = 1.1,
}

local scaledEnemies = {}
local lastBrightness = 4
local lastScale = 0
local lastEnemyScale = 0
local lastWallClimb = 0
local lastSpeedHack = 0

local function LoadConfig()
    local configPath = nil
    local paths = {
        "/storage/emulated/0/Android/data/com.tencent.ig/小小优.U5.七夕.h",
        "/storage/emulated/0/Android/data/com.rekoo.pubgm/小小优.U5.七夕.h",
        "/storage/emulated/0/Android/data/com.pubg.krmobile/小小优.U5.七夕.h",
        "/storage/emulated/0/Android/data/com.vng.pubgmobile/小小优.U5.七夕.h",
    }
    for _, path in ipairs(paths) do
        local f = io.open(path, "r")
        if f then
            configPath = path
            f:close()
            break
        end
    end
    if not configPath then return end
    local file = io.open(configPath, "r")
    if not file then return end
    for line in file:lines() do
        if line then
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" and not trimmed:match("^#") then
                local key, value = trimmed:match("^([^=]+)%s*=%s*(.+)$")
                if key and value then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    local numValue = tonumber(value)
                    if key == "人物内透" then
                        CONFIG.ENABLE_INNER_GLOW = numValue or 0
                    elseif key == "不可见R" then
                        CONFIG.MASK_R = numValue or 255
                    elseif key == "不可见G" then
                        CONFIG.MASK_G = numValue or 0
                    elseif key == "不可见B" then
                        CONFIG.MASK_B = numValue or 0
                    elseif key == "不可见A" then
                        CONFIG.MASK_A = numValue or 255
                    elseif key == "人物亮度" then
                        CONFIG.BRIGHTNESS = numValue or 4
                    elseif key == "自己大小" then
                        CONFIG.CHAR_SCALE = numValue or 0
                    elseif key == "敌人大小" then
                        CONFIG.ENEMY_SCALE = numValue or 0
                    elseif key == "人物爬墙" then
                        CONFIG.WALL_CLIMB = numValue or 0
                    elseif key == "内存加速" then
                        CONFIG.SPEED_HACK = numValue or 0
                    end
                end
            end
        end
    end
    file:close()
end

local function GetGameInstance()
    local gi = nil
    pcall(function()
        if GameplayData.GetGameInstance then
            gi = GameplayData.GetGameInstance()
        end
        if not gi then
            local SettingUtil = require("client.slua.logic.setting.setting_util")
            gi = SettingUtil.GetGameInstance()
        end
    end)
    return gi
end

local bypassDone = false
local function InitAntiCheatBypass()
    if bypassDone then return end
    bypassDone = true
    
    pcall(function()
        local nop = function() end
        local GameplayCallbacks = _G.GameplayCallbacks or _G.GC
        if GameplayCallbacks then
            GameplayCallbacks.SendTssSdkAntiDataToLobby = nop
            GameplayCallbacks.SendDSErrorLogToLobby = nop
            GameplayCallbacks.SendDSHawkEyePatrolLogToLobby = nop
            GameplayCallbacks.SendSecTLog = nop
        end

        local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubsystemMgr then
            local DSHawkEyeSub = SubsystemMgr.Get("DSHawkEyePatrolSubsystem")
            if DSHawkEyeSub then DSHawkEyeSub.MarkSuspiciousPlayer = nop end
        end

        pcall(function()
            local HiggsComponent = package.loaded["GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent"]
            if HiggsComponent then
                HiggsComponent.ControlMHActive = nop
                HiggsComponent.Tick = nop
                HiggsComponent.TriggerAvatarCheck = nop
            end
        end)
    end)
end

local function ModifyCharacterScale(scale)
    if not scale or scale <= 0 then return end
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        local stMesh = player:GetComponentByClass(import("STCharacterMeshComponent"))
        if slua.isValid(stMesh) then
            stMesh:SetRelativeScale3D(FVector(scale, scale, scale))
            return
        end
        local mesh = player:GetMesh()
        if slua.isValid(mesh) then
            mesh:SetRelativeScale3D(FVector(scale, scale, scale))
        end
    end)
end

local function ModifyEnemyScale(scale)
    if not scale or scale <= 0 then return end
    pcall(function()
        local myPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(myPlayer) then return end
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        for _, tPawn in pairs(allPawns) do
            if slua.isValid(tPawn) and tPawn ~= myPlayer and tPawn.TeamID ~= myPlayer.TeamID then
                if not scaledEnemies[tPawn] then
                    local stMesh = tPawn:GetComponentByClass(import("STCharacterMeshComponent"))
                    if slua.isValid(stMesh) then
                        stMesh:SetRelativeScale3D(FVector(scale, scale, scale))
                        scaledEnemies[tPawn] = true
                    end
                    local mesh = tPawn:GetMesh()
                    if slua.isValid(mesh) then
                        mesh:SetRelativeScale3D(FVector(scale, scale, scale))
                        scaledEnemies[tPawn] = true
                    end
                end
            end
        end
    end)
end

local function EnableWallClimb()
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if slua.isValid(player) then
            local charMove = player.CharacterMovement or player.CharMoveComp
            if slua.isValid(charMove) then
                charMove.WalkableFloorAngle = 199.0
                charMove.MaxStepHeight = 999.0
            end
        end
    end)
end

local function ApplyBrightness()
    local gi = GetGameInstance()
    if gi then
        gi:ExecuteCMD("r.CharacterMinShadowFactor", tostring(CONFIG.BRIGHTNESS))
        gi:ExecuteCMD("r.CharacterDiffuseOffset", "500")
        gi:ExecuteCMD("r.CharacterDiffusePower", "500")
    end
end

local function SpeedHack()
    if CONFIG.SPEED_HACK <= 0 then
        return
    end
    
    pcall(function()
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local controller = player:GetPlayerControllerSafety()
        if slua.isValid(controller) then
            local pawn = controller.AcknowledgedPawn
            if slua.isValid(pawn) then
                pawn.CustomTimeDilation = CONFIG.SPEED_HACK
            end
        end
    end)
end

local ESP_Active = false

local function Valid(obj)
    return slua.isValid(obj)
end

local function ApplyVisualMods(localPlayer, enemy, pc)
    if not ESP_Active then return end
    if not Valid(enemy) then return end
    
    local meshes = {}
    pcall(function()
        if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
        local SkelClass = import("SkeletalMeshComponent")
        if SkelClass then
            local childs = enemy:GetComponentsByClass(SkelClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for c = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(c-1) or childs[c]
                    if Valid(comp) and comp ~= enemy.Mesh then table.insert(meshes, comp) end
                end
            end
        end
    end)
    
    pcall(function()
        for _, comp in ipairs(meshes) do
            if Valid(comp) then
                comp.UseScopeDistanceCulling = false 
                comp.PrimitiveShadingStrategy = 1
                comp.ShadingRate = 6
                
                for i = 0, 10 do
                    local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                    if not s or not Valid(matInterface) then break end
                    local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                    if s2 and Valid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                end
            end
        end

        local r = CONFIG.MASK_R
        local g = CONFIG.MASK_G
        local b = CONFIG.MASK_B
        local a = CONFIG.MASK_A
        
        r = math.min(255, math.max(0, r))
        g = math.min(255, math.max(0, g))
        b = math.min(255, math.max(0, b))
        a = math.min(255, math.max(0, a))
        
        local finalColor = { R = r, G = g, B = b, A = a, r = r, g = g, b = b, a = a }
        local scale = { R = 3.0, G = 3.0, B = 0.0, A = 0.0, r = 3.0, g = 3.0, b = 0.0, a = 0.0 }
        
        enemy.WH_MIDs = enemy.WH_MIDs or {}
        local stateChanged = (enemy.WH_LastColorR ~= finalColor.R or enemy.WH_LastColorG ~= finalColor.G or enemy.WH_LastColorB ~= finalColor.B)
        
        for _, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = tostring(comp)
                enemy.WH_MIDs[compKey] = enemy.WH_MIDs[compKey] or {}
                for i = 0, 10 do 
                    local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                    if not s or not Valid(matInterface) then break end
                    local currentCached = enemy.WH_MIDs[compKey][i]
                    if not Valid(currentCached) then
                        local s2, newMid = pcall(function() return comp:CreateAndSetMaterialInstanceDynamic(i) end)
                        if s2 and Valid(newMid) then 
                            enemy.WH_MIDs[compKey][i] = newMid
                            currentCached = newMid
                        end
                    end
                    if Valid(currentCached) then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", finalColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", finalColor)
                            currentCached:SetVectorParameterValue("Para_Color", finalColor)
                            currentCached:SetVectorParameterValue("Para_ColorTint", finalColor)
                            currentCached:SetVectorParameterValue("Para_Color_1", finalColor)
                            currentCached:SetVectorParameterValue("Tint", finalColor)
                            currentCached:SetVectorParameterValue("Color", finalColor)
                            currentCached:SetVectorParameterValue("BaseColor", finalColor)
                            currentCached:SetVectorParameterValue("BodyColor", finalColor)
                            currentCached:SetVectorParameterValue("MainColor", finalColor)
                            currentCached:SetVectorParameterValue("DiffuseColor", finalColor)
                            currentCached:SetVectorParameterValue("EmissiveColor", finalColor)
                            currentCached:SetVectorParameterValue("CustomColor", finalColor)
                            currentCached:SetVectorParameterValue("OverlayColor", finalColor)
                            currentCached:SetVectorParameterValue("GlowColor", finalColor)
                            currentCached:SetVectorParameterValue("EdgeColor", finalColor)
                            currentCached:SetVectorParameterValue("LightColor", finalColor)
                            currentCached:SetVectorParameterValue("OutlineColor", finalColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            currentCached:SetScalarParameterValue("Opacity", 0.7)
                            currentCached:SetScalarParameterValue("Alpha", 0.7)
                            currentCached:SetScalarParameterValue("GlowIntensity", 1.0)
                            currentCached:SetScalarParameterValue("Intensity", 1.0)
                        end)
                    end
                end
            end
        end
        if stateChanged then 
            enemy.WH_LastColorR = finalColor.R
            enemy.WH_LastColorG = finalColor.G
            enemy.WH_LastColorB = finalColor.B
        end
    end)
end

local function MainTick()
    LoadConfig()
    
    if CONFIG.BRIGHTNESS ~= lastBrightness then
        lastBrightness = CONFIG.BRIGHTNESS
        ApplyBrightness()
    end
    
    if CONFIG.ENABLE_INNER_GLOW == 1 then
        ESP_Active = true
        local localPlayer = GameplayData.GetPlayerCharacter()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(localPlayer) and slua.isValid(pc) then
            local myTeamId = localPlayer.TeamID or 0
            local allPawns = Game:GetAllPlayerPawns() or {}
            for _, enemy in pairs(allPawns) do
                if slua.isValid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= myTeamId then
                    local isAlive = false
                    pcall(function() isAlive = enemy:IsAlive() end)
                    if isAlive then
                        ApplyVisualMods(localPlayer, enemy, pc)
                    end
                end
            end
        end
    else
        ESP_Active = false
    end
    
    if CONFIG.CHAR_SCALE ~= lastScale then
        lastScale = CONFIG.CHAR_SCALE
        ModifyCharacterScale(CONFIG.CHAR_SCALE)
    end
    
    if CONFIG.ENEMY_SCALE ~= lastEnemyScale then
        lastEnemyScale = CONFIG.ENEMY_SCALE
        scaledEnemies = {}
    end
    if CONFIG.ENEMY_SCALE > 0 then
        ModifyEnemyScale(CONFIG.ENEMY_SCALE)
    end
    
    if CONFIG.WALL_CLIMB ~= lastWallClimb then
        lastWallClimb = CONFIG.WALL_CLIMB
        if CONFIG.WALL_CLIMB == 1 then
            EnableWallClimb()
        end
    end
    
    if CONFIG.SPEED_HACK ~= lastSpeedHack then
        lastSpeedHack = CONFIG.SPEED_HACK
        if CONFIG.SPEED_HACK > 0 then
            SpeedHack()
        end
    end
end

local function InitAll()
    InitAntiCheatBypass()
end

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.HTY_MAIN_TIMER == tmr then return end
    _G.HTY_MAIN_TIMER = tmr
    
    InitAll()
    
    tmr:AddGameTimer(0.1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(0.28, true, MainTick)
        end
    end)
end)

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


local function GetHelmetSkinFromNMSL()
    local level = 1
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            local lib = import("STExtraBlueprintFunctionLibrary")
            local comp = lib.GetBackpackComponentFromController(pc)
            if slua.isValid(comp) then
                local utils = import("BackpackUtils")
                local armors = utils.GetEuqippedArmorInBackpack(comp)
                for _, armor in pairs(armors) do
                    local defineId = slua.IndexReference(armor, "DefineID")
                    local id = defineId.TypeSpecificID
                    local d = CDataTable.GetTableData("Item", id)
                    if d and d.ItemSubType == 502 then  

                        level = utils.GetEquipmentHelmetLevel(id) or 1
                        print("[ArmorSkin] 检测到头盔 ID=" .. tostring(id) .. " → 等级=" .. tostring(level))
                        break
                    end
                end
            end
        end
    end)

    local skins = {
        [1] = _G.Helmet1Skin or 0,
        [2] = _G.Helmet2Skin or 0,
        [3] = _G.Helmet3Skin or 0,
        [4] = _G.Helmet4Skin or 0,
        [5] = _G.Helmet5Skin or 0,
        [6] = _G.Helmet6Skin or 0,
    }
    local result = skins[level] or 0
    if result > 0 then
        print("[ArmorSkin] 头盔等级=" .. tostring(level) .. " → 使用皮肤ID=" .. tostring(result))
    else
        print("[ArmorSkin] 头盔等级=" .. tostring(level) .. " → 未配置皮肤，使用默认")
    end
    return result
end

local function GetBackpackSkinFromNMSL()
    local level = 1
    pcall(function()
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            local lib = import("STExtraBlueprintFunctionLibrary")
            local comp = lib.GetBackpackComponentFromController(pc)
            if slua.isValid(comp) then
                local utils = import("BackpackUtils")
                local armors = utils.GetEuqippedArmorInBackpack(comp)
                for _, armor in pairs(armors) do
                    local defineId = slua.IndexReference(armor, "DefineID")
                    local id = defineId.TypeSpecificID
                    local d = CDataTable.GetTableData("Item", id)
                    if d and d.ItemSubType == 501 then  

                        level = utils.GetEquipmentBagLevel(id) or 1
                        print("[ArmorSkin] 检测到背包 ID=" .. tostring(id) .. " → 等级=" .. tostring(level))
                        break
                    end
                end
            end
        end
    end)

    local skins = {
        [1] = _G.Backpack1Skin or 0,
        [2] = _G.Backpack2Skin or 0,
        [3] = _G.Backpack3Skin or 0,
        [4] = _G.Backpack4Skin or 0,
        [5] = _G.Backpack5Skin or 0,
        [6] = _G.Backpack6Skin or 0,
    }
    local result = skins[level] or 0
    if result > 0 then
        print("[ArmorSkin] 背包等级=" .. tostring(level) .. " → 使用皮肤ID=" .. tostring(result))
    else
        print("[ArmorSkin] 背包等级=" .. tostring(level) .. " → 未配置皮肤，使用默认")
    end
    return result
end

local E = UEnums.EBackpackClothArmorType
local SubType = { Helmet = 502, Bag = 501 }

_G._ArmorSkinConfig = {
    helmet = GetHelmetSkinFromNMSL,
    bag    = GetBackpackSkinFromNMSL,
}

local function GetSkinId(clothType)
    if clothType == E.Helmet then
        return GetHelmetSkinFromNMSL()
    end
    if clothType == E.Package then
        return GetBackpackSkinFromNMSL()
    end
    return 0
end

local function GetIcon(ItemID)
    if not ItemID or ItemID <= 0 then return nil end
    local d = CDataTable.GetTableData("Item", ItemID)
    if not d then
        return nil
    end
    if d.ItemSmallIcon and d.ItemSmallIcon ~= "" then return d.ItemSmallIcon end
    if d.ItemBigIcon and d.ItemBigIcon ~= "" then return d.ItemBigIcon end
    return nil
end

local function ForceSetIcon(widget, icon)
    if not icon or icon == "" then return false end
    if not widget or not slua.isValid(widget) or not widget.Image_EquipIcon then return false end
    local img = widget.Image_EquipIcon
    img:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    img:SetBrushFromPathAsync(icon, true)
    img:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    return true
end

local function ResetSlot(widget)
    if widget and slua.isValid(widget) and widget.ShowNull then
        widget:ShowNull()
    end
end

local function GetEquipped()
    local has = { [SubType.Helmet] = false, [SubType.Bag] = false }
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
    if not ui or not ui.UIRoot then return has end
    local lib = import("STExtraBlueprintFunctionLibrary")
    local utils = import("BackpackUtils")
    local pc = ui.UIRoot:GetOwningPlayer()
    if not slua.isValid(pc) then return has end
    local comp = lib.GetBackpackComponentFromController(pc)
    if not slua.isValid(comp) then return has end
    for _, armor in pairs(utils.GetEuqippedArmorInBackpack(comp)) do
        local id = slua.IndexReference(armor, "DefineID").TypeSpecificID
        local d = CDataTable.GetTableData("Item", id)
        if d and has[d.ItemSubType] ~= nil then
            has[d.ItemSubType] = true
            print("[ArmorSkin] 检测到装备: ItemSubType=" .. tostring(d.ItemSubType) .. " ID=" .. tostring(id))
        end
    end
    return has
end

local function ApplySlot(widget, clothType, equipped)
    if not equipped then
        ResetSlot(widget)
        return
    end
    local skinId = GetSkinId(clothType)
    if skinId and skinId > 0 then
        local icon = GetIcon(skinId)
        if icon then
            ForceSetIcon(widget, icon)
        else
            print("[ArmorSkin] 皮肤ID " .. tostring(skinId) .. " 无图标")
        end
    end
end

local function Apply()
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
    if not ui or not ui.UIRoot then return end
    local eq = GetEquipped()
    ApplySlot(ui.UIRoot.ArmorSlotItem_Helmet, E.Helmet, eq[SubType.Helmet])
    ApplySlot(ui.UIRoot.ArmorSlotItem_Package, E.Package, eq[SubType.Bag])
end

local function Refresh()
    Apply()
    local dc = _G._ArmorSkinDC
    if dc then
        dc:AddTimer(0.12, Apply)
        dc:AddTimer(0.25, Apply)
    end
end

if not _G._ArmorSkinHooked then
    local cls = require("GameLua.Mod.BaseMod.Client.Backpack.BackPackArmorSlotUI")
    local impl = cls.__inner_impl
    local oldShow = impl.ShowItemIcon
    impl.ShowItemIcon = function(self, ItemData, AvatarItemID)
        oldShow(self, ItemData, AvatarItemID)
        if ItemData and ItemData.DefineID and ItemData.DefineID.TypeSpecificID > 0 then
            local skinId = GetSkinId(self.ClothArmorType)
            if skinId and skinId > 0 then
                local icon = GetIcon(skinId)
                if icon then
                    ForceSetIcon(self, icon)
                end
            end
        end
    end
    _G._ArmorSkinHooked = true
end

if not _G._ArmorSkinDC then
    local dc = require("common.delegate_container")()
    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, function(_, __, open)
        if open then
            dc:AddTimer(0.05, Apply)
            dc:AddTimer(0.15, Apply)
        end
    end)
    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_UPDATE_ARMOR_SLOT, function()
        dc:AddTimer(0.05, Apply)
        dc:AddTimer(0.15, Apply)
    end)
    _G._ArmorSkinDC = dc
end

Refresh()
print("[ArmorSkin] 已初始化（从 nmsl.h 读取配置）")

local function GetOutfitSkinFromNMSL(slotName)
    local map = {
        Cap       = "_G.HatSkin",
        Mask      = "_G.MaskSkin",
        Jacket    = "_G.SuitSkin",
        Trouser   = "_G.PantSkin",
        Shoe      = "_G.ShoeSkin",
        Glasses   = "_G.FaceSkin",
        Gloves    = "_G.GlovesSkin",
        Parachute = "_G.ParachuteSkin",
        Glider    = "_G.GliderSkin",
        Aircraft  = "_G.AircraftSkin",
        Guns      = "_G.GunSkin",
    }
    local varName = map[slotName]
    if varName then
        return loadstring("return " .. varName)() or 0
    end
    return 0
end

local function GetHelmetSkinByLevel()
    return GetHelmetSkinFromNMSL()
end

local function GetBackpackSkinByLevel()
    return GetBackpackSkinFromNMSL()
end

local E = UEnums.EBackpackClothArmorType

local SLOT_MAP = {
    Cap       = E.Cap,
    Mask      = E.Mask,
    Jacket    = E.Jacket,
    Trouser   = E.Trouser,
    Shoe      = E.Shoe,
    Glasses   = E.Glasses,
    Gloves    = E.Gloves,
    Parachute = E.Parachute,
    Aircraft  = E.Aircraft,
    Helmet    = E.Helmet,
    Package   = E.Package,
    Guns      = E.Guns,
    Glider    = E.Glider,
}

local function GetSkinIdFromNMSL(clothType)
    if clothType == E.Helmet then
        return GetHelmetSkinByLevel()
    end
    if clothType == E.Package then
        return GetBackpackSkinByLevel()
    end

    local nameMap = {
        [E.Cap]       = "HatSkin",
        [E.Mask]      = "MaskSkin",
        [E.Jacket]    = "SuitSkin",
        [E.Trouser]   = "PantSkin",
        [E.Shoe]      = "ShoeSkin",
        [E.Glasses]   = "FaceSkin",
        [E.Gloves]    = "GlovesSkin",
        [E.Parachute] = "ParachuteSkin",
        [E.Glider]    = "GliderSkin",
        [E.Aircraft]  = "AircraftSkin",
        [E.Guns]      = "GunSkin",
    }
    local varName = nameMap[clothType]
    if varName then
        return _G[varName] or 0
    end
    return 0
end

local function GetIconWithQuality(ItemID)
    if not ItemID or ItemID <= 0 then
        return nil, 0
    end
    local d = CDataTable.GetTableData("Item", ItemID)
    if not d then
        return nil, 0
    end
    local icon = (d.ItemSmallIcon and d.ItemSmallIcon ~= "") and d.ItemSmallIcon or d.ItemBigIcon
    if not icon or icon == "" then
        return nil, d.ItemQuality or 0
    end
    return icon, d.ItemQuality or 0, d.SpecialIcon or ""
end

local function ForceShowClothById(slotUI, ItemID)
    if not slotUI or not slotUI.UIRoot or not slua.isValid(slotUI.UIRoot) then
        return false
    end
    local icon, quality, specialIcon = GetIconWithQuality(ItemID)
    if not icon then
        return false
    end
    local root = slotUI.UIRoot
    root.Image_ClothingItemIcon:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
    root.Image_ClothingItemIcon:SetBrushFromPathAsync(icon, false)
    root.Image_UnDownload:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    root.Canvas_Clothingmask:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if slotUI.Image_0 then
        slotUI.Image_0:SetWidgetVisibility(UEnums.ESlateVisibility.Hidden)
    end
    if slotUI.CanvasPanel_1 then
        slotUI.CanvasPanel_1:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    if slotUI.UpdateSpecialIcon and specialIcon then
        slotUI:UpdateSpecialIcon(specialIcon)
    end
    if slotUI.SetQuality and slotUI.Image_Icon_Quality_Bottom and slotUI.Image_Quality_Bg then
        slotUI:SetQuality(quality, slotUI.Image_Icon_Quality_Bottom, slotUI.Image_Quality_Bg)
    end
    slotUI.IsDataNull = false
    return true
end

local function ApplySlotOverride(slotUI)
    if not slotUI or not slotUI.ClothArmorType then
        return
    end
    local itemId = GetSkinIdFromNMSL(slotUI.ClothArmorType)
    if itemId and itemId > 0 then
        ForceShowClothById(slotUI, itemId)
    end
end

local function ApplyClothingUI(clothingUI)
    if not clothingUI then
        return
    end
    for _, slot in ipairs(clothingUI.ClothPlotItemArray or {}) do
        ApplySlotOverride(slot)
    end
    for _, slot in ipairs(clothingUI.SpecialClothPlotItemArray or {}) do
        ApplySlotOverride(slot)
    end
    for _, slot in ipairs(clothingUI.SpecialClothCoutPlotItemArray or {}) do
        ApplySlotOverride(slot)
    end
end

local function ApplyAllPanels()
    local ui = UIManager.GetUI(UIManager.UI_Config_InGame.BackPackPanelUI)
    if not ui or not ui.BackpackClothPanel then
        return
    end
    local panel = ui.BackpackClothPanel
    for _, clothingUI in ipairs(panel.RolewearPanelArray or {}) do
        ApplyClothingUI(clothingUI)
    end
end

local function RefreshPanels(delayList)
    ApplyAllPanels()
    local dc = _G._OutfitCustomDC
    if dc and delayList then
        for _, t in ipairs(delayList) do
            dc:AddTimer(t, ApplyAllPanels)
        end
    end
end

function _G.RefreshOutfitFromNMSL()
    RefreshPanels({0.05, 0.15, 0.30})
    Apply()
    print("[OutfitCustom] 已从 nmsl.h 刷新")
end

if not _G._OutfitCustomHooked then
    local cls = require("GameLua.Mod.BaseMod.Client.Backpack.Clothing.BackpackClothSlotUI")
    local impl = cls.__inner_impl

    local oldShow = impl.ShowClothIcon
    impl.ShowClothIcon = function(self, ItemData)
        oldShow(self, ItemData)
        local itemId = GetSkinIdFromNMSL(self.ClothArmorType)
        if itemId and itemId > 0 then
            ForceShowClothById(self, itemId)
        end
    end

    local oldShared = impl.ShowClothIconSharedSkin
    impl.ShowClothIconSharedSkin = function(self, data)
        oldShared(self, data)
        local itemId = GetSkinIdFromNMSL(self.ClothArmorType)
        if itemId and itemId > 0 then
            ForceShowClothById(self, itemId)
        end
    end

    local oldNull = impl.ShowNull
    impl.ShowNull = function(self)
        local itemId = GetSkinIdFromNMSL(self.ClothArmorType)
        if itemId and itemId > 0 then
            ForceShowClothById(self, itemId)
            return
        end
        oldNull(self)
    end

    local clsUI = require("GameLua.Mod.BaseMod.Client.Backpack.Clothing.BackpackClothingUI")
    local implUI = clsUI.__inner_impl

    local oldUpdateCloth = implUI.UpdateCloth
    implUI.UpdateCloth = function(self, BattleItemData)
        oldUpdateCloth(self, BattleItemData)
        ApplyClothingUI(self)
    end

    local oldUpdateSpecial = implUI.UpdateSpecialCloth
    implUI.UpdateSpecialCloth = function(self, BattleItemData)
        oldUpdateSpecial(self, BattleItemData)
        ApplyClothingUI(self)
    end

    local oldUpdateCount = implUI.UpdateSpecialClothCount
    implUI.UpdateSpecialClothCount = function(self, ItemCount)
        oldUpdateCount(self, ItemCount)
        ApplyClothingUI(self)
    end

    _G._OutfitCustomHooked = true
end

if not _G._OutfitCustomDC then
    local dc = require("common.delegate_container")()

    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_CHANGE_STATE, function(_, __, open)
        if open then
            RefreshPanels({0.05, 0.20, 0.40})
        end
    end)

    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_SHOWHIDE_BACKPACK_PANEL, function()
        RefreshPanels({0.05, 0.20, 0.40})
    end)

    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_NOTIFY_PARENT_SWITCHTAB, function(_, __, tab)
        if tab == UEnums.EBackpackTab.AvatarItem then
            RefreshPanels({0.05, 0.20, 0.40, 0.60})
        end
    end)

    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, function()
        RefreshPanels({0.05, 0.20})
    end)

    dc:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_INGAME_UPDATE_CLOTHES_TIMES, function()
        RefreshPanels({0.05, 0.20})
    end)

    _G._OutfitCustomDC = dc
end

local function InitFromNMSL()
    local configs = {
        SuitSkin = _G.SuitSkin or 0,
        HatSkin = _G.HatSkin or 0,
        FaceSkin = _G.FaceSkin or 0,
        MaskSkin = _G.MaskSkin or 0,
        GlovesSkin = _G.GlovesSkin or 0,
        PantSkin = _G.PantSkin or 0,
        ShoeSkin = _G.ShoeSkin or 0,
        ParachuteSkin = _G.ParachuteSkin or 0,
        GliderSkin = _G.GliderSkin or 0,
        Helmet1Skin = _G.Helmet1Skin or 0,
        Backpack1Skin = _G.Backpack1Skin or 0,
    }

    local active = {}
    for name, id in pairs(configs) do
        if id and id > 0 then
            table.insert(active, name .. "=" .. tostring(id))
        end
    end

    if #active == 0 then
        print("[OutfitCustom] 从 nmsl.h 读取完成 — 暂无皮肤配置")
    else
        print("[OutfitCustom] 从 nmsl.h 读取完成 — " .. table.concat(active, ", "))
    end

    RefreshPanels({0.05, 0.15, 0.30})
    Apply()
end

if _G.Mytimer_ticker then
    _G.Mytimer_ticker.AddTimer(0.5, InitFromNMSL)
    _G.Mytimer_ticker.AddTimer(1.0, InitFromNMSL)
    _G.Mytimer_ticker.AddTimer(2.0, InitFromNMSL)

    _G.Mytimer_ticker.AddTimerLoop(2.0, function()
        pcall(function()
            Apply()
            ApplyAllPanels()
        end)
    end, -1, 1)
else
    InitFromNMSL()
end

print("[OutfitCustom] 已加载（皮肤从 nmsl.h 动态读取）")

local MortarAim = {}

MortarAim.Config = {
	AimInterval = 0.03,
	MaxRange = 600.0,
	FOV = 40.0,
	BaseGravity = 980.0,
	SwipeBreakAngle = 3.5,
	PitchWeight = 0.3
}

local GameplayData
local gameplayDataReady = false
local lockedTarget
local lastAimRotation
local aimActive = false
local started = false

local function notify(message)
	local fn = rawget(_G, "Weow") or rawget(_G, "Weow_log")
	if type(fn) == "function" then
		pcall(fn, "[Weow] " .. tostring(message))
	end
end

local function valid(value)
	if value == nil then
		return false
	end
	local slua = rawget(_G, "slua")
	if slua and type(slua.isValid) == "function" then
		local ok, result = pcall(slua.isValid, value)
		return ok and result == true
	end
	return true
end

local function ensure_gameplay_data()
	if gameplayDataReady and GameplayData then
		return true
	end
	local ok, module = pcall(require, "GameLua.GameCore.Data.GameplayData")
	if ok and module then
		GameplayData = module
	end
	gameplayDataReady = GameplayData ~= nil
	return gameplayDataReady
end

local function normalize_angle(angle)
	while angle > 180.0 do
		angle = angle - 360.0
	end
	while angle < -180.0 do
		angle = angle + 360.0
	end
	return angle
end

local function atan2(y, x)
	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	elseif x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	elseif x == 0 and y > 0 then
		return math.pi / 2
	elseif x == 0 and y < 0 then
		return -math.pi / 2
	end
	return 0
end

local function get_player()
	return slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController() and slua_GameFrontendHUD:GetPlayerController():GetPlayerCharacterSafety()
end

local function get_controller()
	return slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
end

local function get_camera(controller)
	local camera
	pcall(function()
		camera = controller and controller.PlayerCameraManager
	end)
	return camera
end

local function get_location(actor)
	local location
	pcall(function()
		if actor and type(actor.K2_GetActorLocation) == "function" then
			location = actor:K2_GetActorLocation()
		end
	end)
	return location
end

local function get_weapon(player)
	local weapon
	pcall(function()
		weapon = player and player.CurrentWeapon
		if not weapon and player and type(player.GetCurrentWeapon) == "function" then
			weapon = player:GetCurrentWeapon()
		end
	end)
	return weapon
end

local function is_dead(actor)
	local result = false
	pcall(function()
		result = actor.bDead == true or actor.bIsDead == true or actor.bIsDeadFlag == true
	end)
	return result
end

local function team_value(actor)
	local value
	pcall(function()
		value = actor.TeamID
		if value == nil and actor.PlayerState then
			value = actor.PlayerState.TeamNum
		end
	end)
	return value
end

local function same_player_key(a, b)
	if not valid(a) or not valid(b) or a == b then
		return a == b
	end
	local ak, bk
	pcall(function() ak = a.PlayerKey end)
	pcall(function() bk = b.PlayerKey end)
	if ak ~= nil and bk ~= nil then
		return ak == bk
	end
	return false
end

local function is_enemy(local_actor, actor)
	if not valid(actor) or actor == local_actor or same_player_key(local_actor, actor) then
		return false
	end
	local local_team = team_value(local_actor)
	local actor_team = team_value(actor)
	if local_team ~= nil and actor_team ~= nil and local_team == actor_team then
		return false
	end
	return true
end

local function collect_characters()
	local result = {}
	local function add(list)
		if type(list) ~= "table" then
			return
		end
		for _, actor in pairs(list) do
			if valid(actor) then
				result[actor] = true
			end
		end
	end
	pcall(function()
		if GameplayData and type(GameplayData.GetAllPlayerCharacters) == "function" then
			add(GameplayData.GetAllPlayerCharacters())
		end
	end)
	pcall(function()
		if GameplayData and type(GameplayData.GetAllCharacters) == "function" then
			add(GameplayData.GetAllCharacters())
		end
	end)
	return result
end

local function solve_ballistic_pitch(horizontal, vertical, velocity, gravity)
	local velocity2 = velocity * velocity
	local velocity4 = velocity2 * velocity2
	local discriminant = velocity4 - gravity * gravity * horizontal * horizontal
		discriminant = discriminant - 2.0 * gravity * vertical * velocity2
	if discriminant < 0 then
		return 45.0
	end
	local root = math.sqrt(discriminant)
	local denominator = gravity * horizontal
	local angle = denominator == 0 and 90.0 or math.atan((velocity2 + root) / denominator) * (180.0 / math.pi)
	if angle < 45.0 then angle = 45.0 end
	if angle > 88.0 then angle = 88.0 end
	return angle
end

local function reverse_map_pitch(ballistic_pitch)
	local value = (ballistic_pitch - 45.0) * 2.0930232558139537 - 60.0
	if value < -60.0 then value = -60.0 end
	if value > 30.0 then value = 30.0 end
	return value
end

local function get_ballistics(weapon)
	local state
	local velocity
	local gravity_scale
	pcall(function() state = weapon and weapon.MortarAimState end)
	pcall(function()
		if weapon and type(weapon.GetBulletFireSpeedFromEntity) == "function" then
			velocity = tonumber(weapon:GetBulletFireSpeedFromEntity())
		end
	end)
	if not velocity or velocity <= 0 then
		velocity = state == 1 and 12520.0 or 9070.0
	end
	pcall(function()
		local entity = weapon and weapon.ShootWeaponEntity
		if valid(entity) and entity.LaunchGravityScale then
			gravity_scale = tonumber(entity.LaunchGravityScale)
		end
	end)
	if not gravity_scale or gravity_scale <= 0 then
		gravity_scale = state == 1 and 4.0 or 2.8
	end
	return velocity, MortarAim.Config.BaseGravity * gravity_scale
end

local function is_mortar_weapon(weapon)
	if not valid(weapon) then
		return false
	end
	local state
	pcall(function() state = weapon.MortarState end)
	-- The original aim closure gates on MortarState == 2.  Some builds omit
	-- the field from the Lua proxy, so the name check is used only in that case.
	if state ~= nil and tonumber(state) ~= 2 then
		return false
	end
	local name = ""
	pcall(function() name = string.lower(tostring(weapon)) end)
	return string.find(name, "mortar", 1, true) ~= nil or state == 2
end

local function find_target(local_actor, controller)
	local camera = get_camera(controller)
	if not valid(camera) then
		return nil
	end
	local camera_location, camera_rotation
	pcall(function()
		camera_location = camera:GetCameraLocation()
		camera_rotation = camera:GetCameraRotation()
	end)
	if not camera_location or not camera_rotation then
		return nil
	end
	local best_score = MortarAim.Config.FOV
	local best_target
	for actor in pairs(collect_characters()) do
		if is_enemy(local_actor, actor) and not is_dead(actor) then
			local location = get_location(actor)
			if location then
				local dx = location.X - camera_location.X
				local dy = location.Y - camera_location.Y
				local dz = location.Z - camera_location.Z
				local horizontal = math.sqrt(dx * dx + dy * dy)
				-- main/f222 uses horizontal distance for MaxRange; Z is only used
				-- for the angular pitch and the ballistic solve.
				local distance = math.sqrt(dx * dx + dy * dy) / 100.0
				if distance <= MortarAim.Config.MaxRange then
					local yaw = atan2(dy, dx) * (180.0 / math.pi)
					local pitch = atan2(dz, horizontal) * (180.0 / math.pi)
					local yaw_delta = math.abs(normalize_angle(yaw - camera_rotation.Yaw))
					local pitch_delta = math.abs(normalize_angle(pitch - camera_rotation.Pitch))
					if yaw_delta <= MortarAim.Config.FOV then
						local score = math.sqrt(yaw_delta * yaw_delta + (pitch_delta * MortarAim.Config.PitchWeight) ^ 2)
						if score < best_score then
							best_score = score
							best_target = actor
						end
					end
				end
			end
		end
	end
	return best_target
end

local function apply_rotation(player, controller, camera, rotation, yaw)
	pcall(function()
		if valid(camera) then
			camera.bLimitViewPitch = false
			camera.bLimitViewYaw = false
			camera.ViewPitchMin = -89.9
			camera.ViewPitchMax = 89.9
		end
		if type(player.K2_SetActorRotation) == "function" and type(FRotator) == "function" then
			player:K2_SetActorRotation(FRotator(0, yaw, 0), false)
		end
		player.BaseAimRotation = rotation
		controller.ControlRotation = rotation
	end)
	lastAimRotation = rotation
end

function MortarAim.Tick()
	if not ensure_gameplay_data() then
		return
	end
	local player = get_player()
	local controller = get_controller()
	if not valid(player) or not valid(controller) then
		return
	end
	local camera = get_camera(controller)
	if not valid(camera) then
		return
	end
	local camera_rotation
	pcall(function() camera_rotation = camera:GetCameraRotation() end)
	if not camera_rotation then
		return
	end
	local weapon = get_weapon(player)
	if not is_mortar_weapon(weapon) then
		if aimActive then
			aimActive = false
			lockedTarget = nil
			lastAimRotation = nil
			notify("Auto Aim OFF")
		end
		return
	end
	if not aimActive then
		aimActive = true
		notify("Mortar Deployed - AIM ON")
	end
	if lockedTarget and lastAimRotation then
		local yaw_delta = math.abs(normalize_angle(camera_rotation.Yaw - lastAimRotation.Yaw))
		local pitch_delta = math.abs(normalize_angle(camera_rotation.Pitch - lastAimRotation.Pitch))
		if yaw_delta > MortarAim.Config.SwipeBreakAngle or pitch_delta > MortarAim.Config.SwipeBreakAngle then
			lockedTarget = nil
			lastAimRotation = nil
			notify("Target Unlocked (Swiped)")
		end
	end
	if lockedTarget and (not is_enemy(player, lockedTarget) or is_dead(lockedTarget)) then
		lockedTarget = nil
	end
	if lockedTarget then
		local p = get_location(player)
		local t = get_location(lockedTarget)
		if p and t then
			local dx, dy, dz = t.X - p.X, t.Y - p.Y, t.Z - p.Z
			if math.sqrt(dx * dx + dy * dy) / 100.0 > MortarAim.Config.MaxRange then
				lockedTarget = nil
			end
		else
			lockedTarget = nil
		end
	end
	if not lockedTarget then
		lockedTarget = find_target(player, controller)
		if lockedTarget then
			notify("Target Locked!")
		end
	end
	if not lockedTarget then
		lastAimRotation = nil
		return
	end
	local origin = get_location(player)
	local target = get_location(lockedTarget)
	if not origin or not target then
		lockedTarget = nil
		notify("lockedTarget = nil")
		return
	end
	local dx, dy, dz = target.X - origin.X, target.Y - origin.Y, target.Z - origin.Z
	local horizontal = math.sqrt(dx * dx + dy * dy)
	local velocity, gravity = get_ballistics(weapon)
	local ballistic_pitch = solve_ballistic_pitch(horizontal, dz, velocity, gravity)
	local pitch = reverse_map_pitch(ballistic_pitch)
	local yaw = atan2(dy, dx) * (180.0 / math.pi)
	local rotation = FRotator(pitch, yaw, 0)
	apply_rotation(player, controller, camera, rotation, yaw)
end

function MortarAim.Start()
	if started then
		return true
	end
	local ticker = package.loaded["common.time_ticker"] or require("common.time_ticker")
	if not ticker or type(ticker.AddTimerLoop) ~= "function" then
		notify("[ERROR] AddTimerLoop not found!")
		return false
	end
	ticker.AddTimerLoop(0, MortarAim.Tick, -1, MortarAim.Config.AimInterval)
	started = true
	notify("[START] Mortar Auto Aim V28 (Standalone Masterpiece)")
	return true
end

MortarAim.Start()