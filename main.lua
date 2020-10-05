-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
Class = require 'class'

-- Require animation class
require 'animation'

-- Require enemy class
require 'enemy'


-- Require my custom implementation of a level
require 'level'

-- Require engine class
require 'engine'

-- Library to tween (interpolate) between values
flux = require 'flux'

WINDOW_WIDTH = 960
WINDOW_HEIGHT = 600

VIRTUAL_WIDTH = 320
VIRTUAL_HEIGHT = 200

keyboard = {}

logo = {}
logo.logox = 10
logo.logoy = -100
logo.size = 0.4
info = {}
info.y1 = 250
info.y2 = 250

winnerbar = {}
winnerbar.y = -100
winnerbar.x = 50
winnerbar.size = 0.6

attackicon1 = {}
attackicon1.x = VIRTUAL_WIDTH / 2 - 82
attackicon1.y = VIRTUAL_HEIGHT

attackicon2 = {}
attackicon2.x = VIRTUAL_WIDTH / 2 - 24
attackicon2.y = VIRTUAL_HEIGHT

attackicon3 = {}
attackicon3.x = VIRTUAL_WIDTH / 2 + 34
attackicon3.y = VIRTUAL_HEIGHT

selectedicon = {}
selectedicon.enabled = false
selectedicon.index = -1
selectedicon.y = VIRTUAL_HEIGHT - 70


mainbanner = {}
banner3 = {}
banner3.y = VIRTUAL_HEIGHT/2 - 40
banner3.x = VIRTUAL_WIDTH/2
banner3.yoff = 45
banner3.xoff  = 45
banner3.size = 0.1

banner2 = {}
banner2.y = VIRTUAL_HEIGHT/2 - 40
banner2.x = VIRTUAL_WIDTH/2
banner2.yoff = 45
banner2.xoff  = 45
banner2.size = 0.1

banner1 = {}
banner1.y = VIRTUAL_HEIGHT/2 - 40
banner1.x = VIRTUAL_WIDTH/2
banner1.yoff = 45
banner1.xoff  = 45
banner1.size = 0.1

bannergo = {}
bannergo.y = VIRTUAL_HEIGHT/2 - 40
bannergo.x = VIRTUAL_WIDTH/2
bannergo.yoff = 45
bannergo.xoff  = 64
bannergo.size = 0.1

changecounter = 0

MainLevel = nil
MainEngine = nil

currentlevel = 0 --first level
accumulatedtime = 0--total time
youwin = false

-- attach vs code debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

--profiler
local profile = require("profile")

function lerp(a,b,t) 
	return (1-t)*a + t*b 
end


--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Build Engine Tribute - by Cristian Villalba')
	love.window.setIcon(love.image.newImageData('items/icon/icon.png'))

    -- "seed" the RNG so that calls to random are always random
    -- use the current time, since that will vary on startup every time
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['hit'] = love.audio.newSource('sounds/effects/hit.ogg', 'static'),
        ['jump'] = love.audio.newSource('sounds/effects/jump_08.wav', 'static'),
        ['shot'] = love.audio.newSource('sounds/effects/shuriken.wav', 'static'),
		['shield'] = love.audio.newSource('sounds/effects/shield.ogg', 'static'),
		['win'] = love.audio.newSource('sounds/effects/won.wav', 'static'),
		['flag'] = love.audio.newSource('sounds/effects/flagpickup.ogg', 'static'),
		['select'] = love.audio.newSource('sounds/effects/select.ogg', 'static'),
		['fast'] = love.audio.newSource('sounds/effects/fast.ogg', 'static'),
		['counter'] = love.audio.newSource('sounds/effects/counter.ogg', 'static'),
		['go'] = love.audio.newSource('sounds/effects/go.ogg', 'static'),
		
		['music'] = love.audio.newSource('sounds/music/sword-metal.ogg', 'static')
		
    }

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
	
	--load Main logo
	logo.texture = love.graphics.newImage('items/logo/pipiv2.png')
	flux.to(logo, 1.0, {logoy = 10}):ease('elasticout'):oncomplete(playEffect):after(info, 1.0, { y1 = VIRTUAL_HEIGHT / 2 + 50}):ease('elasticout'):oncomplete(playEffect):after(info, 1.0, { y2 = VIRTUAL_HEIGHT / 2 + 60}):ease('elasticout')
	sounds['fast']:play()
	
	--load Winner bar
	winnerbar.texture = love.graphics.newImage('items/win/youwin.png')
	
	--load attackicons
	attackicon1.texture = love.graphics.newImage('items/attacks/01.png')
	attackicon2.texture = love.graphics.newImage('items/attacks/02.png')
	attackicon3.texture = love.graphics.newImage('items/attacks/03.png')
	selectedicon.texture = love.graphics.newImage('items/attacks/selected.png')
	
	
	--load banners
	mainbanner[0] = banner3
	mainbanner[1] = banner2
	mainbanner[2] = banner1
	mainbanner[3] = bannergo
	banner3.texture = love.graphics.newImage('items/counter/3.png')
	banner2.texture = love.graphics.newImage('items/counter/2.png')
	banner1.texture = love.graphics.newImage('items/counter/1.png')
	bannergo.texture = love.graphics.newImage('items/counter/go.png')

	--load timer font
	timerFont = love.graphics.newImageFont("items/timer/timerv4.png","1234567890:")
	
	if (currentlevel == -1) then
		--load rand level
		--MainLevel = Level(1, currentlevel) --initialize random level
		MainLevel = Level(1, -1) --initialize demo level
		MainEngine = Engine()
		MainEngine:setAttackMode(2)
		PLAYER_X = -1.25
		PLAYER_Y = -0.5
		
		--PLAYER_X = -1.25
		--PLAYER_Y = -4.00
		--DIR_X = -0.041072827399203
		--DIR_Y = 0.99915615538785
		--CAM_X_PLANE = -0.65944306255598
		--CAM_Y_PLANE = -0.027108066083476
				
		localtimer = love.timer.getTime()
		
		gameState = 'game' --go directly to game
	elseif (currentlevel == -2) then
		MainLevel = Level(1, -2) --initialize level from file
		MainEngine = Engine()
		MainEngine:setAttackMode(2)
		PLAYER_X = -1.25
		PLAYER_Y = -0.5
		localtimer = love.timer.getTime()

		gameState = 'game' --go directly to game
	else
		--load introductory level
		MainLevel = Level(0, -1) --initialize introduction level
		MainEngine = Engine()
				
		gameState = 'welcome'
	end
	
	--background music
	sounds['music']:setVolume(0.5)
	sounds['music']:setLooping(true)
	sounds['music']:play()
end

--[[
    Called by LÖVE whenever we resize the screen; here, we just want to pass in the
    width and height to push so our virtual resolution can be resized as needed.
]]
function love.resize(w, h)
    push:resize(w, h)
end


-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
	if gameState == 'welcome' and key == 'escape' then
		love.event.quit()
    end
	
	--if key == 'u' then
	--	profile.stop()
	--	print(profile.report(40))
	--end
	
	--if key == 'y' then
	--	profile.start()
	--end
	
	if (gameState == 'waiting') then
		if selectedicon.enabled == true then
			if key == '1' then
				selectedicon.index = 1
				sounds['select']:play()
			end
			if key == '2' then
				selectedicon.index = 2
				sounds['select']:play()
			end
			if key == '3' then
				selectedicon.index = 3
				sounds['select']:play()
			end
		end
	end
	
	if gameState == 'game' then
		if key == 'escape' then		
			currentlevel = 0
			accumulatedtime = 0
			youwin = false
			MainLevel = nil
			MainEngine = nil
			selectedicon.enabled = false
			selectedicon.index = -1
			selectedicon.y = VIRTUAL_HEIGHT - 70
			CURR_Z = 0
			
			--load Main logo
			logo.texture = love.graphics.newImage('items/logo/pipiv2.png')
			flux.to(logo, 1.0, {logoy = 10}):ease('elasticout'):oncomplete(playEffect):after(info, 1.0, { y1 = VIRTUAL_HEIGHT / 2 + 50}):ease('elasticout'):oncomplete(playEffect):after(info, 1.0, { y2 = VIRTUAL_HEIGHT / 2 + 60}):ease('elasticout')
			sounds['fast']:play()
		
			--load banners
			mainbanner[0] = banner3
			mainbanner[1] = banner2
			mainbanner[2] = banner1
			mainbanner[3] = bannergo
			banner3.size = 0.1
			banner2.size = 0.1
			banner1.size = 0.1
			bannergo.size = 0.1
			
			--load introductory level
			MainLevel = Level(0, -1) --initialize introduction level
			MainEngine = Engine()
			
			gameState = 'welcome'
		end
    end
	
	if gameState == 'welcome' and  key == 'return' then
		
		MainLevel = nil
		MainEngine = nil
		
		--load a random level
		MainLevel = Level(1, currentlevel)
		MainEngine = Engine()
		
		flux.to(logo, 0.5, {logoy = -150}):ease('elasticin')
		flux.to(info, 0.5, { y1 = 250}):ease('elasticin')
		flux.to(info, 0.5, { y2 = 250 }):ease('elasticin'):oncomplete(waitingBanner)
		
		changeCounter = 0
		gameState = 'waiting'
		
		sounds['select']:play()
				
    end

    love.keyboard.keysPressed[key] = true
end

function playEffect()
	sounds['fast']:play()
end

function playCounter()
	sounds['counter']:play()
end

function playGo()
	sounds['go']:play()
end

function waitingBanner()

	flux.to(banner3, 1.0, {size = 1.5}):ease('elasticout'):onstart(playCounter):oncomplete(removeNumber)
	flux.to(banner2, 1.0, {size = 1.5}):ease('elasticout'):onstart(playCounter):delay(1):oncomplete(removeNumber)
	flux.to(banner1, 1.0, {size = 1.5}):ease('elasticout'):onstart(playCounter):delay(2):oncomplete(removeNumber)
	flux.to(bannergo, 1.0, {size = 1.5}):ease('elasticout'):onstart(playGo):delay(3):after(bannergo, 0.5, {size = 0.01}):oncomplete(removeNumber):oncomplete(startGame)
	
	flux.to(attackicon1, 0.5, {y = VIRTUAL_HEIGHT - 70}):ease('elasticout'):oncomplete(enableSelection):after(attackicon1, 1.0, {y = VIRTUAL_HEIGHT + 10}):ease('elasticout'):delay(3.5)
	flux.to(attackicon2, 0.5, {y = VIRTUAL_HEIGHT - 70}):ease('elasticout'):after(attackicon2, 1.0, {y = VIRTUAL_HEIGHT + 10}):ease('elasticout'):delay(3.5)
	flux.to(attackicon3, 0.5, {y = VIRTUAL_HEIGHT - 70}):ease('elasticout'):after(attackicon3, 1.0, {y = VIRTUAL_HEIGHT + 10}):ease('elasticout'):delay(3.5)
end

function enableSelection()
	selectedicon.enabled = true
end

function removeNumber()
	mainbanner[changeCounter] = nil
	changeCounter = changeCounter + 1
	
	if (changeCounter == 3) then
		if (selectedicon.index == -1) then
			selectedicon.index = love.math.random(1 , 3)
		end
		flux.to(selectedicon, 0.5, {y = VIRTUAL_HEIGHT + 10}):delay(0.5):ease('elasticout')
	end
end

function startGame()
	gameState = 'game'
	MainEngine:setAttackMode(selectedicon.index)
	localtimer = love.timer.getTime()
end

function afterWin()
	gameState = 'game'
	selectedicon.index = 2 --force to jump in "final" level
	MainEngine:setAttackMode(selectedicon.index)
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end


--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
	flux.update(dt)
	
	MainEngine:update(gameState, dt)
end


--[[
    Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]
function love.draw()
	
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
	
	Engine:draw()
	
	if gameState == 'welcome' then
		--reset color
		love.graphics.setColor(1, 1 , 1, 1)
		
		love.graphics.setFont(smallFont)
        love.graphics.printf('CEV Games 2020 - cristian.villalba@gmail.com', 0, info.y1, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press enter to start!', 0, info.y2, VIRTUAL_WIDTH, 'center')
		
		love.graphics.draw(logo.texture, logo.logox, logo.logoy, 0, logo.size, logo.size, 0, 0, 0, 0 )
	end
	
	if gameState == 'waiting' then
		--reset color
		love.graphics.setColor(1, 1 , 1, 1)
		
		for n in pairs(mainbanner) do
			if mainbanner[n] ~= nil  and n <= changeCounter then
				love.graphics.draw(mainbanner[n].texture, mainbanner[n].x, mainbanner[n].y, 0, mainbanner[n].size, mainbanner[n].size, mainbanner[n].xoff, mainbanner[n].yoff, 0, 0 )
			end
		end
		
		--attackicons
		love.graphics.draw(attackicon1.texture, attackicon1.x, attackicon1.y, 0, attackicon1.size, attackicon1.size, 0, 0, 0, 0 )
		love.graphics.draw(attackicon2.texture, attackicon2.x, attackicon2.y, 0, attackicon2.size, attackicon2.size, 0, 0, 0, 0 )
		love.graphics.draw(attackicon3.texture, attackicon3.x, attackicon3.y, 0, attackicon3.size, attackicon3.size, 0, 0, 0, 0 )
		
		if selectedicon.enabled == true then 
			if (selectedicon.index == 1) then
				love.graphics.draw(selectedicon.texture, VIRTUAL_WIDTH/2 - 82, selectedicon.y, 0, selectedicon.size, selectedicon.size, 0, 0, 0, 0 )
			elseif (selectedicon.index == 2) then
				love.graphics.draw(selectedicon.texture, VIRTUAL_WIDTH/2 - 24, selectedicon.y, 0, selectedicon.size, selectedicon.size, 0, 0, 0, 0 )
			elseif (selectedicon.index == 3) then
				love.graphics.draw(selectedicon.texture, VIRTUAL_WIDTH/2 + 34, selectedicon.y, 0, selectedicon.size, selectedicon.size, 0, 0, 0, 0 )
			end
		end
	end
	
	if gameState == 'game' then
		--reset color
		love.graphics.setColor(1, 1 , 1, 1)
		love.graphics.setFont(timerFont)
        love.graphics.printf(currentTimer(), 0, 15, VIRTUAL_WIDTH, 'center')
	end
	
	if gameState == 'winner' then
		--reset color
		love.graphics.setColor(1, 1 , 1, 1)
		love.graphics.draw(winnerbar.texture, winnerbar.x, winnerbar.y, 0, winnerbar.size, winnerbar.size, 0, 0, 0, 0 )
	end
	
    --displayFPS()


    push:apply('end')
end

function currentTimer()
	local timediff = (love.timer.getTime() - localtimer) * 1000 --time difference in miliseconds
	
	if (youwin == false) then
		timediff = timediff + accumulatedtime --add time from other levels
	else
		timediff = accumulatedtime
	end
	
	local totalseconds = timediff/1000
	local totalminutes = math.floor(totalseconds / 60) 
	local totalhours = math.floor(totalminutes / 60)
	
	local finalseconds = math.floor(totalseconds % 60)
	local finalminutes = math.floor(totalminutes % 60)
	
	if (finalseconds >= 60) then
		finalseconds = 0
	end
	
	if (finalminutes >= 60) then
		finalminutes = 0
	end
	
	local finalstring  = string.format('%02d', totalhours) .. ':'.. string.format('%02d', finalminutes) .. ':' 
	                     .. string.format('%02d', finalseconds) .. ':' .. string.format('%03d', timediff%1000)
	
	return finalstring
end

function advanceLevel()

	if (youwin == false) then
		accumulatedtime = accumulatedtime + (love.timer.getTime() - localtimer) * 1000 --time difference in miliseconds
	end
	
	MainLevel = nil
	MainEngine = nil
	
	--selectionicon
	selectedicon.enabled = false
	selectedicon.y = VIRTUAL_HEIGHT - 70
	
	--load banners
	mainbanner[0] = banner3
	mainbanner[1] = banner2
	mainbanner[2] = banner1
	mainbanner[3] = bannergo
	banner3.size = 0.1
	banner2.size = 0.1
	banner1.size = 0.1
	bannergo.size = 0.1
	
	--load next level
	currentlevel = currentlevel + 1
	MainLevel = Level(1, currentlevel)
	MainEngine = Engine()
	
	if (currentlevel == 11) then
		flux.to(winnerbar, 2.0, {y = 10}):ease('elasticout'):after(winnerbar, 2.0, {y = -100}):ease('elasticout'):oncomplete(afterWin)
		changeCounter = 0
		gameState = 'winner'
		youwin = true
		
		sounds['win']:play()
	else
		flux.to(logo, 0.5, {logoy = -150}):ease('elasticin')
		flux.to(info, 0.5, { y1 = 250}):ease('elasticin')
		flux.to(info, 0.5, { y2 = 250 }):ease('elasticin'):oncomplete(waitingBanner)
		
		changeCounter = 0
		gameState = 'waiting'
		
		sounds['flag']:play()
	end
	
	
	
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
