-- THIS FILE IS EXTRACTED BY @ OFFICIAL_NADEEM896211 TOOL
-- JOIN OVER TELEGRAM CHANNEL @ASSET_FINDER

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