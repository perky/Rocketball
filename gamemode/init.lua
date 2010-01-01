-- INIT --
-- Useful link: http://luabin.foszor.com/code/gamemodes/fretta/gamemode

-- Load lua files.
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

-- Send content to players.
-- resource.AddFile("path/to/file.extension")

------------------------------------
-- Create variables and Initialize.
------------------------------------
function GM:Initialize()
	self.BaseClass:Initialize()
end

function GM:Think()
	self.BaseClass:Think()
end

------------------------------------
-- Round Functions.
-- Useful to call:
-- GAMEMODE:AddRoundTime( extra_time )
-- GAMEMODE:RoundEndWithResult( winner, text )
------------------------------------
function GM:CanStartRound( round_number )
	return true
end

function GM:OnPreRoundStart( round_number )
	self.BaseClass:OnPreRoundStart( round_number )
	
	UTIL_UnFreezeAllPlayers()
end

function GM:OnRoundStart( round_number )
	self.BaseClass:OnRoundStart( round_number )
	
	GAMEMODE:SpawnRocketball()
end

function GM:OnRoundEnd( round_number )
	self.BaseClass:OnRoundEnd( round_number )
end

function GM:RoundTimerEnd()
	self.BaseClass:RoundTimerEnd()
end

function GM:CheckRoundEnd()
	self.BaseClass:CheckRoundEnd()
end

function GM:CheckPlayerDeathRoundEnd()
	self.BaseClass:CheckPlayerDeathRoundEnd()
end

------------------------------------
-- Player Functions.
------------------------------------
function GM:PlayerConnect( pl, ip )
end

function GM:PlayerAuthed( pl, steam_id, unique_id )
end

function GM:PlayerReconnected( pl )
end

function GM:PlayerInitialSpawn( pl )
	self.BaseClass:PlayerInitialSpawn( pl )
end

function GM:PlayerDisconnected( pl )
	self.BaseClass:PlayerDisconnected( pl )
end

function GM:PlayerDeath( victim, attacker, dmginfo )
	self.BaseClass:PlayerDeath( victim, attacker, dmginfo )
end

function GM:PlayerDeathSound()
	-- Return true to disable the default death sound,
	-- then play your custom sound in GM:PlayerDeath()
	return false
end

function GM:GravGunPickupAllowed( ply, ent )
	return false
end

function GM:GravGunPunt( pl, ent )
	if ent:GetClass() == "sent_rocketball" and ent:GetPos():Distance( pl:EyePos() ) < 160 then
		ent:OnPunt( pl )
		return true
	else
		return false
	end
end

local rocketball = nil
function GM:SpawnRocketball()
	if not GAMEMODE:InRound() then return end
	
	local ent = ents.Create( "sent_rocketball" )
	ent:SetPos( Vector(0,0,150) )
	ent:Spawn()
	ent:Activate()
	
	rocketball = ent
	return ent
end

function GM:PreSpawnRocketball()
	timer.Simple( 1, self.SpawnRocketball, self )
end

------------------------------------
-- Entity Functions.
------------------------------------
function GM:EntityTakeDamage( ent, inflictor, attacker, damage_amount, damage_info )
end