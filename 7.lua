local ASTExtraPlayerController = import("/Script/ShadowTrackerExtra.STExtraPlayerController")
local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
local UGameplayStatics = import("GameplayStatics")
local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local FormatLog = FuncUtil.FormatLog
local LogIf = SecurityCommonUtils.LogIf
local IsNumber = SecurityCommonUtils.IsNumber
local IsTable = SecurityCommonUtils.IsTable
local nMaxCountDownSeconds = 30.0
local sCollectBeWatchedPlayerInfoTimerIDName = "_nCollectBeWatchedPlayerInfoTimerID"
local ClientHawkEyePatrolSubsystem = {}

function ClientHawkEyePatrolSubsystem:_PostConstruct()
  ClientHawkEyePatrolSubsystem.__super._PostConstruct(self)
  FormatLog("_PostConstruct")
  self:AddCommonEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_HAWK_SYNC, self._OnHawkSync, self)
  self:AddCommonEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_HAWK_REPORT_SUCCESS, self._OnHawkReportSuccess, self)
  self:AddCommonEvent(EVENTTYPE_SECURITY, EVENTID_SECURITY_RECV_INSPECTOR_BROADCAST_COUNT, self._OnRecvInspectorBroadcastCount, self)
  self.nInspectorBroadcastCount = -1
  self.nMaxInspectorBroadcastCount = 1
end

function ClientHawkEyePatrolSubsystem:OnRelease()
  FormatLog("OnRelease")
  ClientHawkEyePatrolSubsystem.__super.OnRelease(self)
end

function ClientHawkEyePatrolSubsystem:CheckShowReportedTips()
  FormatLog("CheckShowReportedTips")
  if not UIManager then
    FormatLog("invalid UIManager")
    return false
  end
  if not UIManager.UI_Config_InGame or not UIManager.UI_Config_InGame.BattlePopTips then
    FormatLog("invalid UI_Config")
    return false
  end
  local NewBattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
  if not NewBattlePopTips then
    FormatLog("invalid NewBattlePopTips")
    return false
  end
  if not slua.isValid(NewBattlePopTips.UIRoot) then
    return false
  end
  FormatLog("BattleGeneralTip 12152")
  IngameTipsTools.BattleGeneralTip(12152)
  return true
end

function ClientHawkEyePatrolSubsystem:TryShowReportedTips()
  if self:CheckShowReportedTips() then
    FormatLog("TryShowReportedTips finish")
  else
    self:AddGameTimer(5, false, function()
      self:CheckShowReportedTips()
    end)
    FormatLog("TryShowReportedTips timer")
  end
end

function ClientHawkEyePatrolSubsystem:_OnHawkSync(_, __, uCharacter)
  FormatLog("_OnHawkSync")
  if not slua.isValid(uCharacter) then
    FormatLog("invalid character")
    return
  end
  local ParticalPath = "/Game/Arts_Effect/ParticleSystems/Share/P_Flying_Eagle_Cheaters_Smoke.P_Flying_Eagle_Cheaters_Smoke"
  local Util = require("client.slua_ui_framework.util")
  Util.GetAssetAsync(ParticalPath, function(uParticle)
    if slua.isValid(uParticle) and slua.isValid(uCharacter) then
      local bNoParticle = true
      local ParticleSystemComponentClass = import("/Script/Engine.ParticleSystemComponent")
      local CompList = uCharacter:GetComponentsByClass(ParticleSystemComponentClass)
      for _, uParticleComp in pairs(CompList) do
        if slua.isValid(uParticleComp) and uParticleComp.Template == uParticle then
          bNoParticle = false
          uParticleComp:SetActive(true, false)
          FormatLog("exist Template")
          break
        end
      end
      if bNoParticle then
        local UGameplayStatics = import("GameplayStatics")
        UGameplayStatics.SpawnEmitterAttached(uParticle, uCharacter.RootComponent, "None", FVector(0, 0, 0), FRotator(0, 0, 0), FVector(1, 1, 1), 0, true)
      end
    else
      FormatLog("invalid uParticle")
    end
  end)
  local ENetRole = import("ENetRole")
  if uCharacter.Role == ENetRole.ROLE_AutonomousProxy and not self.bShowBeReportedTips then
    self.bShowBeReportedTips = true
    FormatLog("bShowBeReportedTips rep")
    self:TryShowReportedTips()
  end
  local Loc = uCharacter:K2_GetActorLocation()
  local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
  InGameMarkTools.ClientAddMapMark(81, Loc, 0, nil, nil, uCharacter)
end

function ClientHawkEyePatrolSubsystem:_OnHawkReportSuccess(_, __, bReporter)
  FormatLog("_OnHawkReportSuccess bReporter[%s]", tostring(bReporter))
  if bReporter then
    local UIUtil = require("client.common.ui_util")
    local WatchGame_UIBP_UIRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
    if WatchGame_UIBP_UIRoot and WatchGame_UIBP_UIRoot.CanvasPanel_HawkImprison then
      WatchGame_UIBP_UIRoot.CanvasPanel_HawkImprison:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    end
    local sMessageContent = LocUtil.GetLocalizeResStr("76602")
    local sConfirmButtonText = LocUtil.GetLocalizeResStr("29665")
    local tUIConfig = UIManager.UI_Config_InGame.QuickReportConfirmWindow
    UIManager.ShowUI(tUIConfig, {
      sLogPrefix = "MaliciousTeammateReceiveWarning",
      sConfirmButtonText = sConfirmButtonText,
      sMessage = sMessageContent,
      nAutoConfirmSeconds = -1
    })
  else
    self.bShowBeReportedTips = true
    FormatLog("bShowBeReportedTips rpc")
    IngameTipsTools.BattleGeneralTip(12152)
  end
end

function ClientHawkEyePatrolSubsystem:_OnRecvInspectorBroadcastCount(_, __, nBroadcastCount, bSendHawkReportBoardcast)
  self.nInspectorBroadcastCount = nBroadcastCount or -1
  FormatLog("nBroadcastCount[%s] self.nInspectorBroadcastCount[%s] bSendHawkReportBoardcast[%s]", nBroadcastCount, self.nInspectorBroadcastCount, bSendHawkReportBoardcast)
  if bSendHawkReportBoardcast then
    local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
    if WarzoneHandle and WarzoneHandle.send_hawkeye_report_broadcast then
      FormatLog("send_hawkeye_report_broadcast")
      WarzoneHandle.send_hawkeye_report_broadcast()
    end
  end
end

function ClientHawkEyePatrolSubsystem:GetInspectorBroadcastCount()
  return self.nInspectorBroadcastCount
end

function ClientHawkEyePatrolSubsystem:GetMaxInspectorBroadcastCount()
  return self.nMaxInspectorBroadcastCount
end

function ClientHawkEyePatrolSubsystem:CanInspectorBroadcast()
  return self.nInspectorBroadcastCount >= 0 and self.nInspectorBroadcastCount < self.nMaxInspectorBroadcastCount
end

function ClientHawkEyePatrolSubsystem.InitHawkEyePatrolSubsystem()
  if LogIf(ClientHawkEyePatrolSubsystem._nInitializeTimerID, "timer exists") then
    return
  end
  ClientHawkEyePatrolSubsystem._nInitializeTimerID = Game:SetTimer(1, true, function()
    local tSubsystem = SubsystemMgr:Get("ClientHawkEyePatrolSubsystem")
    if not tSubsystem then
      return
    end
    tSubsystem:_InitHawkEyePatrolSubsystem()
    if ClientHawkEyePatrolSubsystem._nInitializeTimerID then
      Game:ClearTimer(ClientHawkEyePatrolSubsystem._nInitializeTimerID)
      ClientHawkEyePatrolSubsystem._nInitializeTimerID = nil
    end
  end)
end

function ClientHawkEyePatrolSubsystem:_InitHawkEyePatrolSubsystem()
  if LogIf(self._bHasInitialized, "has initialized") then
    return
  end
  if LogIf(not self:IsDuringHawkEyePatrol(), "not patrol") then
    return
  end
  self._bHasReported = false
  self._bHasShownWatchEndedTips = false
  self[sCollectBeWatchedPlayerInfoTimerIDName] = self:AddGameTimer(1, true, function()
    self:_CollectBeWatchedPlayerInfo()
  end)
  self._nPatrolBeginTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
  self:_StartFrameUIRefreshTimer()
  self:_StartHideUITimer()
  self:_StartShowDistanceUITimer()
  self:_StartCloseBattleEndedTipsTimer()
  self:_StartBattleTimeUsageTimer()
  self:_StartQuitVoiceRoomTimer()
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    self:AddControlEvent(uMyController, "OnPlayerKilledOthersPlayer", self._OnPlayerKilledOtherPlayer, self)
    uMyController:ToggleEnableOBBulletTrackEffectSetting(true)
  end
  FormatLog("nPatrolBeginTimeMilliseconds=%.1f", self._nPatrolBeginTime)
  self._bHasInitialized = true
end

function ClientHawkEyePatrolSubsystem:HasReported()
  if self._bHasReported then
    return true
  end
  return false
end

function ClientHawkEyePatrolSubsystem:OnClickLowerLeftExitWatching()
  FormatLog("")
  if self:HasReported() then
    FormatLog("has reported")
    self:ExitWatching()
    return
  end
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_TWO, nil, LocUtil.GetLocalizeResStr(36671), function()
    self:ExitWatching()
  end)
end

function ClientHawkEyePatrolSubsystem:ExitWatching()
  FormatLog("")
  FuncUtil.ShowLoadingToLobby()
  WatchGameUI.ReportExcepion()
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  if WarzoneHandle and WarzoneHandle.send_leave_hawkeye_watch then
    WarzoneHandle.send_leave_hawkeye_watch("player_exit")
  end
  require("client.network.Protocol.ClientEntryHandler").send_giveup_enter_game()
  LobbySystem.ReturnToLobby()
end

function ClientHawkEyePatrolSubsystem:OnClickBottomRightOpenReportWindow()
  local nRemainingSeconds = self:GetForbidNextPatrolRemainingTimeInSeconds()
  FormatLog("nRemainingSeconds=%s", nRemainingSeconds)
  if nRemainingSeconds < 0.1 then
    UIManager.ShowUI(UIManager.UI_Config_InGame.HawkEyeReportWindow)
    return
  end
  local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
  IngameTipsTools.ShowMsgBox(IngameTipsTools.MSGBOX_SHOW_TYPE_TWO, nil, LocUtil.LocalizeResFormat(119600002, math.tointeger(nMaxCountDownSeconds)), function()
    UIManager.ShowUI(UIManager.UI_Config_InGame.HawkEyeReportWindow)
  end, nil, LocUtil.GetLocalizeResStr(49266))
end

function ClientHawkEyePatrolSubsystem:_MarkHasReported()
  FormatLog("")
  self._bHasReported = true
end

function ClientHawkEyePatrolSubsystem:OnShowWatchEndedTips()
  FormatLog("")
  self._bHasShownWatchEndedTips = true
end

function ClientHawkEyePatrolSubsystem:HasShownWatchEndedTips()
  if self._bHasShownWatchEndedTips then
    return true
  end
  return false
end

function ClientHawkEyePatrolSubsystem:SendReportTLog(tReasonCodeArray, bInspectorBroadcast)
  if LogIf(not IsTable(tReasonCodeArray), "invalid tReasonCodeArray") then
    return
  end
  if not self:IsDuringHawkEyePatrol() then
    FormatLog("not during hawkeye patrol")
    return
  end
  local tBeWatchedPlayerInfo = self:GetBeWatchedPlayerInfo()
  if not tBeWatchedPlayerInfo then
    FormatLog("invalid tBeWatchedPlayerInfo")
    return
  end
  if self:HasReported() then
    FormatLog("has reported")
    return
  end
  self:_MarkHasReported()
  local LogicComplaint = require("client.logic.battle.logic_complaint")
  local ComplaintConfig = require("client.slua.umg.complaint.complaint_config")
  local SecurityClientUtils = require("GameLua.Mod.BaseMod.Client.Security.SecurityClientUtils")
  local tMainReasonArray
  if next(tReasonCodeArray) then
    tMainReasonArray = {
      ComplaintConfig.EComplaintReasonType.CHEATED
    }
  end
  local nBitMap = bInspectorBroadcast and 1 or 0
  LogicComplaint.Submit(tBeWatchedPlayerInfo.sPlayerName, tBeWatchedPlayerInfo.bIsAI, false, tMainReasonArray, nil, nil, tReasonCodeArray, nil, nil, nil, ComplaintConfig.EComplaintSceneTLogType.HawkEyePatrol, tBeWatchedPlayerInfo.nPlayerUID, tBeWatchedPlayerInfo.sOpenID, nil, nil, nil, nil, nil, SecurityCommonUtils.GetCurrentBattleMainModeID(), SecurityClientUtils.GetInBattleSubModeID(), SecurityClientUtils.GetInBattleMapID(), false, nil, nil, "hawkeyepatrol", tBeWatchedPlayerInfo.nPlayerUID, nil, nil, nil, nil, nil, nil, nil, nil, nil, nBitMap)
end

function ClientHawkEyePatrolSubsystem:ReportCheat(bInspectorBroadcast)
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uMyController) then
    FormatLog("invalid uMyController")
    return
  end
  local uSpectatorComponent = uMyController.SpectatorComponent
  if not slua.isValid(uSpectatorComponent) then
    FormatLog("invalid uSpectatorComponent")
    return
  end
  uSpectatorComponent:ServerRPC_HawkReportCheat(bInspectorBroadcast)
  if bInspectorBroadcast then
    self.nInspectorBroadcastCount = self.nInspectorBroadcastCount + 1
    FormatLog("update nInspectorBroadcastCount[%s]", self.nInspectorBroadcastCount)
  end
end

function ClientHawkEyePatrolSubsystem:RequestImprison(bImprison)
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uMyController) then
    FormatLog("invalid uMyController")
    return
  end
  local uSpectatorComponent = uMyController.SpectatorComponent
  if not slua.isValid(uSpectatorComponent) then
    FormatLog("invalid uSpectatorComponent")
    return
  end
  if bImprison == nil then
    bImprison = false
  end
  uSpectatorComponent:ServerRPC_RequestImprison(bImprison)
end

function ClientHawkEyePatrolSubsystem:_CollectBeWatchedPlayerInfo()
  if not self:IsDuringHawkEyePatrol() then
    FormatLog("not hawk eye spectator")
    return
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    FormatLog("invalid uMyController")
    return
  end
  local uWatchedCharacter = uMyController:GetCurPawn()
  if not Game:IsClassOf(uWatchedCharacter, ASTExtraPlayerCharacter) then
    FormatLog("invalid uWatchedCharacter")
    return
  end
  if uWatchedCharacter.PlayerKey <= 0 then
    FormatLog("invalid uWatchedCharacter.PlayerKey")
    return
  end
  if uWatchedCharacter.PlayerKey ~= uMyController.LobbyWatchInfo.WatchedPlayerKey then
    FormatLog("player key not equal, %d, %d", uWatchedCharacter.PlayerKey, uMyController.LobbyWatchInfo.WatchedPlayerKey)
    return
  end
  local sOpenID
  local uWatchedPlayerState = uWatchedCharacter:GetPlayerStateSafety()
  if slua.isValid(uWatchedPlayerState) then
    sOpenID = uWatchedPlayerState.OpenID
  end
  self._tBeWatchedPlayerInfo = {
    sPlayerName = uWatchedCharacter:GetPlayerNameSafety(),
    nPlayerUID = tonumber(uWatchedCharacter.PlayerUID),
    sOpenID = sOpenID,
    bIsAI = uWatchedCharacter.bEnsure,
    nTeamID = uWatchedCharacter.TeamID
  }
  FormatLog("sPlayerName=%s, nPlayerUID=%s, sOpenID=%s, bIsAI=%s, nTeamID=%s", self._tBeWatchedPlayerInfo.sPlayerName, self._tBeWatchedPlayerInfo.nPlayerUID, self._tBeWatchedPlayerInfo.sOpenID, self._tBeWatchedPlayerInfo.bIsAI, self._tBeWatchedPlayerInfo.nTeamID)
  SecurityCommonUtils.ClearTimerByMemberName(self, sCollectBeWatchedPlayerInfoTimerIDName)
end

function ClientHawkEyePatrolSubsystem:GetBeWatchedPlayerInfo()
  return self._tBeWatchedPlayerInfo
end

function ClientHawkEyePatrolSubsystem:WantMatchNextPatrol()
  FormatLog()
  if self._bHasCalledWantMatchNextPatrol then
    FormatLog("has called before")
    return
  end
  if not self:IsDuringHawkEyePatrol() then
    FormatLog("not during hawkeye patrol")
    return
  end
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  WarzoneHandle.send_leave_hawkeye_watch("is_hawkeye_next")
  self:_CreateOvertimerTimerForNextPatrol()
  self._bHasCalledWantMatchNextPatrol = true
  self:_CloseExitGameTimer()
end

function ClientHawkEyePatrolSubsystem:GetForbidNextPatrolRemainingTimeInSeconds()
  if self:HasShownWatchEndedTips() then
    FormatLog("HasShownWatchEndedTips")
    return 0
  end
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uMyController = GameplayData.GetPlayerController()
  if not slua.isValid(uMyController) then
    FormatLog("invalid uMyController")
    return 0
  end
  local uWatchedCharacter = uMyController:GetCurPawn()
  if not slua.isValid(uWatchedCharacter) then
    FormatLog("invalid uWatchedCharacter")
    return 0
  end
  if not SecurityCommonUtils.IsHealthStatusAlive(uWatchedCharacter.HealthStatus) then
    FormatLog("health status=%s", uWatchedCharacter.HealthStatus)
    return 0
  end
  if not self._nPatrolBeginTime then
    return nMaxCountDownSeconds
  end
  local nElapsedTimeSeconds = UGameplayStatics.GetTimeSeconds(CGameWorld) - self._nPatrolBeginTime
  nElapsedTimeSeconds = math.max(0, nElapsedTimeSeconds)
  FormatLog("nElapsedTimeSeconds=%.2f", nElapsedTimeSeconds)
  return math.max(0, nMaxCountDownSeconds - nElapsedTimeSeconds)
end

function ClientHawkEyePatrolSubsystem:IsDuringHawkEyePatrol()
  if not GameStatus.IsInFightingStatus() then
    FormatLog("not in battle")
    return false
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    FormatLog("invalid uMyController")
    return false
  end
  return uMyController:IsHawkEyeSpectator()
end

function ClientHawkEyePatrolSubsystem:ReturnLobbyAndOpenH5(bIsOvertime)
  FormatLog()
  if self._bHasCalledReturnLobbyAndOpenH5 then
    FormatLog("has called before")
    return
  end
  if not self:IsDuringHawkEyePatrol() then
    FormatLog("not in hawk eye patrol")
    return
  end
  self:ClearNextPatrolOvertimeTimer(bIsOvertime)
  local WarzoneHandle = require("client.network.Protocol.WarzoneHandle")
  if WarzoneHandle and WarzoneHandle.send_leave_hawkeye_watch then
    WarzoneHandle.send_leave_hawkeye_watch("player_exit")
  end
  local webModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.webModule)
  webModule:BackLobbyAndOpenWeb()
  self._bHasCalledReturnLobbyAndOpenH5 = true
end

function ClientHawkEyePatrolSubsystem:_CreateOvertimerTimerForNextPatrol()
  FormatLog()
  if self._NextPatrolOvertimeTimerID then
    FormatLog("timer exists")
    return
  end
  self._NextPatrolOvertimeTimerID = self:AddGameTimer(10, false, function()
    FormatLog("next patrol overtime")
    self:ReturnLobbyAndOpenH5(true)
  end)
end

function ClientHawkEyePatrolSubsystem:ClearNextPatrolOvertimeTimer(bIsOvertime)
  FormatLog("%s", bIsOvertime)
  SecurityCommonUtils.ClearTimerByMemberName(self, "_NextPatrolOvertimeTimerID")
end

function ClientHawkEyePatrolSubsystem:IsCharacterLocationShouldDraw(uMyLocation, uCharacterLocation)
  if not SecurityCommonUtils.IsVector(uMyLocation) then
    FormatLog("invalid uMyLocation")
    return false
  end
  if not SecurityCommonUtils.IsVector(uCharacterLocation) then
    FormatLog("invalid uCharacterLocation")
    return false
  end
  if uCharacterLocation.Z >= 150000 then
    return false
  end
  if FVector.Dist2D(uMyLocation, uCharacterLocation) > 50000 then
    return false
  end
  return true
end

function ClientHawkEyePatrolSubsystem:_StartFrameUIRefreshTimer()
  FormatLog()
  if self._nFrameUIRefreshTimerID then
    FormatLog("timer exists")
    return
  end
  self._nFrameUIRefreshTimerID = self:AddGameTimer(1, true, function()
    local sLogPrefix = "RefreshFrameUI"
    local tBeWatchedPlayerInfo = self:GetBeWatchedPlayerInfo()
    if not tBeWatchedPlayerInfo then
      FormatLog("%s, invalid tBeWatchedPlayerInfo", sLogPrefix)
      return
    end
    if not self:IsDuringHawkEyePatrol() then
      FormatLog("%s, not hawkeye", sLogPrefix)
      return
    end
    local uMyController = slua_GameFrontendHUD:GetPlayerController()
    if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
      FormatLog("invalid uMyController")
      return
    end
    local uMyLocation = uMyController:GetCurPawnLocation()
    local uPlayerCharacterArray = Game:GetAllPlayerPawns()
    for _, uPlayerCharacter in pairs(uPlayerCharacterArray) do
      if slua.isValid(uPlayerCharacter) and uPlayerCharacter.Replay_CreateEnemyFrameUI and uPlayerCharacter.Replay_SetVisiableOfFrameUI and uPlayerCharacter.Replay_IsEnemyFrameUIExisted and SecurityCommonUtils.IsHealthStatusAlive(uPlayerCharacter.HealthStatus) then
        local bIsShouldShow = true
        if uPlayerCharacter.TeamID == tBeWatchedPlayerInfo.nTeamID then
          bIsShouldShow = false
        end
        local uCharacterLocation = uPlayerCharacter:K2_GetActorLocation()
        if not self:IsCharacterLocationShouldDraw(uMyLocation, uCharacterLocation) then
          bIsShouldShow = false
        end
        if bIsShouldShow then
          if not uPlayerCharacter:Replay_IsEnemyFrameUIExisted() then
            uPlayerCharacter:Replay_CreateEnemyFrameUI(true, true)
          end
          uPlayerCharacter:Replay_SetVisiableOfFrameUI(true)
        else
          uPlayerCharacter:Replay_SetVisiableOfFrameUI(false)
        end
      end
    end
  end)
end

function ClientHawkEyePatrolSubsystem:_StartHideUITimer()
  FormatLog()
  if self._nHideUITimerID then
    FormatLog("timer exists")
    return
  end
  self._nHideUITimerID = self:AddGameTimer(1, true, function()
    local sLogPrefix = "HideUITimer"
    if not self:IsDuringHawkEyePatrol() then
      FormatLog("%s, not hawkeye", sLogPrefix)
      return
    end
    local UIUtil = require("client.common.ui_util")
    local WatchGameUIRoot = UIUtil.GetWidgetByName("watchgame", "WatchGame_UIBP")
    if WatchGameUIRoot and WatchGameUIRoot.AppointmentSwitch then
      FormatLog("%s, hide add friend button", sLogPrefix)
      WatchGameUIRoot.AppointmentSwitch:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end)
end

function ClientHawkEyePatrolSubsystem:_StartShowDistanceUITimer()
  FormatLog()
  if self._nShowDistanceUITimerID then
    FormatLog("timer exists")
    return
  end
  self._nShowDistanceUITimerID = self:AddGameTimer(2, true, function()
    local sLogPrefix = "ShowDistanceUI"
    if not self:IsDuringHawkEyePatrol() then
      FormatLog("%s, not hawkeye", sLogPrefix)
      return
    end
    local tConfig = UIManager.UI_Config_InGame.HawkEyeDistanceUI
    if not tConfig then
      FormatLog("%s, invalid tConfig", sLogPrefix)
      return
    end
    UIManager.ShowUI(tConfig)
    SecurityCommonUtils.ClearTimerByMemberName(self, "_nShowDistanceUITimerID")
  end)
end

function ClientHawkEyePatrolSubsystem:_OnPlayerKilledOtherPlayer(FatalDamageParameter)
  if LogIf(not FatalDamageParameter, "invalid FatalDamageParameter") then
    return
  end
  local nVictimKey = FatalDamageParameter.victimKey
  if LogIf(not IsNumber(nVictimKey), "invalid victim key") then
    return
  end
  if not self:IsDuringHawkEyePatrol() then
    return
  end
  local uMyController = slua_GameFrontendHUD:GetPlayerController()
  if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    return
  end
  if uMyController.LobbyWatchInfo.WatchedPlayerKey ~= nVictimKey then
    FormatLog("WatchedPlayerKey ~= nVictimPlayerKey, %d, %d", uMyController.LobbyWatchInfo.WatchedPlayerKey, nVictimKey)
    return
  end
  if SecurityCommonUtils.IsHealthStatusAlive(uMyController.ClientFatalDamageLastRecords.ResultHealthStatus) then
    return
  end
  FormatLog("OnPlayerKilledOtherPlayer, show watched tips")
  self:ShowWatchEndedTips()
  local uCurPlayerState = uMyController:GetCurPlayerState()
  if slua.isValid(uCurPlayerState) and uCurPlayerState.GetRevivalCount and uCurPlayerState:GetRevivalCount() <= 0 and uCurPlayerState.GetLeftBuyLifeCounts and 0 >= uCurPlayerState:GetLeftBuyLifeCounts() then
    self:_StartExitGameTimer()
  end
end

function ClientHawkEyePatrolSubsystem:_StartCloseBattleEndedTipsTimer()
  FormatLog()
  if self._nCloseBattleEndedTipsTimerID then
    FormatLog("timer exists")
    return
  end
  self._nCloseBattleEndedTipsTimerID = self:AddGameTimer(2, true, function()
    local sLogPrefix = "CloseBattleEndedTips"
    if not self:IsDuringHawkEyePatrol() then
      FormatLog("%s, not hawkeye", sLogPrefix)
      return
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uMyController = GameplayData.GetPlayerController()
    if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
      FormatLog("%s, invalid uMyController", sLogPrefix)
      return
    end
    local bRestoreBattleEndTips = false
    if slua.isValid(uMyController.NetConnection) and uMyController.NetConnection:IsClosed() then
      bRestoreBattleEndTips = true
      FormatLog("%s, connection closed", sLogPrefix)
    end
    local uWatchedPlayerState = uMyController:GetCurPlayerState()
    if slua.isValid(uWatchedPlayerState) and uWatchedPlayerState.isLostConnection then
      bRestoreBattleEndTips = true
      FormatLog("%s, lost connection", sLogPrefix)
    end
    if bRestoreBattleEndTips then
      if WatchGameUI and self._bCloseBattleEndedTipsByMyself then
        self:ShowWatchEndedTips()
        self._bCloseBattleEndedTipsByMyself = false
        FormatLog("%s, restore end tips", sLogPrefix)
      end
      return
    end
    local uWatchedCharacter = uMyController:GetCurPawn()
    if not Game:IsClassOf(uWatchedCharacter, ASTExtraPlayerCharacter) then
      FormatLog("%s, invalid uWatchedCharacter", sLogPrefix)
      return
    end
    if not SecurityCommonUtils.IsHealthStatusAlive(uWatchedCharacter.HealthStatus) then
      FormatLog("%s, health status=%s", sLogPrefix, uWatchedCharacter.HealthStatus)
      return
    end
    if uWatchedCharacter.PlayerKey <= 0 then
      FormatLog("%s, invalid uWatchedCharacter.PlayerKey", sLogPrefix)
      return
    end
    if uWatchedCharacter.PlayerKey ~= uMyController.LobbyWatchInfo.WatchedPlayerKey then
      FormatLog("%s, player key not equal, %d, %d", sLogPrefix, uWatchedCharacter.PlayerKey, uMyController.LobbyWatchInfo.WatchedPlayerKey)
      return
    end
    if not WatchGameUI then
      return
    end
    if self._bNeverCloseBattleEndedTips then
      FormatLog("%s, never close", sLogPrefix)
      return
    end
    FormatLog("%s, close, health=%s", sLogPrefix, uWatchedCharacter.HealthStatus)
    WatchGameUI:CloseBattleEndedTips()
    EventSystem:postEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_SHOWORHIDE_HAWKFREECAM, false)
    self._bCloseBattleEndedTipsByMyself = true
  end)
end

function ClientHawkEyePatrolSubsystem:_StartBattleTimeUsageTimer()
  FormatLog()
  if self._nBattleTimeUsageTimerID then
    FormatLog("timer exists")
    return
  end
  self._nBattleTimeUsageTimerID = self:AddGameTimer(1, true, function()
    local sLogPrefix = "BattleTimeUsage"
    if not self:IsDuringHawkEyePatrol() then
      FormatLog("%s, not hawkeye", sLogPrefix)
      return
    end
    if not slua.isValid(CGameWorld) then
      FormatLog("%s, invalid world", sLogPrefix)
      return
    end
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local uMyController = GameplayData.GetPlayerController()
    if not Game:IsClassOf(uMyController, ASTExtraPlayerController) then
      FormatLog("%s, invalid uMyController", sLogPrefix)
      return
    end
    local uWatchedCharacter = uMyController:GetCurPawn()
    if not Game:IsClassOf(uWatchedCharacter, ASTExtraPlayerCharacter) then
      FormatLog("%s, invalid uWatchedCharacter", sLogPrefix)
      return
    end
    if not SecurityCommonUtils.IsHealthStatusAlive(uWatchedCharacter.HealthStatus) then
      FormatLog("%s, health status=%s", sLogPrefix, uWatchedCharacter.HealthStatus)
      return
    end
    if uWatchedCharacter.PlayerKey <= 0 then
      FormatLog("%s, invalid uWatchedCharacter.PlayerKey", sLogPrefix)
      return
    end
    if uWatchedCharacter.PlayerKey ~= uMyController.LobbyWatchInfo.WatchedPlayerKey then
      FormatLog("%s, player key not equal, %d, %d", sLogPrefix, uWatchedCharacter.PlayerKey, uMyController.LobbyWatchInfo.WatchedPlayerKey)
      return
    end
    local UGameplayStatics = import("GameplayStatics")
    local CurrentWorldTime = UGameplayStatics.GetTimeSeconds(CGameWorld)
    if not IsNumber(self._nBattleUsedSeconds) then
      self._nBattleUsedSeconds = 0
    elseif self._nLastTimeIncreaseBattleUsedSeconds and CurrentWorldTime > self._nLastTimeIncreaseBattleUsedSeconds then
      self._nBattleUsedSeconds = self._nBattleUsedSeconds + (CurrentWorldTime - self._nLastTimeIncreaseBattleUsedSeconds)
    end
    self._nLastTimeIncreaseBattleUsedSeconds = CurrentWorldTime
  end)
end

function ClientHawkEyePatrolSubsystem:GetUsedDailyTimeInSeconds()
  local nResult = 0
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uMyController = GameplayData.GetPlayerController()
  if Game:IsClassOf(uMyController, ASTExtraPlayerController) then
    nResult = uMyController.HawkEyeSpectateUsedMatchCount
    FormatLog("HawkEyeSpectateUsedMatchCount=%s", nResult)
    if 0 < uMyController.HawkEyeSpectateMaxMatchCount then
      local LocalSecondsSinceEpoch = os.time()
      local UTCDateTableSinceEpoch = os.date("!*t", LocalSecondsSinceEpoch)
      local UTCSecondsSinceEpoch = os.time(UTCDateTableSinceEpoch)
      local SecondsSinceInject = UTCSecondsSinceEpoch - uMyController.HawkEyeSpectateMaxMatchCount
      FormatLog("LocalSeconds=%s, UTCDate=%s, UTCSeconds=%s, InjectTime=%s, SinceInject=%s", LocalSecondsSinceEpoch, UTCDateTableSinceEpoch, UTCSecondsSinceEpoch, uMyController.HawkEyeSpectateMaxMatchCount, SecondsSinceInject)
      if 0 < SecondsSinceInject then
        nResult = nResult + SecondsSinceInject
      end
      FormatLog("PlusInject=%s", nResult)
    end
  end
  if IsNumber(self._nBattleUsedSeconds) then
    nResult = nResult + self._nBattleUsedSeconds
    FormatLog("nBattleUsedSeconds=%s", self._nBattleUsedSeconds)
  end
  return nResult
end

function ClientHawkEyePatrolSubsystem:_StartQuitVoiceRoomTimer()
  FormatLog()
  if self._nQuitVoiceRoomTimerID then
    FormatLog("timer exists")
    return
  end
  self._nQuitVoiceRoomTimerID = self:AddGameTimer(5, true, function()
    if not self:IsDuringHawkEyePatrol() then
      return
    end
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    if not logic_chat_voice then
      return
    end
    FormatLog("Quit Voice Room")
    local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
    local Enum_AntsVoiceRoomType = logic_chat_voice_const.Enum_AntsVoiceRoomType
    logic_chat_voice:QuitAntsVoiceRoom(Enum_AntsVoiceRoomType.BattleTeam)
    local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
    logic_antsvoice_interface:QuitLbsRoom()
    if self._nQuitVoiceRoomTimerID then
      self:RemoveGameTimer(self._nQuitVoiceRoomTimerID)
      self._nQuitVoiceRoomTimerID = nil
    end
  end)
end

function ClientHawkEyePatrolSubsystem:ShowWatchEndedTips()
  FormatLog("")
  WatchGameUI:ExitWatchGame(false)
  EventSystem:postEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_SHOWORHIDE_HAWKFREECAM, true)
  self:OnShowWatchEndedTips()
end

function ClientHawkEyePatrolSubsystem:ForceNeverCloseBattleEndedTips()
  FormatLog("")
  self._bNeverCloseBattleEndedTips = true
end

function ClientHawkEyePatrolSubsystem:_StartExitGameTimer()
  if self._nExitGameTimerID then
    FormatLog("ExitGameTimer Exist")
    return
  end
  self._nExitGameTimerID = self:AddGameTimer(60, false, function()
    self:ExitWatching()
  end)
  FormatLog("ExitGameTimer Add Successful")
end

function ClientHawkEyePatrolSubsystem:_CloseExitGameTimer()
  if self._nExitGameTimerID then
    self:RemoveGameTimer(self._nExitGameTimerID)
    FormatLog("ExitGameTimer Clear")
  end
end

local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, ClientHawkEyePatrolSubsystem)

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