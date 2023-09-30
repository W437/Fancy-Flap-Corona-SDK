
-- Initial Settings
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning


local storyboard = require( "composer" )



-- Seed the random number generator
math.randomseed( os.time() )

------

local sounds = {}
sounds["select"] = audio.loadSound("sounds/select.caf")
sounds["flap"] = audio.loadSound("sounds/flap.caf")
sounds["score"] = audio.loadSound("sounds/point.mp3")
sounds["gameover"] = audio.loadSound("sounds/hit.caf")
sounds["gameoverSound"] = audio.loadSound("sounds/die.caf")
audio.setVolume(1, {channel = 1})
audio.setVolume(0.5, {channel = 2})
audio.setVolume(1, {channel = 3})
audio.setVolume(1, {channel = 4})
audio.setVolume(1, {channel = 5})

if audio.supportsSessionProperty == true then
	print("supportSessionProperty is true")
	audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

function playSound(name) 
	if name == "flap" then
		audio.stop(1)
		audio.play(sounds["flap"], {channel=1})
	elseif name == "score" then
		audio.stop(2)
		audio.play(sounds["score"], {channel=2})
	elseif name == "gameover" then
		audio.stop(3)
		audio.play(sounds["gameover"], {channel=3})
	elseif name == "select" then
		audio.stop(4)
		audio.play(sounds["select"], {channel=4})
	elseif name == "gameoverSound" then
		audio.stop(5)
		audio.play(sounds["gameoverSound"], {channel=5})
	end
end


--



-- Set up global variables
-- Android needs the file name and not the font name!
pixelFont = "AdvoCut"

local bannerId = "53d67cfb7c0d14d3066f6638"
local fullscreenId = "53d67cfb7c0d14d3066f663a"

--AdMob controls. Global functions so we can easily access them.
--NOTE: Replace adMobId with your own AdMob app id. Ads don't work in the simulator so you will have to 
--build to device or xcode. They will not show up with an invalid adMobId. 
RevMob = require("revmob")
REVMOB_IDS = { ["Android"] = "xxxxx", ["iPhone OS"] = "53d67cfb7c0d14d3066f6636" }
RevMob.startSession(REVMOB_IDS)
--RevMob.setTestingMode(RevMob.TEST_WITH_ADS)

--[[ bannerId = "53d67cfb7c0d14d3066f6638"
fullscreenId = "53d67cfb7c0d14d3066f663a" --]]
fullscreen = RevMob.createFullscreen(revmobListener)
banner = RevMob.createBanner( {x = display.contentWidth / 2, y = display.contentHeight / 2 , width = 320, height = 60 }, {listener = revmobListener })

revmobListener = function(event)
  print("Event: " .. event.type)
end


local gameNetwork = require "gameNetwork"
local loggedIntoGC
_G.loggedIntoGC = false

local function initCallback( event )
    if event.data then
        _G.loggedIntoGC = true
        gameNetwork.request( "loadScores", 
            { leaderboard={ category="FFLB1", 
            playerScope="Global", timeScope="AllTime", range={1,99} },
            listener=requestCallback } )
    else
        _G.loggedIntoGC = false
    end
end

-- function to listen for system events
local function onSystemEvent( event ) 
    if event.type == "applicationStart" then
        gameNetwork.init( "gamecenter", initCallback )
        return true
    end
end
--[[
local monitorMem = function()

    collectgarbage()
    print( "MemUsage: " .. collectgarbage("count") )

    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
    print( "TexMem:   " .. textMem )
end

Runtime:addEventListener( "enterFrame", monitorMem )
--]]


Runtime:addEventListener( "system", onSystemEvent )

-- Now change scene to go to the menu.
-- Now change scene to go to the menu.
storyboard.gotoScene( "game", "crossFade", 1 )
