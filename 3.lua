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
