-------------------------------------------------------------------------
--T and G Apps Ltd.
--Created by Joseph Stevens
--www.tandgapps.co.uk
--joe@tandgapps.co.uk

--CoronaSDK version 2014.2100 was used for this template.
--Please use an even newer version that has Png2Box2D image sheet support for the correct physics outlines.

--You are not allowed to publish this template to the Appstore as it is. 
--You need to work on it, improve it and replace the graphics. 

--For questions and/or bugs found, please contact me using our contact
--form on http://www.tandgapps.co.uk/contact-us/
-------------------------------------------------------------------------
local storyboard = require( "composer" )
local scene = storyboard.newScene()
local physics = require ("physics")	-- Require physics
local gameNetwork = require "gameNetwork"


-----------------------------------------------
--*** Set up our variables and group ***
-----------------------------------------------
-- Setup the display groups we want
local gameGroup
local uiGroup
local workshopGroup

-- Some handy maths vars
local _W = display.contentWidth
local _H = display.contentHeight

-- Functions
local menuTick
local playTapped
local soundTapped -- Wael Abed Elal
local muteTapped
local gameTapped -- WAE
local rateTapped
local settingsTapped

-- Set up sprite sheets
local playerSpriteSheet
local playerSequenceData
local cloudSpriteSheet
local numbersSpriteSheet --W
local numbersSequenceData --W

-----------------------------------------------
--*** Set up our sprites ***
-----------------------------------------------
local player
local floor
local logoFancy
local logoFlap
local highscoreLabel
local background
local backgroundAlt
local clouds = {}
local bgArt
local me
local gameModes = {}

-- Revmob ads

local easyButton
local mediumButton
local hardButton
local settingsButton




-- Logo

local f1
local a1
local n
local c
local y
local f2
local l
local a2
local p

local fence
local fenceAlt


----------------------------------------------------------------------------------
--
-- scenetemplate.lua
--
----------------------------------------------------------------------------------


-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:create( event )
	local screenGroup = self.view
	gameGroup = display.newGroup()
	logo = display.newGroup()
	uiGroup = display.newGroup()
	screenGroup:insert(gameGroup)
	screenGroup:insert(uiGroup)
	screenGroup:insert(logo)

	f1 = display.newImageRect(logo, "assets/logo/f@2x.png", 30, 70)
	f1.x = _W / 2 - 102
	f1.y = _H / 2 - 400
	
	a1 = display.newImageRect(logo, "assets/logo/a@2x.png", 30, 50)
	a1.x = _W / 2 - 75
	a1.y = _H / 2 - 400
	
	n = display.newImageRect(logo, "assets/logo/n@2x.png", 30, 50)
	n.x = _W / 2 - 46
	n.y = _H / 2 - 400
	
	c = display.newImageRect(logo, "assets/logo/c@2x.png", 30, 50)
	c.x = _W / 2 - 18
	c.y = _H / 2 - 400
	
	y = display.newImageRect(logo, "assets/logo/y@2x.png", 30, 70)
	y.x = _W / 2 + 11
	y.y = _H / 2 - 400
	
	f2 = display.newImageRect(logo, "assets/logo/f2@2x.png", 30, 70)
	f2.x = _W / 2 + 39
	f2.y = _H / 2 - 400
	
	l = display.newImageRect(logo, "assets/logo/l@2x.png", 15, 70)
	l.x = _W / 2 + 59
	l.y = _H / 2 - 400
	
	a2 = display.newImageRect(logo, "assets/logo/a2@2x.png", 30, 50)
	a2.x = _W / 2 + 79
	a2.y = _H / 2 - 400
	
	p = display.newImageRect(logo, "assets/logo/p@2x.png", 30, 70)
	p.x = _W / 2 + 104.5
	p.y = _H / 2 - 400
	
	
	
	

	easyButton = display.newImageRect(uiGroup, "assets/easy_button.png", 210, 69)
	easyButton.x = _W / 2 
	easyButton.y = _H / 2 + 50
	easyButton.xScale = 0.8
	easyButton.yScale = 0.8
	--(_H / 2 - 120) + math.sin(event.time / 500) * 3
	
	mediumButton = display.newImageRect(uiGroup, "assets/medium_button.png", 210, 69)
	mediumButton.x = _W / 2 
	mediumButton.y = _H / 2 + 110
	mediumButton.xScale = 0.8
	mediumButton.yScale = 0.8

	hardButton = display.newImageRect(uiGroup, "assets/hard_button.png", 210, 69)
	hardButton.x = _W / 2 
	hardButton.y = _H / 2 + 170
	hardButton.xScale = 0.8
	hardButton.yScale = 0.8
	
	settingsButton = display.newImageRect(uiGroup, "assets/settings_button.png", 69, 71)
	settingsButton.x = _W / 2 + 120
	settingsButton.y = _W / 2 + 370
	settingsButton.xScale = 0.8
	settingsButton.yScale = 0.8
	
	
	
	--[[
	muteButton = display.newImageRect(uiGroup, "assets/sound@2x.png", 50, 40)
	muteButton.x = _W / 2 
	muteButton.y = _H / 2 + 235
	muteButton.alpha = 1
	
	soundButton = display.newImageRect(uiGroup, "assets/mute@2x.png", 50, 40)
	soundButton.x = _W / 2 
	soundButton.y = _H / 2 + 235
	soundButton.alpha = 1
	soundButton.isVisible = false --]]
	
	
	if(system.getInfo("model") == "iPad") then
		uiGroup.y = -10
	end
	
	logo.y = logo.y - 60
	
	if _W < 500 and _H < 500 then
		uiGroup.y = uiGroup.y-90
	else
		uiGroup.y = uiGroup.y
	end
	
	rPlayer = {}
	rPlayer.__index = rPlayer
	setmetatable(rPlayer, {__index = rPlayer })

	_G.players = { "assets/flappy_bird4@2x.png", "assets/flappy_bird2@2x.png", "assets/flappy_bird3@2x.png", "assets/flappy_bird@2x.png", "assets/flappy_bird5@2x.png", "assets/flappy_bird6@2x.png"}
  	_G.randomPlayer = players[math.random(1, #players)]
	
	playerSequenceData = {name="player", start=1, count=3, time=200}
	playerSpriteSheet = graphics.newImageSheet(randomPlayer, {width=34, height=24, numFrames=3, sheetContentWidth=102, sheetContentHeight=24})
	player = display.newSprite(uiGroup, playerSpriteSheet, playerSequenceData)
	player.x = _W / 2 - 300
	player.y = _H - 70
	previousY = player.y
	player.xScale = -4.3
	player.yScale = 4.3
	player:setSequence("player")
	player:play()
	
 physics.start()
 physics.setGravity(0, worldGravity)
 
 local flappy = { 42, -25, 30,-47, 46,-40, 50,45, -45,45, -50,-40, 53, 40, 55, 45, 50, 60 }
 physics.addBody( player, { density=3.0, friction=0.8, bounce=0.3, shape=flappy } )
 
 
 physics.setDrawMode( "normal" ) --set to hybrid to see the physics shapes.



		Background = {}
	Background.__index = Background
	setmetatable(Background, {__index = Background })

	_G.backgrounds = { "assets/background-day@2x.png", "assets/background-night@2x.png"}
  	_G.randomBackground = backgrounds[math.random(1, #backgrounds)]
	background = display.newImageRect(gameGroup, randomBackground, _W + 1, _H-10)
	background.anchorY = 1
	background.x = _W / 2
	background.y = _H - 10

	backgroundAlt = display.newImageRect(gameGroup, randomBackground, _W + 1, _H-10)
	backgroundAlt.anchorY = 1
	backgroundAlt.x = 
	_W + _W / 2
	backgroundAlt.y = _H - 10

	
	

	floor = display.newImageRect(gameGroup, "assets/floor@2x.png", 500, 100)
	floor.anchorX = 0
	floor.anchorY = 0
	floor.x = 0
	floor.y = _H - 70
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:show( event )
	-- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeHidden()


    --Functions
	menuTick = function (event)
		-- Move the player up and down in a sine wave
		player.y = _H / 2 - 60 + math.sin(event.time / 200) * 8
		--logo
		local animateLogo = function ( event )
			a1.y = (_H / 2 - 120) + math.sin(event.time / 500) * 3
			n.y = (_H / 2 - 120) + math.cos(event.time / 500) * 3
			c.y = (_H / 2 - 120) + math.sin(event.time / 500) * 3
			y.y = (_H / 2 - 110) + math.cos(event.time / 500) * 3
			l.y = (_H / 2 - 130) + math.cos(event.time / 500) * 3
			a2.y = (_H / 2 - 120) + math.sin(event.time / 500) * 3
			p.y = (_H / 2 - 110) + math.cos(event.time / 500) * 3
		end
		timer.performWithDelay(600, animateLogo)
		
		
		
		-- Rotate the player depending on their position last frame
		--player.rotation = math.atan2((player.y - previousY) / 4, 1) * -20 / math.pi

		-- Save the player's Y position so that it can be used for rotation next frame
		previousY = player.y 

		-- Update the floor position, %35 to make the floor look like it's repeating
		floor.x = (floor.x - 1) % 35 - 35

		-- Move the repeating background
		background:translate(-0.5, 0)
		backgroundAlt:translate(-0.5, 0)

		if background.x <= -_W/2 then
			background.x = _W + _W / 2 - 2
		end
		
		if backgroundAlt.x <= -_W/2 then
			backgroundAlt.x = _W + _W / 2 - 2
		end

	end

	
	

	playTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.xScale = t.xScale - 0.06
			t.yScale = t.yScale - 0.06
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.xScale = t.xScale + 0.06
				t.yScale = t.yScale + 0.06

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					playSound("select")

					-- Go the the game
					storyboard.gotoScene( "game", "fade", 400 )
				end
			end
		end
		return true
	end--]]

		gameTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.xScale = t.xScale - 0.06
			t.yScale = t.yScale - 0.06
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.xScale = t.xScale + 0.06
			    t.yScale = t.yScale + 0.06

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					playSound("select")
gameNetwork.show( "leaderboards", 
     { leaderboard = 
          { category="FFLB1", playerScope="Global", timeScope="AllTime" } 
     } )
     
     gameNetwork.request( "loadScores",
{
    leaderboard =
    {
        category="FFLB1",
        playerScope="Global",   -- Global, FriendsOnly
        timeScope="AllTime",    -- AllTime, Week, Today
        range={1,99}
    },
    listener=requestCallback
})
					
				end
			end
		end
		return true
	end
	--]] 
	--[[
			muteTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.yScale = 0.9
			t.xScale = 0.9
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
			t.yScale = 1
			t.xScale = 1
			t.alpha = 1

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					muteButton.isVisible = false
					soundButton.isVisible = true
					audio.setVolume(0, {channel = 1})
					audio.setVolume(0, {channel = 2})
					audio.setVolume(0, {channel = 3})
					audio.setVolume(0, {channel = 4})
					audio.setVolume(0, {channel = 5})
					audio.setVolume(0, {channel = 6})
					
				end
			end
		end
		return true
	end --]]
	--[[
			soundTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.yScale = 0.9
			t.xScale = 0.9
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
			t.yScale = 1
			t.xScale = 1
			t.alpha = 1

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					muteButton.isVisible = true
					soundButton.isVisible = false
audio.setVolume(1, {channel = 1})
audio.setVolume(0.5, {channel = 2})
audio.setVolume(1, {channel = 3})
audio.setVolume(1, {channel = 4})
audio.setVolume(1, {channel = 5})
					
					
				end
			end
		end
		return true
	end --]]
	
	
	settingsTapped = function ( event )
		local t = event.target
		if event.phase == "began" then
			display.getCurrentStage():setFocus(t)
			t.isFocus = true
			t.xScale = t.xScale - 0.06
			t.yScale = t.yScale - 0.06
				elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.xScale = t.xScale + 0.06
				t.yScale = t.yScale + 0.06
				transition.to(t, {rotation = 360 ,   alpha=255, time=1000, delay=100})

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					playSound("select")
					

					-- Go the the game
					--storyboard.gotoScene( "game", "fade", 400 )
				end
			end
		end
		return true
	end
	--[[
	local rect = display.newRect( 50, 50, 100, 150 )
rect:setFillColor( 1, 0, 0 )
rect.rotation = -45
local reverse = 1

local function rockRect()
    if ( reverse == 0 ) then
        reverse = 1
        transition.to( rect, { rotation=-45, time=500, transition=easing.inOutCubic } )
    else
        reverse = 0
        transition.to( rect, { rotation=45, time=500, transition=easing.inOutCubic } )
    end
end
--]]
timer.performWithDelay( 600, rockRect, 0 )  -- Repeat forever
	
	
				rateTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.xScale = t.xScale - 0.06
			t.yScale = t.yScale - 0.06
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.xScale = t.xScale + 0.06
				t.yScale = t.yScale + 0.06

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then 
					local options =
					{
  						iOSAppId = "861853047"
					}
					native.showPopup( "appStore", options )
					playSound("select")
				end
			end
		end
		return true
	end
	

	--
    		transition.to(player, {x=_W / 2 ,   alpha=255, time=2000, delay=100})
			transition.to(f1, {y=_H / 2 - 130 ,  alpha=255, time=500, delay=100})
			transition.to(a1, {y=_H / 2 - 120 ,  alpha=255, time=500, delay=100})
			transition.to(n, {y=_H / 2 - 120 ,  alpha=255, time=500, delay=100})
			transition.to(c, {y=_H / 2 - 120 ,  alpha=255, time=500, delay=100})			
			transition.to(y, {y=_H / 2 - 110 ,  alpha=255, time=500, delay=100})
			transition.to(f2, {y=_H / 2 - 130 ,  alpha=255, time=500, delay=100})		
			transition.to(l, {y=_H / 2 - 130 ,  alpha=255, time=500, delay=100})
			transition.to(a2, {y=_H / 2 - 120 ,  alpha=255, time=500, delay=100})		
			transition.to(p, {y=_H / 2 - 110 ,  alpha=255, time=500, delay=100})
	
	
	
	--[[
		logoFancy.x = _W / 2 - 60
	logoFancy.y = _H / 2 - 100
	logoFancy.alpha = 50
	
	logoFlap = display.newImageRect(uiGroup, "assets/flap@2x.png", 110, 50)
	logoFlap.x = _W / 2 + 80
	logoFlap.y = _H / 2 - 100
	logoFlap.alpha = 50
	
	]]--

	--
	local highscoreFile = io.open(system.pathForFile("highscore", system.DocumentsDirectory), "r")

	if not highscoreFile then
		-- create a new one
		highscoreFile = io.open(system.pathForFile("highscore", system.DocumentsDirectory), "w")
		highscoreFile:write("0")
		highscoreFile:close()
		highscoreFile = io.open(system.pathForFile("highscore", system.DocumentsDirectory), "r")
	end

	local highscore = tonumber(highscoreFile:read("*a"))
	highscoreFile:close()
	highscoreFile = nil

	-- Show an ad
	banner:show()

	-- Add the event listeners
	Runtime:addEventListener("enterFrame", menuTick)
	easyButton:addEventListener("touch", playTapped)
	settingsButton:addEventListener("touch", settingsTapped)
	--soundButton:addEventListener("touch", soundTapped)
	hardButton:addEventListener("touch", gameTapped)
	mediumButton:addEventListener("touch", rateTapped)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:destroy( event )
	Runtime:removeEventListener("enterFrame", menuTick)
end


-----------------------------------------------
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

return scene
