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
local physics = require ("physics")	--Require physics
local gameNetwork = require "gameNetwork"
--local facebook = require( "facebook" )
require('bmf2')
local json = require( "json" )

local myfont = bmf2.loadFont( 'bmGlyphArial' )

-----------------------------------------------
--*** Set up our variables ***
-----------------------------------------------
-- Setup the display groups we want
local backgroundGroup
local gameGroup
local wallGroup

-- Some handy maths vars
local _W = display.contentWidth
local _H = display.contentHeight
local mSin = math.sin
local mAtan2 = math.atan2
local mPi = math.pi 
local mR = math.random

local wallSpeed = 3 -- Speed the walls move
local wallGapHeight = 300 -- Gap between the top and bottom wall
local wallSpeedFrequency = 1300 -- The amount of time in ms between each wall appearing
local flapForce = 520 -- How fast the player is pushed up when they tap the screen
local worldGravity = 50 -- How fast the player falls
local screenShakeIntensity = 10 -- How much the screen shakes when the player dies
local screenShakeDuration = 10-- How long the screen shakes for (50 = 1 second)








-- The scores for getting medals on game over

local scores = {}
scores.bronzeMedalScore = 10
scores.silverMedalScore = 30
scores.goldMedalScore = 60
scores.platinumMedalScore = 150
scores.rainbowMedalScore = 250
scores.chuckMedalScore = 500

-- Do not edit these
local previousY
local hasGameStarted = false
local usesPhysicsOutlines = true 
local topWallOutline
local bottomWallOutline
local isGameOver = false
local score = 0
local wallTimer
local highscore
local highscoreFile

-- Functions
local gameTick
local makeNewWall
local screenTouched
local playerCollision
local screenShake
local tryAgain
local gameCenter -- Wael Abed Elal

--local facebookButton

-----------------------------------------------
--*** Set up our sprites ***
-----------------------------------------------
-- Set up sprite sheets
local playerSequenceData = {name="player", start=1, count=3, time=200}
local playerSpriteSheet = graphics.newImageSheet(_G.randomPlayer, {width=34, height=24, numFrames=3, sheetContentWidth=102, sheetContentHeight=24})
local cloudSpriteSheet = graphics.newImageSheet("assets/cloud@2x.png", {width=128, height=71, numFrames=3, sheetContentWidth=384, sheetContentHeight=71})
local tapHintSequenceData = {name="tap", start=1, count=2, time=750}
local tapHintSpriteSheet = graphics.newImageSheet("assets/tap_hint@2x.png", {width=115, height=70, numFrames=2, sheetContentWidth=230, sheetContentHeight=70})

-- Display items
local player
local walls = {}
local floor
local scoreLabel
local gameOver = {}
local tryAgainButton
local gameCenterButton 
local background
local backgroundAlt
local tapHint

local muteTapped
local soundTapped
local soundButton
local muteButton
local homeButton
local facebookButton
local homeTapped

local backgrounds
local randomBackground

local newScore


--------------------------------------------
-- ** GAME CENTER STUFF ** ------------
--------------------------------------------

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.



function scene:create( event )
	local screenGroup = self.view
	
	banner:show()
	
	backgroundGroup = display.newGroup()
	wallGroup = display.newGroup()
	gameGroup = display.newGroup()
	screenGroup:insert(backgroundGroup)
	screenGroup:insert(wallGroup)
	screenGroup:insert(gameGroup)
	
	player = display.newSprite(gameGroup, playerSpriteSheet, playerSequenceData)
	player.x = _W / 4 
	player.y = _H / 2
	previousY = player.y
	player.xScale = -4.3
	player.yScale = 4.3
	player:setSequence("player")
	player:play()

	floor = display.newImageRect(gameGroup, "assets/floor@2x.png", 500, 100)
	floor.anchorX = 0
	floor.anchorY = 0
	floor.x = 0
	floor.y = _H - 70

	scoreLabel = bmf2.newString(myfont, "0")
	scoreLabel.x = _W /2
	scoreLabel.y = _H / 2 - 200
	
	background = display.newImageRect(backgroundGroup, _G.randomBackground, _W + 1, _H-10)
	background.anchorY = 1
	background.x = _W / 2
	background.y = _H - 10

	backgroundAlt = display.newImageRect(backgroundGroup, _G.randomBackground, _W + 1, _H-10)
	backgroundAlt.anchorY = 1
	backgroundAlt.x = 
	_W + _W / 2
	backgroundAlt.y = _H - 10

	tapHint = display.newSprite(gameGroup, tapHintSpriteSheet, tapHintSequenceData)
	tapHint.x = _W / 2 
	tapHint.y = _H / 2 + 20
	tapHint.xScale= 1.3
	tapHint.yScale = 1.8
	tapHint:play()
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:show( event )
	-- Completely remove the previous scene/all scenes.
    -- Handy in this case where we want to keep everything simple.
    storyboard.removeHidden()

	-- The gameTick is called every single frame.
	-- It controls all the background movement and the players rotation 
	gameTick = function (event)
		-- If the game has not started yet then move the player up and down in a sine wave
		if not hasGameStarted then
			player.y = _H / 2 + mSin(event.time / 200) * 15
		end

		-- Rotate the player depending on their position last frame
		player.rotation = mAtan2((player.y - previousY) / 25, 0.9) * -90 / mPi
		
		-- Save the player's Y position so that it can be used for rotation next frame
		previousY = player.y 

		-- Update the wall positions
		for i = 1, #walls do
			walls[i].top.x = walls[i].top.x - wallSpeed
			walls[i].bottom.x = walls[i].bottom.x - wallSpeed
			walls[i].sensor.x = walls[i].sensor.x - wallSpeed
		end

		-- Remove the wall if it has gone off screen
		if walls[1] and walls[1].top.x < 0 - walls[1].top.width then
			walls[1].top:removeSelf()
			walls[1].bottom:removeSelf()
			table.remove(walls, 1)
		end

		-- Update the floor position, %35 to make the floor look like it's repeating
		floor.x = (floor.x - wallSpeed) % 35 - 35

		-- Move the repeating background
		background:translate(-wallSpeed / 2, 0)
		backgroundAlt:translate(-wallSpeed / 2, 0)

		if background.x <= -_W/2 then
			background.x = backgroundAlt.x + _W - 3
		end
		if backgroundAlt.x <= -_W/2 then
			backgroundAlt.x = background.x + _W - 3
		end

	end

	makeNewWall = function (event)
		table.insert(walls, {})

		local randomWallPosition = math.random(0, _H - wallGapHeight - 150)
		walls[#walls].top = display.newImageRect(wallGroup, "assets/top_wall@2x.png", 80, 500)
		walls[#walls].top.x = _W + 100
		walls[#walls].top.y = 90 - (walls[#walls].top.height / 2) + randomWallPosition
		walls[#walls].top.xScale = 0.8
		walls[#walls].top.yScale = 0.8
		walls[#walls].bottom = display.newImageRect(wallGroup, "assets/bottom_wall@2x.png", 80, 500)
		walls[#walls].bottom.x = _W + 100
		walls[#walls].bottom.y = 400 - (walls[#walls].bottom.height / 2) + wallGapHeight + randomWallPosition
		walls[#walls].bottom.xScale = 0.8
		walls[#walls].bottom.yScale = 0.8
		
		
		walls[#walls].sensor = display.newLine(wallGroup, walls[#walls].top.x - 20 , walls[#walls].top.y , walls[#walls].bottom.x - 20, walls[#walls].bottom.y - 20)
		walls[#walls].sensor.alpha = 0
		walls[#walls].sensor.isSensor = true
		
		topWallOutline = {26, -196, 24, -132, -26, -132, -26, -196, -24, 196, -24, -132, 24, -132, 24, 196, 24, -132, 26, -196, 26, -132 }
		bottomWallOutline = {26, -196, 24, -132, -26, -132, -26, -196, -24, 156, -24, -132, 24, -132, 24, 156, 24, -132, 26, -156, 26, -132 }
		physics.addBody(walls[#walls].sensor, "static", {isSensor=true})
		physics.addBody(walls[#walls].bottom, "static", { density=3.0, friction=0.8, bounce=0.3 ,shape=bottomWallOutline})
		physics.addBody(walls[#walls].top, "static", { density=3.0, friction=0.8, bounce=0.3, shape=topWallOutline})
		
	end
	------------------------------
	screenTouched = function (event)
		if event.phase == "began" then
			if hasGameStarted then
				if not isGameOver then
					-- Don't flap if the player is close to the top of the screen
					if player.y > 50 then
						player:setLinearVelocity(0, -flapForce)
						playSound("flap")
					end
				end
			else
				-- Set up the player's physics
				physics.start()
				physics.setGravity(0, worldGravity)
				
				local flappy = { -63, -45, 40,-57, 56,-50, 50,55, -55,55, -55,-50, 63, 50, 55, 55, 60, 50 }
				physics.addBody( player, { density=3.0, friction=0.8, bounce=0.3, shape=flappy } )
				

				physics.setDrawMode( "normal" ) --set to hybrid to see the physics shapes.
				player:setLinearVelocity(0, -flapForce)
				playSound("flap")

				-- Start creating walls
				wallTimer = timer.performWithDelay(wallSpeedFrequency, makeNewWall, 0)

				physics.addBody(floor, "static")
				player:addEventListener("collision", playerCollision)

				-- Remove the tap hint
				tapHint:removeSelf()

				-- Start the game
				hasGameStarted = true
			end
		end

		return true
	end

	-- Controls the game over screen, as well as the score counter.
	playerCollision = function (event)
		if event.phase == "began" and not isGameOver then
			if not event.other.isSensor then
				-- Stop the game
				Runtime:removeEventListener("enterFrame", gameTick)
				Runtime:removeEventListener("touch", screenTouched)
				player:pause()
				isGameOver = true
				playSound("gameover")
				system.vibrate()
				function gvrSound()
					playSound("gameoverSound")
				end
				timer.performWithDelay(400, gvrSound)

				-- Make the screen shake
				timer.performWithDelay(20, screenShake, screenShakeDuration)

				-- Remove the score and show the game over screen
				scoreLabel:removeSelf();

				gameOver.gameOverImage = display.newImageRect(gameGroup, "assets/gameover@2x.png", 140, 90)
				gameOver.gameOverScoreboard = display.newImageRect(gameGroup, "assets/scoreboard@2x.png", 1, 1)
				tryAgainButton = display.newImageRect(gameGroup, "assets/play_button@2x.png", 80, 50)
				gameCenterButton = display.newImageRect(gameGroup, "assets/game_center@2x.png", 80, 50)	
				homeButton = display.newImageRect(gameGroup, "assets/homeButton@2x.png", 80, 50)

				
				gameOver.gameOverImage.x = _W / 2
				gameOver.gameOverImage.y = _H / 2 - 400
				gameOver.gameOverImage.alpha = 0
				gameOver.gameOverImage.xScale = 1.5
				gameOver.gameOverImage.yScale = 1.5

				gameOver.gameOverScoreboard.x = _W / 2
				gameOver.gameOverScoreboard.y = _H / 2
				gameOver.gameOverScoreboard.alpha = 0

				tryAgainButton.x = _W / 2 - 250
				tryAgainButton.y = _H / 2 + 110
				tryAgainButton.alpha = 0
				
				gameCenterButton.x = _W / 2 + 250
				gameCenterButton.y = _H / 2 + 110
				gameCenterButton.alpha = 0
				
				homeButton.x = _W / 2 
				homeButton.y = _H / 2 + 250
				homeButton.alpha = 0
				
				
				local function displayScores(event)
					-- Display the player's score and high score
					
					
					gameNetwork.request( "setHighScore",{ localPlayerScore = { category="FFLB1", value=score }, })
					
					

					gameOver.gameOverScoreLabel = display.newText({parent=gameGroup, text="" .. score, font=pixelFont, fontSize=17, width=200, align="center"})

					
					
					gameOver.gameOverHighScoreLabel = display.newText({parent=gameGroup, text="" .. highscore, font=pixelFont, fontSize=17, width=200, align="center"})
					gameOver.gameOverScoreLabel.x = _W / 2 + 50
					gameOver.gameOverScoreLabel.y = _H / 2 - 23
					gameOver.gameOverScoreLabel:setFillColor(0, 0, 0)

					gameOver.gameOverHighScoreLabel.x = _W / 2 + 50
					gameOver.gameOverHighScoreLabel.y = _H / 2 + 41
					gameOver.gameOverHighScoreLabel:setFillColor(0, 0, 0)
				if loggedIntoGC then 
					if score >= scores.chuckMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="6",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					elseif score >= scores.rainbowMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="5",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					elseif score >= scores.platinumMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="4",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					elseif score >= scores.goldMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="3",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					elseif score >= scores.silverMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="2",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					elseif score >= scores.bronzeMedalScore then
						gameNetwork.request( "unlockAchievement",
						{
    						achievement =
    						{
        						identifier="1",
        						percentComplete=100,
        						showsCompletionBanner=true,
    						},
    						listener=requestCallback
						})
					end
				end
					
					-- Give the player a medal if they scored enough
					if score >= scores.chuckMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/chuckMedal@2x.png", 41, 95.5)
					elseif score >= scores.rainbowMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/rainbowMedal@2x.png", 41, 95.5)
					elseif score >= scores.platinumMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/platinumMedal@2x.png", 41, 95.5)
					elseif score >= scores.goldMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/medal_gold@2x.png", 41, 95.5)
					elseif score >= scores.silverMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/medal_silver@2x.png", 41, 95.5)
					elseif score >= scores.bronzeMedalScore then
						gameOver.gameOverMedal = display.newImageRect(gameGroup, "assets/medal_bronze@2x.png", 41, 95.5)
					end
					
					if highscore == score then
						newScore =  display.newImageRect(gameGroup, "assets/new@2x.png", 30, 13)
					end
					
					if newScore then
						newScore.x = _W /2 + 3
						newScore.y = _H/2 + 18
					end
				
					
					if gameOver.gameOverMedal then
						gameOver.gameOverMedal.anchorY = 0
						gameOver.gameOverMedal.x = _W / 2 - 52
						gameOver.gameOverMedal.y = _H / 2 - gameOver.gameOverMedal.height / 2 + 1 

						gameOver.gameOverMedal.yScale = 0.1
						transition.to(gameOver.gameOverMedal, {yScale=1, time=100})
					end


					-- Add a touch event to the try again button
					tryAgainButton:addEventListener("touch", tryAgain)
					gameCenterButton:addEventListener("touch", gameCenter)
					homeButton:addEventListener("touch", homeTapped)
					--facebookButton:addEventListener("touch", facebookTapped)
				end
				

				-- Transition in the game over screen
				local transitionDelay = 1000
				local transitionTime = 300
				transition.to(gameOver.gameOverImage, {alpha=1, y=_H/2-140, time=transitionTime, delay=transitionDelay})
				transition.to(gameOver.gameOverScoreboard, {alpha=1, xScale =200 , yScale =150 , time=transitionTime, delay=transitionDelay})
				transition.to(tryAgainButton, {alpha=1, x= _W/2-50, time=transitionTime, delay=transitionDelay})
				transition.to(gameCenterButton, {alpha=1, x= _W/2+50, time=transitionTime, delay=transitionDelay})
				transition.to(homeButton, {alpha=1, y= _H/2+170, time=transitionTime, delay=transitionDelay})
				--[[if _W < 500 and _H < 500 then
					transition.to(facebookButton, {alpha=1, y= _H/2+215, time=transitionTime, delay=transitionDelay})
				elseif _W < 800 and _H < 980 then
					transition.to(facebookButton, {alpha=1, y= _H/2+255, time=transitionTime, delay=transitionDelay})
				else
					transition.to(facebookButton, {alpha=1, y= _H/2+220, time=transitionTime, delay=transitionDelay})
				end--]]
				timer.performWithDelay(transitionDelay + transitionTime, displayScores)
				-- Stop creating new walls
				timer.cancel(wallTimer)

				-- Update the highscore
				if score > highscore then
					highscoreFile = io.open(system.pathForFile("highscore", system.DocumentsDirectory), "w")
					highscore = score
					highscoreFile:write("" .. score)
					highscoreFile:close()
					highscoreFile = nil
				end
			end
		elseif event.phase == "ended" and not isGameOver then
			if event.other.isSensor then
				score = score + 1
					scoreLabel.text =  "" .. score 
					if score >= 100 then
						scoreLabel.x = _W /2 - 25
					elseif score >= 10 then
						scoreLabel.x = _W /2 - 20
					end
				playSound("score")
				
			end
		end
	end

	-- This function is called when you collide with either the walls or the floor. 
	screenShake = function (event)
		if event.count == screenShakeDuration then
			-- Reset the screen's position
			self.view.x = 0
			self.view.y = 0
		else
			-- Move the screen around randomly
			self.view.x = math.random(-screenShakeIntensity, screenShakeIntensity)
			self.view.y = math.random(-screenShakeIntensity, screenShakeIntensity)
		end
	end

	-- Reset the game and start again
	
	
	homeTapped = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.y = t.y + 3
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.y = t.y - 3

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
					-- Hide the ad

					playSound("select")

					-- Remove the game over screen
					if gameOver.gameOverMedal then
						gameOver.gameOverMedal:removeSelf();
						gameOver.gameOverMedal = nil
					end
					gameOver.gameOverScoreboard:removeSelf();
					gameOver.gameOverScoreboard = nil
					gameOver.gameOverImage:removeSelf();
					gameOver.gameOverImage = nil
					gameOver.gameOverScoreLabel:removeSelf();
					gameOver.gameOverScoreLabel = nil
					gameOver.gameOverHighScoreLabel:removeSelf();
					gameOver.gameOverHighScoreLabel = nil
					tryAgainButton:removeSelf();
					tryAgainButton = nil
					gameCenterButton:removeSelf();
					homeButton:removeSelf();
					homeButton = nil
					if newScore then
						newScore:removeSelf()
						newScore = nil
					end

					-- Move the player back to the starting place
					previousY = player.y
					player.rotation = 0

					storyboard.gotoScene("menu", fade)
				end
			end
		end
		return true
	end
	
	tryAgain = function (event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.y = t.y + 3
			t.alpha = 0.8
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				t.y = t.y - 3

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
					-- Hide the ad

					playSound("select")

					-- Remove the game over screen
					if gameOver.gameOverMedal then
						gameOver.gameOverMedal:removeSelf();
						gameOver.gameOverMedal = nil
					end
					gameOver.gameOverScoreboard:removeSelf();
					gameOver.gameOverScoreboard = nil
					gameOver.gameOverImage:removeSelf();
					gameOver.gameOverImage = nil
					gameOver.gameOverScoreLabel:removeSelf();
					gameOver.gameOverScoreLabel = nil
					gameOver.gameOverHighScoreLabel:removeSelf();
					gameOver.gameOverHighScoreLabel = nil
					tryAgainButton:removeSelf();
					tryAgainButton = nil
					gameCenterButton:removeSelf();
					homeButton:removeSelf();
					homeButton = nil
					if newScore then
						newScore:removeSelf()
						newScore = nil
					end

					scoreLabel = bmf2.newString(myfont, "0")
					scoreLabel.x = _W /2
					scoreLabel.y = 100
					-- Move the player back to the starting place
					player.x = _W / 4
					player.y = _H / 2
					previousY = player.y
					player.rotation = 0
					player:play()
					player:setLinearVelocity(0, 0)
					player:removeEventListener("collision", playerCollision)
					
					isGameOver = false
					hasGameStarted = false
					score = 0

					-- Add back the game event listeners
					Runtime:addEventListener("touch", screenTouched)
					Runtime:addEventListener("enterFrame", gameTick)

					-- Remove physics from the player
					physics.removeBody(player)

					-- Delete all walls
					for i = #walls, 1, -1 do
						walls[i].top:removeSelf()
						walls[i].bottom:removeSelf()
						walls[i].sensor:removeSelf()
						walls[i] = nil
					end
				

					-- Show the tap hint again
					tapHint = display.newSprite(gameGroup, tapHintSpriteSheet, tapHintSequenceData)
					tapHint.x = _W / 2 
					tapHint.y = _H / 2 + 20
					tapHint.xScale= 1.3
					tapHint.yScale = 1.8
					tapHint:play();
				end
			end
		end
		return true
	end
	
	
	

gameCenter = function( event )
    local t = event.target
	if event.phase == "began" then 
            display.getCurrentStage():setFocus( t )
            t.isFocus = true
            t.y = t.y + 3
			t.alpha = 0.8
	elseif t.isFocus then 
            if event.phase == "ended"  then 
                display.getCurrentStage():setFocus( nil )
		t.isFocus = false
		t.alpha = 1
		t.y = t.y - 3
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
end

local json = require( "json" )
--[[
local function fblistener( event )

    print( "event.name", event.name )  --"fbconnect"
    print( "event.type:", event.type ) --type is either "session", "request", or "dialog"
    print( "isError: " .. tostring( event.isError ) )
    print( "didComplete: " .. tostring( event.didComplete ) )

    --"session" events cover various login/logout events
    --"request" events handle calls to various Graph API calls
    --"dialog" events are standard popup boxes that can be displayed

    if ( "session" == event.type ) then
        --options are: "login", "loginFailed", "loginCancelled", or "logout"
        if ( "login" == event.phase ) then
            local access_token = event.token
            --code for tasks following a successful login
        end

    elseif ( "request" == event.type ) then
        print("facebook request")
        if ( not event.isError ) then
            local response = json.decode( event.response )
            --process response data here
        end

    elseif ( "dialog" == event.type ) then
        print( "dialog", event.response )
        --handle dialog results here
    end
end--]]
--[[
facebookTapped = function( event )
    local t = event.target
	if event.phase == "began" then 
            display.getCurrentStage():setFocus( t )
            t.isFocus = true
            t.y = t.y + 3
			t.alpha = 0.8
	elseif t.isFocus then 
            if event.phase == "ended"  then 
                display.getCurrentStage():setFocus( nil )
		t.isFocus = false
		t.alpha = 1
		t.y = t.y - 3
		--Check bounds. If we are in it then click!
		local b = t.contentBounds
                    if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
                    	playSound("select")
                    	facebook.login( "501790179948842", fblistener, { "publish_actions" } )
                    	facebook.request( "me/feed", "POST", { message="I just scored " .. score .. " in Fancy Flap, can you beat me?!" } )
						
                    end
            end
        end
end
--]]
--native.showAlert("Success", "Message successfuly posted!", {"OK"});
	

	-- Get the current highscore
	highscoreFile = io.open(system.pathForFile("highscore", system.DocumentsDirectory), "r")
	highscore = tonumber(highscoreFile:read("*a"))
	highscoreFile:close()
	highscoreFile = nil

	-- Add the event listeners
	Runtime:addEventListener("touch", screenTouched)
	Runtime:addEventListener("enterFrame", gameTick)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:destroy( event )
	if wallTimer ~= nil then timer.cancel( wallTimer ); wallTimer=nil; end 
	Runtime:removeEventListener("touch", screenTouched)
	Runtime:removeEventListener("enterFrame", gameTick)
end


-----------------------------------------------
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "destroy", scene )

return scene