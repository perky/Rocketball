-- CLIENT HUD --
local BarRange = 1000
local BarScale = 0.7
local matball = Material("sprites/sent_ball")
local lastPuntAlpha = 0
local lastPuntDist  = 0

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	
	local BarWidth = ScrW() * BarScale
	local temp = 9999999
	local distance
	local Rocketball
	for k,v in pairs( ents.FindByClass("sent_rocketball") ) do
		distance = v:GetPos():Distance( LocalPlayer():EyePos() )
		if distance < temp then 
			Rocketball = v
			temp = distance
		end
	end
	
	if IsValid( Rocketball ) then
		distance = math.min(temp, BarRange)
		temp = BarWidth / BarRange
		
		local pos = BarWidth - (distance * temp)
		local good = BarWidth - (GAMEMODE.PuntLength * temp)
		local best = BarWidth - ((GAMEMODE.PuntPowerMax-GAMEMODE.PuntPowerMin) * temp)
		local offset = (ScrW() - BarWidth) / 2
		
		draw.RoundedBox( 6, offset, 80, BarWidth, 10, Color(0,0,0,255) )
		draw.RoundedBox( 6, offset+good, 80, BarWidth-good, 10, Color(0,255,0,255) )
		draw.RoundedBox( 6, offset+good, 80, BarWidth-best, 10, Color(255,0,0,255) )
		
		local rr,gg,bb = Rocketball:GetColor()
		surface.SetDrawColor( rr, gg, bb, 255 ) 
		surface.SetMaterial(matball)
		surface.DrawTexturedRect(offset+pos, 50, 64, 64)
		
		if lastPuntAlpha > 0 then
			lastPuntAlpha = lastPuntAlpha - 1
			pos = BarWidth - (lastPuntDist * temp)
			if LocalPlayer():GetNetworkedInt("powerup") == 1 then
				surface.SetDrawColor( 0, 255, 0, lastPuntAlpha )
			else
				surface.SetDrawColor( 255, 255, 255, lastPuntAlpha )
			end
			surface.DrawTexturedRect(offset+pos, 50, 64, 64)
		end
	end
	
	
end

function GM:GravGunPunt( pl, ent )
	local dist = ent:GetPos():Distance( pl:EyePos() )
	lastPuntAlpha = 150
	if dist > GAMEMODE.PuntLength then dist = GAMEMODE.PuntLength end
	lastPuntDist  = dist
	return true
end
---------------------------------------------------------------------------
-- As long as you know what you're doing you can edit these
-- Or if you really know what your doing delete and create your own hud =D
---------------------------------------------------------------------------
local CustomText = ""

function GM:HUDNeedsUpdate()
	if self.BaseClass:HUDNeedsUpdate() then return true end
	
	if CustomText != GetGlobalString("CustomHudText") then
		CustomText = GetGlobalString("CustomHudText")
		return true
	end
	
	return false
end

function GM:UpdateHUD_Alive( InRound )
    if ( GAMEMODE.RoundBased || GAMEMODE.TeamBased ) then
        local Bar = vgui.Create( "DHudBar" )
        GAMEMODE:AddHUDItem( Bar, 2 )
		
		local text = GetGlobalString("CustomHudText")
		if text != "" then
			local CustomText = vgui.Create( "DHudElement" );
			CustomText:SizeToContents()
			CustomText:SetText( text )
			GAMEMODE:AddHUDItem( CustomText, 8 )
		end
		
		
		if ( GAMEMODE.TeamBased ) then
            local TeamIndicator = vgui.Create( "DHudUpdater" );
                TeamIndicator:SizeToContents()
                TeamIndicator:SetValueFunction( function() return team.GetName( LocalPlayer():Team() ) end )
                TeamIndicator:SetColorFunction( function() return team.GetColor( LocalPlayer():Team() ) end )
                TeamIndicator:SetFont( "HudSelectionText" )
                Bar:AddItem( TeamIndicator )
		end
               
        if ( GAMEMODE.RoundBased ) then
            local RoundNumber = vgui.Create( "DHudUpdater" );
                RoundNumber:SizeToContents()
                RoundNumber:SetValueFunction( function() return GetGlobalInt( "RoundNumber", 0 ) end )
                RoundNumber:SetLabel( "ROUND" )
                Bar:AddItem( RoundNumber )
                       
            local RoundTimer = vgui.Create( "DHudCountdown" );
                RoundTimer:SizeToContents()
                RoundTimer:SetValueFunction( 
					function() 
						if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then 
							return GetGlobalFloat( "RoundStartTime", 0 ) 
						end
                        return GetGlobalFloat( "RoundEndTime" ) 
					end
				)
                RoundTimer:SetLabel( "TIME" )
                Bar:AddItem( RoundTimer )
		end
    end
end

function GM:UpdateHUD_Dead( bWaitingToSpawn, InRound )
	if ( !InRound && GAMEMODE.RoundBased ) then
			
			local text = GetGlobalString("CustomHudText")
			if text == "" then
				text = "Waiting for round start"
			end
			local RespawnText = vgui.Create( "DHudElement" );
					RespawnText:SizeToContents()
					RespawnText:SetText( text )
			GAMEMODE:AddHUDItem( RespawnText, 8 )
			return
	end

	if ( bWaitingToSpawn ) then
			local RespawnTimer = vgui.Create( "DHudCountdown" );
					RespawnTimer:SizeToContents()
					RespawnTimer:SetValueFunction( function() return LocalPlayer():GetNWFloat( "RespawnTime", 0 ) end )
					RespawnTimer:SetLabel( "SPAWN IN" )
			GAMEMODE:AddHUDItem( RespawnTimer, 8 )
			return
	end
   
	if ( InRound ) then
			local RoundTimer = vgui.Create( "DHudCountdown" );
					RoundTimer:SizeToContents()
					RoundTimer:SetValueFunction( 
					function()
						if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then return GetGlobalFloat( "RoundStartTime", 0 )  end
						return GetGlobalFloat( "RoundEndTime" ) 
					end
					)
					RoundTimer:SetLabel( "TIME" )
			GAMEMODE:AddHUDItem( RoundTimer, 8 )
			return
	end
   
	if ( Team != TEAM_SPECTATOR && !Alive ) then
			local RespawnText = vgui.Create( "DHudElement" );
					RespawnText:SizeToContents()
					RespawnText:SetText( "Press Fire to Spawn" )
			GAMEMODE:AddHUDItem( RespawnText, 8 )   
	end
end

function GM:UpdateHUD_Observer( bWaitingToSpawn, InRound, ObserveMode, ObserveTarget )
	local lbl = nil
	local txt = nil
	local col = Color( 255, 255, 255 );

	if ( IsValid( ObserveTarget ) && ObserveTarget:IsPlayer() && ObserveTarget != LocalPlayer() && ObserveMode != OBS_MODE_ROAMING ) then
			lbl = "SPECTATING"
			txt = ObserveTarget:Nick()
			col = team.GetColor( ObserveTarget:Team() );
	end
   
	if ( ObserveMode == OBS_MODE_DEATHCAM || ObserveMode == OBS_MODE_FREEZECAM ) then
			txt = "You Died! You'll spawn next round." -- were killed by?
	end
   
	if ( txt ) then
			local txtLabel = vgui.Create( "DHudElement" );
			txtLabel:SetText( txt )
			if ( lbl ) then txtLabel:SetLabel( lbl ) end
			txtLabel:SetTextColor( col )
		   
			GAMEMODE:AddHUDItem( txtLabel, 2 )             
	end
   
	GAMEMODE:UpdateHUD_Dead( bWaitingToSpawn, InRound )
end