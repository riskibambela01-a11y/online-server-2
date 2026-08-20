local EnemyESP = {}

local GAME_PACKAGES = {
    "com.tencent.ig",
    "com.rekoo.pubgm",
    "com.pubg.krmobile",
    "com.vng.pubgmobile",
}

local CONFIG_PATH = nil

for _, pkg in ipairs(GAME_PACKAGES) do
    local path = "/storage/emulated/0/Android/data/" .. pkg .. "/小小优.U5.七夕.h"
    local f = io.open(path, "r")
    if f then
        CONFIG_PATH = path
        f:close()
        break
    end
end

local CONFIG = {
    HP_BAR = 1,
    BOX_ESP = 1,
    SHOW_BOT = 1,
    DRAW_DISTANCE = 300,  -- 单位：米
}

local function LoadConfig()
    if not CONFIG_PATH then return end
    local file = io.open(CONFIG_PATH, "r")
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
                    if key == "名字血条" then
                        CONFIG.HP_BAR = numValue or 0
                    elseif key == "显示人框" then
                        CONFIG.BOX_ESP = numValue or 0
                    elseif key == "显示人机" then
                        CONFIG.SHOW_BOT = numValue or 0
                    elseif key == "绘制距离" then
                        CONFIG.DRAW_DISTANCE = numValue or 300
                    end
                end
            end
        end
    end
    file:close()
end

local function IsBot(pawn)
    local teamId = pawn.TeamID or 0
    return teamId > 100
end

local function IsAlive(pawn)
    if not slua.isValid(pawn) then return false end
    local alive = false
    pcall(function()
        alive = pawn:IsAlive()
    end)
    return alive
end

local function GetDistance(pawn1, pawn2)
    local p1 = pawn1:K2_GetActorLocation()
    local p2 = pawn2:K2_GetActorLocation()
    local dx = p1.X - p2.X
    local dy = p1.Y - p2.Y
    local dz = p1.Z - p2.Z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function IsDeadBox(pawn)
    local name = pawn.PlayerName or ""
    if name == "" or name == "Unknown" or name == "UNKNOWN" then
        return true
    end
    return false
end

local function GetValidEnemies(character)
    local myTeamId = character.TeamID or 0
    local allPawns = Game:GetAllPlayerPawns() or {}
    local enemies = {}
    local enemySet = {}
    
    -- 绘制距离：米 → 游戏单位 (1米 = 100单位)
    local drawDistanceUnits = CONFIG.DRAW_DISTANCE * 100
    
    for _, enemy in pairs(allPawns) do
        if slua.isValid(enemy) and enemy ~= character then
            local enemyTeamId = enemy.TeamID or 0
            if enemyTeamId ~= myTeamId then
                if IsDeadBox(enemy) then
                    goto continue
                end
                if IsAlive(enemy) then
                    local dist = GetDistance(character, enemy)
                    if dist > drawDistanceUnits then
                        goto continue
                    end
                    local isBot = IsBot(enemy)
                    if CONFIG.SHOW_BOT == 0 and isBot then
                        goto continue
                    end
                    table.insert(enemies, enemy)
                    enemySet[tostring(enemy)] = true
                end
            end
        end
        ::continue::
    end
    
    return enemies, enemySet
end

local function ModifyScreenMarkConfig()
    pcall(function()
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local screenMarkConfig = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        
        if screenMarkConfig then
            if screenMarkConfig[1006] then
                screenMarkConfig[1006].bBindBlocked = true
                screenMarkConfig[1006].bBindOutScreen = true
                screenMarkConfig[1006].MaxWidgetNum = 99
                screenMarkConfig[1006].MaxShowDistance = 6000000
                screenMarkConfig[1006].bScaleByDistance = false
            end
        end
    end)
end

local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
local activeMarks = {}
local lastEnemySet = {}

local function ClearAllMarks()
    for _, mark in pairs(activeMarks) do
        if mark then
            pcall(function()
                if InGameMarkTools.ClientRemoveMapMark then
                    InGameMarkTools.ClientRemoveMapMark(mark)
                elseif InGameMarkTools.HideMapMark then
                    InGameMarkTools.HideMapMark(mark)
                end
            end)
        end
    end
    activeMarks = {}
end

local function HPBarUpdate()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local character = GameplayData.GetPlayerCharacter()
    if not slua.isValid(character) then
        return
    end
    
    if CONFIG.HP_BAR ~= 1 then
        ClearAllMarks()
        lastEnemySet = {}
        return
    end
    
    local enemies, enemySet = GetValidEnemies(character)
    
    local needRefresh = false
    
    for id, _ in pairs(enemySet) do
        if not lastEnemySet[id] then
            needRefresh = true
            break
        end
    end
    
    if not needRefresh then
        for id, _ in pairs(lastEnemySet) do
            if not enemySet[id] then
                needRefresh = true
                break
            end
        end
    end
    
    if needRefresh then
        ClearAllMarks()
        local index = 1
        for _, enemy in ipairs(enemies) do
            local enemyPos = enemy:K2_GetActorLocation()
            local mark = InGameMarkTools.ClientAddMapMark(1006, enemyPos, 0, "", 4, enemy)
            if mark then
                activeMarks[index] = mark
                index = index + 1
            end
        end
    end
    
    lastEnemySet = enemySet
end

local function BoxESPUpdate()
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local character = GameplayData.GetPlayerCharacter()
    if not slua.isValid(character) then
        return
    end
    
    local enemies, enemySet = GetValidEnemies(character)
    
    local allPawns = Game:GetAllPlayerPawns() or {}
    for _, enemy in pairs(allPawns) do
        if slua.isValid(enemy) and enemy ~= character then
            local shouldShow = (CONFIG.BOX_ESP == 1 and enemySet[tostring(enemy)])
            
            pcall(function()
                if enemy.Replay_SetVisiableOfFrameUI then
                    enemy:Replay_SetVisiableOfFrameUI(shouldShow or false)
                end
            end)
        end
    end
    
    if CONFIG.BOX_ESP == 1 then
        for _, enemy in ipairs(enemies) do
            pcall(function()
                if enemy.Replay_IsEnemyFrameUIExisted then
                    if not enemy:Replay_IsEnemyFrameUIExisted() then
                        enemy:Replay_CreateEnemyFrameUI(true, true)
                    end
                    if enemy.Replay_SetVisiableOfFrameUI then
                        enemy:Replay_SetVisiableOfFrameUI(true)
                    end
                end
            end)
        end
    end
end

local function MainTick_HP()
    LoadConfig()
    HPBarUpdate()
end

local function MainTick_Box()
    LoadConfig()
    BoxESPUpdate()
end

ModifyScreenMarkConfig()

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.HTY_HPBAR_TIMER == tmr then return end
    _G.HTY_HPBAR_TIMER = tmr
    tmr:AddGameTimer(0.1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(0.3, true, MainTick_HP)
        end
    end)
end)

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.HTY_BOX_ESP_TIMER == tmr then return end
    _G.HTY_BOX_ESP_TIMER = tmr
    tmr:AddGameTimer(0.1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(0.3, true, MainTick_Box)
        end
    end)
end)

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

local GAME_PACKAGES = {
    "com.tencent.ig",
    "com.rekoo.pubgm",
    "com.pubg.krmobile",
    "com.vng.pubgmobile",
}

local CONFIG_PATH = nil

for _, pkg in ipairs(GAME_PACKAGES) do
    local path = "/storage/emulated/0/Android/data/" .. pkg .. "/小小优.U5.七夕.h"
    local f = io.open(path, "r")
    if f then
        CONFIG_PATH = path
        f:close()
        break
    end
end

local CONFIG = {
    BULLET_TRACK = 99999,
    TRACK_DISTANCE = 99999,
    TRACK_BOT = 0,
    TRACK_NEARDEATH = 99999,
    TRACK_RANGE = 99999,
    TRACK_PART = 999,
    WEAPON_IDS = {},      -- { [武器ID] = 概率 }
}

local BONE_MAP = {
    [0] = "Head",
    [1] = "neck_01",
    [2] = "spine_03",
}

local function LoadConfig()
    if not CONFIG_PATH then return end
    local file = io.open(CONFIG_PATH, "r")
    if not file then return end
    
    CONFIG.WEAPON_IDS = {}
    
    for line in file:lines() do
        if line then
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" and not trimmed:match("^#") then
                local key, value = trimmed:match("^([^=]+)%s*=%s*(.+)$")
                if key and value then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    local numValue = tonumber(value)
                    if key == "子弹追踪" then
                        CONFIG.BULLET_TRACK = numValue or 0
                    elseif key == "追踪距离" then
                        CONFIG.TRACK_DISTANCE = numValue or 99999999
                    elseif key == "人机追踪" then
                        CONFIG.TRACK_BOT = numValue or 0
                    elseif key == "倒地追踪" then
                        CONFIG.TRACK_NEARDEATH = numValue or 0
                    elseif key == "追踪范围" then
                        CONFIG.TRACK_RANGE = numValue or 99999
                    elseif key == "追踪部位" then
                        CONFIG.TRACK_PART = numValue or 0
                    end
                else
                    -- 解析 "ID 概率" 格式
                    local id, prob = trimmed:match("^(%d+)%s+(%d+)$")
                    if id and prob then
                        CONFIG.WEAPON_IDS[tonumber(id)] = tonumber(prob)
                    else
                        -- 兼容只有ID没有概率
                        local num = tonumber(trimmed)
                        if num then
                            CONFIG.WEAPON_IDS[num] = 100
                        end
                    end
                end
            end
        end
    end
    file:close()
end

local function IsBot(pawn)
    local teamId = pawn.TeamID or 0
    return teamId > 100
end

local function GetEnemyTargetsFromActors(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end
    
    local uPlayerController = player:GetPlayerControllerSafety()
    if not slua.isValid(uPlayerController) then return result end
    
    local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
    if not ASTExtraPlayerCharacter then return result end
    
    local Actors = Game:GetActorsByClass(ASTExtraPlayerCharacter)
    if not Actors then return result end
    
    local count = Actors:Num() or 0
    local myTeam = player:GetTeamID()
    
    for i = 0, count - 1 do
        local actor = Actors:Get(i)
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

local function SniperBulletTrack()
    if CONFIG.BULLET_TRACK ~= 1 then
        return
    end
    
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    
    local pc = player:GetPlayerControllerSafety()
    if not slua.isValid(pc) then return end
    
    if not player.bIsWeaponFiring then return end
    
    local weaponManager = player.WeaponManagerComponent
    if not weaponManager then return end
    
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not currentWeapon then return end
    
    local shootComp = currentWeapon.ShootWeaponComponent
    if not shootComp then return end
    
    local shootEntity = shootComp.ShootWeaponEntityComponent
    if not shootEntity then return end
    
    local weaponID = shootEntity.WeaponID
    
    -- 检查武器ID是否在配置中
    local weaponProb = CONFIG.WEAPON_IDS[weaponID]
    if not weaponProb then
        return
    end
    
    -- 概率判断
    if weaponProb < 100 then
        local rand = math.random(1, 100)
        if rand > weaponProb then
            return
        end
    end
    
    local enemies = GetEnemyTargetsFromActors(CONFIG.TRACK_DISTANCE)
    if not enemies or #enemies == 0 then return end
    
    -- 过滤敌人
    local filteredEnemies = {}
    for _, target in ipairs(enemies) do
        if slua.isValid(target) then
            if CONFIG.TRACK_BOT == 0 and IsBot(target) then
                goto continue
            end
            if CONFIG.TRACK_NEARDEATH == 0 then
                local isNearDeath = false
                pcall(function() isNearDeath = target:IsNearDeath() end)
                if isNearDeath then
                    goto continue
                end
            end
            table.insert(filteredEnemies, target)
        end
        ::continue::
    end
    
    if #filteredEnemies == 0 then return end
    
    local camManager = import("GameplayStatics").GetPlayerCameraManager(pc, 0)
    if not slua.isValid(camManager) then return end
    
    local camLoc = camManager:GetCameraLocation()
    if not camLoc then return end
    
    local ui_util = require("client.common.ui_util")
    if not ui_util then return end
    
    local viewportSize = ui_util.GetViewportSize()
    if not viewportSize then return end
    
    local centerX = viewportSize.X * 0.5
    local centerY = viewportSize.Y * 0.5
    local trackRange = CONFIG.TRACK_RANGE or 99999
    
    local closest = nil
    local closestDist = trackRange
    
    local boneName = BONE_MAP[CONFIG.TRACK_PART] or "Head"
    
    for _, target in ipairs(filteredEnemies) do
        if slua.isValid(target) then
            local aimPos = target:GetBonePos(boneName, {X = 0, Y = 0, Z = 0})
            if aimPos then
                local visible = pc:LineOfSightTo(target, camLoc, true)
                if visible then
                    local screen = import("Vector2D")()
                    local success = pc:ProjectWorldLocationToScreen(aimPos, screen, false)
                    if success and screen.X > 0 and screen.Y > 0 then
                        local dx = screen.X - centerX
                        local dy = screen.Y - centerY
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist < trackRange and dist < closestDist then
                            closestDist = dist
                            closest = target
                        end
                    end
                end
            end
        end
    end
    
    if not slua.isValid(closest) then return end
    
    local aimPos = closest:GetBonePos(boneName, {X = 0, Y = 0, Z = 0})
    if not aimPos then return end
    
    local rot = import("KismetMathLibrary").FindLookAtRotation(camLoc, aimPos)
    local ShootId = shootComp.CurShootID
    shootComp:ShootBulletInner(aimPos, rot, ShootId)
end

local function MainTick()
    LoadConfig()
    SniperBulletTrack()
end

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.HTY_SNIPER_TIMER == tmr then return end
    _G.HTY_SNIPER_TIMER = tmr
    tmr:AddGameTimer(0.1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(0.05, true, MainTick)
        end
    end)
end)

print("HTY - 子弹追踪已加载")

-- THIS FILE IS EXTRACTED BY @ OFFICIAL_NADEEM896211 TOOL
-- JOIN OVER TELEGRAM CHANNEL @ASSET_FINDER

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

local GAME_PACKAGES = {
    "com.tencent.ig",
    "com.rekoo.pubgm",
    "com.pubg.krmobile",
    "com.vng.pubgmobile",
}

local CONFIG = {
    NO_RECOIL_ADS = 1,
    ANTI_SHAKE = 0,
    SUPER_FIRE_RATE = 0,
    FIRE_RATE_VALUE = 0.01,
    ALL_GUN_FOCUS = 1,
    FOCUS_VALUE = 0,
    QUICK_SCOPE = 1,
    SCOPE_VALUE = 25,
    QUICK_SWITCH = 0,
    SWITCH_VALUE = 0,
    AIM_SPEED = 0,
    AIM_RANGE = 0,
    EXTRA_HIT_SCALE = 0,
    NEARDEATH_AIM = 0,
}

local CONFIG_PATH = nil
local lastWeapon = nil

local function LoadConfig()
    for _, pkg in ipairs(GAME_PACKAGES) do
        local path = "/storage/emulated/0/Android/data/" .. pkg .. "/小小优.U5.七夕.h"
        local f = io.open(path, "r")
        if f then
            CONFIG_PATH = path
            f:close()
            break
        end
    end
    if not CONFIG_PATH then return end
    local file = io.open(CONFIG_PATH, "r")
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
                    if key == "无跳弹" then
                        CONFIG.NO_RECOIL_ADS = numValue or 0
                    elseif key == "防抖" then
                        CONFIG.ANTI_SHAKE = numValue or 0
                    elseif key == "射速" then
                        CONFIG.SUPER_FIRE_RATE = numValue or 0
                    elseif key == "射速值" then
                        CONFIG.FIRE_RATE_VALUE = numValue or 0.01
                    elseif key == "聚点" then
                        CONFIG.ALL_GUN_FOCUS = numValue or 0
                    elseif key == "聚点值" then
                        CONFIG.FOCUS_VALUE = numValue or 0
                    elseif key == "秒开镜" then
                        CONFIG.QUICK_SCOPE = numValue or 0
                    elseif key == "开镜值" then
                        CONFIG.SCOPE_VALUE = numValue or 25
                    elseif key == "切枪" then
                        CONFIG.QUICK_SWITCH = numValue or 0
                    elseif key == "切枪值" then
                        CONFIG.SWITCH_VALUE = numValue or 0
                    elseif key == "自瞄速度" then
                        CONFIG.AIM_SPEED = numValue or 0
                    elseif key == "自瞄范围" then
                        CONFIG.AIM_RANGE = numValue or 0
                    elseif key == "X特效" then
                        CONFIG.EXTRA_HIT_SCALE = numValue or 0
                    elseif key == "倒地自瞄" then
                        CONFIG.NEARDEATH_AIM = numValue or 0
                    end
                end
            end
        end
    end
    file:close()
end

local function ApplyWeaponMods(weaponEntity)
    if not slua.isValid(weaponEntity) then return end

    if CONFIG.NO_RECOIL_ADS == 1 then
        weaponEntity.RecoilKickADS = 0.0
    end

    if CONFIG.ANTI_SHAKE == 1 then
        weaponEntity.AnimationKick = 0.0
    end

    if CONFIG.AIM_SPEED > 0 and weaponEntity.AutoAimingConfig then
        local ranges = {"OuterRange", "InnerRange"}
        for _, rangeName in ipairs(ranges) do
            local cfg = weaponEntity.AutoAimingConfig[rangeName]
            if cfg then
                cfg.Speed = CONFIG.AIM_SPEED
            end
        end
    end

    if CONFIG.AIM_RANGE > 0 and weaponEntity.AutoAimingConfig then
        local ranges = {"OuterRange", "InnerRange"}
        for _, rangeName in ipairs(ranges) do
            local cfg = weaponEntity.AutoAimingConfig[rangeName]
            if cfg then
                cfg.adsorbMaxRange = CONFIG.AIM_RANGE
                cfg.adsorbMinRange = CONFIG.AIM_RANGE
            end
        end
    end

    if CONFIG.EXTRA_HIT_SCALE > 0 then
        weaponEntity.ExtraHitPerformScale = CONFIG.EXTRA_HIT_SCALE
    end

    if CONFIG.SUPER_FIRE_RATE == 1 then
        weaponEntity.ShootInterval = CONFIG.FIRE_RATE_VALUE
    end

    if CONFIG.ALL_GUN_FOCUS == 1 then
        weaponEntity.GameDeviationAccuracy = CONFIG.FOCUS_VALUE
        weaponEntity.GameDeviationFactor = CONFIG.FOCUS_VALUE
        weaponEntity.ShotGunHorizontalSpread = CONFIG.FOCUS_VALUE
        weaponEntity.ShotGunVerticalSpread = CONFIG.FOCUS_VALUE
        weaponEntity.CrossHairBurstSpeed = CONFIG.FOCUS_VALUE
        weaponEntity.CrossHairBurstIncreaseSpeed = CONFIG.FOCUS_VALUE
    end

    if CONFIG.QUICK_SCOPE == 1 then
        weaponEntity.WeaponAimInTime = CONFIG.SCOPE_VALUE
    end

    if CONFIG.QUICK_SWITCH == 1 then
        weaponEntity.SwitchFromBackpackToIdleTime = CONFIG.SWITCH_VALUE
        weaponEntity.SwitchFromIdleToBackpackTime = CONFIG.SWITCH_VALUE
    end

    if weaponEntity.AutoAimingConfig then
        local dyRate = 0
        if CONFIG.NEARDEATH_AIM == 1 then
            dyRate = 10
        end
        if weaponEntity.AutoAimingConfig.OuterRange then
            weaponEntity.AutoAimingConfig.OuterRange.DyingRate = dyRate
        end
        if weaponEntity.AutoAimingConfig.InnerRange then
            weaponEntity.AutoAimingConfig.InnerRange.DyingRate = dyRate
        end
    end
end

local function MainTick()
    local uCon = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uCon) then return end
    local currentPawn = uCon:GetCurPawn()
    if not slua.isValid(currentPawn) then return end

    LoadConfig()

    local wm = currentPawn.WeaponManagerComponent
    if not wm then return end
    
    local weapon = wm.CurrentWeaponReplicated
    if not weapon then return end
    
    local entity = weapon.ShootWeaponEntityComp
    if not slua.isValid(entity) then return end
    
    -- 只有换武器时才修改
    if weapon ~= lastWeapon then
        ApplyWeaponMods(entity)
        lastWeapon = weapon
    end
end

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.HTY_WEAPON_TIMER == tmr then return end
    _G.HTY_WEAPON_TIMER = tmr
    tmr:AddGameTimer(1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(3, true, MainTick)
        end
    end)
end)