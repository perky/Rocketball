-- CLIENT HUD --

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
end

---------------------------------------------------------------------------
-- As long as you know what you're doing you can edit these
-- Or if you really know what your doing delete and create your own hud =D
---------------------------------------------------------------------------

function GM:UpdateHUD_Alive( InRound )
    if ( GAMEMODE.RoundBased || GAMEMODE.TeamBased ) then
        local Bar = vgui.Create( "DHudBar" )
        GAMEMODE:AddHUDItem( Bar, 2 )
		
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
			local RespawnText = vgui.Create( "DHudElement" );
					RespawnText:SizeToContents()
					RespawnText:SetText( "Waiting for round start" )
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
					RoundTimer:SetValueFunction( function()
																					if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then return GetGlobalFloat( "RoundStartTime", 0 )  end
																					return GetGlobalFloat( "RoundEndTime" ) end )
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
			txt = "You Died!" -- were killed by?
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