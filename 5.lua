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