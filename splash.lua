local storyboard = require("composer")
local scene = storyboard.newScene()
local splashScreen

function scene:create(event)
	-- splash screen
	local grp = self.view
	local _W = display.contentWidth
	local _H = display.contentHeight
	splashScreen = display.newImageRect("Default-568h@2x.png", _W, _H)
	splashScreen.x = _W / 2
	splashScreen.y = _H / 2 
	grp:insert( splashScreen )
	-- end
end

function scene:show(event)
	local function toMenu()
		local options = {
			effect = "crossFade",
			time = 1000
		}
		display.setDefault("background", 75, 181, 191)
		storyboard.gotoScene("menu", options)
	end
	timer.performWithDelay( 1000, toMenu )
end

function scene:destroy(event)
	print("exit")
end

scene:addEventListener( "create", scene)
scene:addEventListener( "destroy", scene)
scene:addEventListener( "show", scene)
return scene