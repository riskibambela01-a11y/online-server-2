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