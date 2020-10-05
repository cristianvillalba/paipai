--[[
    This is CS50 2019.
    Final Project

    -- Engine Class --

    Author: Cristian Villalba
    cristian.villalba@gmail.com
]]

bit = require('bit')

PLAYER_X = 0
PLAYER_Y = 0
DIR_X = 0
DIR_Y = -1
CAM_X_PLANE = 0.66
CAM_Y_PLANE = 0
LAST_SECTOR_ID = 0
ACCEL = 20.0
MAXVEL = 4.5
DISTANCE_TO_WALL = 9999
COL_RADIUS = 0.15
HORIZ = 0
BOTTOMVIEW = 0
CURR_Z = 0
SLOPE = 0

alreadyvisited = {}
collisionsectors = {}
bunchstack = {}


VELOCITY_X = 0
VELOCITY_Y = 0
LAST_MOVE = 0
CANT_MOVE = 0

ISFIRING = false
SHIELD = nil
SHURIKENID = nil
ATTACKTYPE = 0

--constants for jumping
GRAVITY = -0.98
INITIALVEL = 0.245
MAXJUMPTIME = 0.5

ZBUFFER = {}

Engine = Class{}

-- Vertex shader which uses the InstancePosition vertex attribute.
PIXELSHADER = love.graphics.newShader([[
#ifdef VERTEX
attribute vec2 InstancePosition;
attribute vec4 InstanceColor;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
	vertex_position.xy += InstancePosition;
	VaryingColor = InstanceColor;
	return transform_projection * vertex_position;
}
#endif
]])

function Engine:init()
	PLAYER_X = 0
	PLAYER_Y = 0
	DIR_X = 0
	DIR_Y = -1
	CAM_X_PLANE = 0.66
	CAM_Y_PLANE = 0
	LAST_SECTOR_ID = 0
	ACCEL = 20.0
	MAXVEL = 4.5
	DISTANCE_TO_WALL = 9999
	COL_RADIUS = 0.15

	alreadyvisited = {}
	collisionsectors = {}
	bunchstack = {}


	VELOCITY_X = 0
	VELOCITY_Y = 0
	LAST_MOVE = 0
	CANT_MOVE = 0

	ZBUFFER = {}
	
	self.localtime = 0 --variables to draw force shield
	self.maxtime = MAXJUMPTIME --variables to draw force shield
	self.fire = false --variables to draw force shield
	self.attacktype = 0
	
end

function Engine:rotateCam(dir,tpf)
	rad = tpf * 2
	
	if dir == 'left' then
		--rad = -1 * tpf
		
		NEWDIR_X = DIR_X * math.cos(rad) + DIR_Y * math.sin(rad) 
		NEWDIR_Y = -DIR_X * math.sin(rad) + DIR_Y * math.cos(rad)
		NEWCAM_X_PLANE = CAM_X_PLANE * math.cos(rad) + CAM_Y_PLANE * math.sin(rad) 
		NEWCAM_Y_PLANE = -CAM_X_PLANE * math.sin(rad) + CAM_Y_PLANE * math.cos(rad) 
		
	elseif dir == 'right' then
		--rad = 1 * tpf
		
		NEWDIR_X = DIR_X * math.cos(rad) - DIR_Y * math.sin(rad) 
		NEWDIR_Y = DIR_X * math.sin(rad) + DIR_Y * math.cos(rad)
		NEWCAM_X_PLANE = CAM_X_PLANE * math.cos(rad) - CAM_Y_PLANE * math.sin(rad) 
		NEWCAM_Y_PLANE = CAM_X_PLANE * math.sin(rad) + CAM_Y_PLANE * math.cos(rad) 
	
	end
	
	DIR_X = NEWDIR_X
	DIR_Y = NEWDIR_Y
	CAM_X_PLANE = NEWCAM_X_PLANE
	CAM_Y_PLANE = NEWCAM_Y_PLANE
	
end

function Engine:strafe(dir,tpf)
	rate = 0
	
	if (dir == 1) then
		NEWVELOCITYX = VELOCITY_X - ACCEL * tpf * CAM_X_PLANE
		NEWVELOCITYY = VELOCITY_Y - ACCEL * tpf * CAM_Y_PLANE
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY
		end
	else
		NEWVELOCITYX = VELOCITY_X + ACCEL * tpf * CAM_X_PLANE
		NEWVELOCITYY = VELOCITY_Y + ACCEL * tpf * CAM_Y_PLANE
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY
		end
	end
end

function Engine:foward(val, tpf)
	
	if val == 1 then
		NEWVELOCITYX = VELOCITY_X + ACCEL * tpf * DIR_X
		NEWVELOCITYY = VELOCITY_Y + ACCEL * tpf * DIR_Y
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY		
		end
	elseif val == -1 then
		NEWVELOCITYX = VELOCITY_X - ACCEL * tpf * DIR_X
		NEWVELOCITYY = VELOCITY_Y - ACCEL * tpf * DIR_Y
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY
		end
	elseif val == -2 then --slide movement
		NEWVELOCITYX = VELOCITY_X + ACCEL * tpf * SLIDE_X
		NEWVELOCITYY = VELOCITY_Y + ACCEL * tpf * SLIDE_Y
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY		
		end
	end
end

function Engine:pushPlayer(pushtype, dirx, diry, tpf)
	
	if (pushtype == 0) then
		NEWVELOCITYX = VELOCITY_X + ACCEL * tpf * (dirx - PLAYER_X)
		NEWVELOCITYY = VELOCITY_Y + ACCEL * tpf * (diry - PLAYER_Y)
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL*1.5) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY		
		end
	end
	
	if (pushtype == 1) then
		if (ATTACKTYPE == 0 or ATTACKTYPE == 2 or (ATTACKTYPE == 1 and self.fire == false)) then --cant push if player is jumping
			NEWVELOCITYX = VELOCITY_X + ACCEL * tpf * dirx
			NEWVELOCITYY = VELOCITY_Y + ACCEL * tpf * diry
		end
		
		if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < MAXVEL*1.5) then
			VELOCITY_X = NEWVELOCITYX
			VELOCITY_Y = NEWVELOCITYY		
		end
		
		if (ATTACKTYPE == 0 and self.fire == true) then --if player is performing a shield
			self.fire = false
			ISFIRING = false
			SHIELD = nil
		end
	end
	
	sounds['hit']:play()
end

function Engine:updatePos(tpf)
	--simulate friction
	--meaning that every tick the velocity should decrease
	NEWVELOCITYX = VELOCITY_X  * 0.9 --simulate friction 
	NEWVELOCITYY = VELOCITY_Y  * 0.9 --simulate friction 
	
	if (math.sqrt(NEWVELOCITYX * NEWVELOCITYX + NEWVELOCITYY * NEWVELOCITYY) < 0.001) then
			VELOCITY_X = 0
			VELOCITY_Y = 0
	else
		VELOCITY_X = NEWVELOCITYX
		VELOCITY_Y = NEWVELOCITYY
	end
		
	NEWPLAYER_X = PLAYER_X - VELOCITY_X * tpf
	NEWPLAYER_Y = PLAYER_Y - VELOCITY_Y * tpf
	
	self:nearestWall(LAST_SECTOR_ID, NEWPLAYER_X, NEWPLAYER_Y)
	
	local nextsector = -1
	local heightdiff = false
	
	if (NEWPLAYER_X ~= PLAYER_X and NEWPLAYER_Y ~= PLAYER_Y) then
		nextsector = self:getPointSector(NEWPLAYER_X, NEWPLAYER_Y)
	end
	
	if (nextsector ~= -1 and nextsector ~= LAST_SECTOR_ID) then
		local zdiff = CURR_Z - MainLevel:getSectorZ(nextsector)
		local slopedpixel1 = MainLevel:getSectorZ(nextsector)/10 - MainLevel:getSectorSlope(nextsector, NEWPLAYER_X, NEWPLAYER_Y)/200
		local slopedpixel0 = CURR_Z/10 - MainLevel:getSectorSlope(LAST_SECTOR_ID, PLAYER_X, PLAYER_Y)/200
		
		if (math.abs(slopedpixel1 - slopedpixel0) > 0.5 and slopedpixel1 > slopedpixel0) then
			heightdiff = true
		end
	end
	
	if (DISTANCE_TO_WALL > COL_RADIUS and heightdiff == false) then
		LAST_GOODPOS_X = PLAYER_X
		LAST_GOODPOS_Y = PLAYER_Y
		PLAYER_X = NEWPLAYER_X
		PLAYER_Y = NEWPLAYER_Y		
	else
		PLAYER_X = LAST_GOODPOS_X
		PLAYER_Y = LAST_GOODPOS_Y
		LATEST_VELMOD = math.sqrt(VELOCITY_X* VELOCITY_X + VELOCITY_Y * VELOCITY_Y)
		CANT_MOVE = LAST_MOVE --prevent keeping going in that direction

		
		if (ATTACK_ANGLE < 0) then
			if (LAST_MOVE == 1) then
				VELOCITY_X = DISTANCE_TO_WALL_X 
				VELOCITY_Y = DISTANCE_TO_WALL_Y
			elseif(LAST_MOVE == 2) then
				VELOCITY_X = -DISTANCE_TO_WALL_X 
				VELOCITY_Y = -DISTANCE_TO_WALL_Y
			end
		else
			if (LAST_MOVE == 1) then
				VELOCITY_X = -DISTANCE_TO_WALL_X 
				VELOCITY_Y = -DISTANCE_TO_WALL_Y
			elseif(LAST_MOVE == 2) then
				VELOCITY_X = DISTANCE_TO_WALL_X 
				VELOCITY_Y = DISTANCE_TO_WALL_Y
			end
		end
		SLIDE_X = VELOCITY_X
		SLIDE_Y = VELOCITY_Y
		
	end
end

function Engine:update(gamestate, dt)
	
	if (gamestate == 'game') then
		if (self.fire == true) then
			if (self.localtime > self.maxtime) then
				self.fire = false
				ISFIRING = false
				
				if (ATTACKTYPE == 0) then
					SHIELD = nil
				end
				
				if (ATTACKTYPE == 1) then
					HORIZ = 0
				end
				
			else
				self.localtime = self.localtime + dt
				
				if (ATTACKTYPE == 0) then
					SHIELD:update(dt)
				end
				
				if (ATTACKTYPE == 1) then
					HORIZ = (INITIALVEL * self.localtime + 0.5*GRAVITY*self.localtime*self.localtime)*1500
				end
			end
		end
	
		if love.keyboard.isDown('left') then
			self:rotateCam('left', dt)
		elseif love.keyboard.isDown('right') then
			self:rotateCam('right', dt)
		end
		
		if love.keyboard.isDown('o') then
			self:viewChange('up',dt)
		elseif love.keyboard.isDown('l') then
			self:viewChange('down',dt)
		end
		
		--if love.keyboard.isDown('i') then
		--	self:floorChange('up',dt)
		--elseif love.keyboard.isDown('k') then
		--	self:floorChange('down',dt)
		--end
		
		--if love.keyboard.isDown('u') then
		--	self:toggleChange('up',dt)
		--elseif love.keyboard.isDown('j') then
		--	self:toggleChange('down',dt)
		--end
		
		--if love.keyboard.isDown('y') then
		--	self:toggleSlope()
		--end
		
		
		if ((ATTACKTYPE == 0 and self.fire == false) or ATTACKTYPE == 1 or ATTACKTYPE == 2) then

			if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
				if (CANT_MOVE ~= 1) then
					self:clearCollisionData()
					self:foward(-1, dt)
					LAST_MOVE = 1
					
					if (CANT_MOVE == 2) then
						CANT_MOVE = 0
					end
				else
					self:clearCollisionData()
					self:foward(-2, dt) --slide movement
					LAST_MOVE = 1
					
					if (CANT_MOVE == 2) then
						CANT_MOVE = 0
					end
				end
			end
		
		
			if love.keyboard.isDown('down') or love.keyboard.isDown('s') and CANT_MOVE ~=2 then
				self:clearCollisionData()
				self:foward(1, dt)
				LAST_MOVE = 2
				
				if (CANT_MOVE == 1) then
					CANT_MOVE = 0
				end
			end
			
			if love.keyboard.isDown('a') and CANT_MOVE ~=3 then
				self:clearCollisionData()
				self:strafe(-1,dt)
				LAST_MOVE = 3
				
				if (CANT_MOVE ~= 3) then
					CANT_MOVE = 0
				end
			end
			
			if love.keyboard.isDown('d') and CANT_MOVE ~=4 then
				self:clearCollisionData()
				self:strafe(1,dt) 
				LAST_MOVE = 4
				
				if (CANT_MOVE ~= 4) then
					CANT_MOVE = 0
				end
			end
		end
		
		if love.keyboard.isDown('space') and self.fire == false then
			self.localtime = 0
			self.fire = true
			--self.attacktype = 2 --this comes from player selection
			--ATTACKTYPE = 2 --this comes from player selection
			ISFIRING = true
			
			if (self.attacktype == 0) then
				self.maxtime = 2
				SHIELD = Enemy(PLAYER_X + DIR_X/4, PLAYER_Y + DIR_Y/4, 4, 0)
				
				sounds['shield']:play()
			end
			
			if (self.attacktype == 1) then
				self.maxtime = MAXJUMPTIME
				
				sounds['jump']:play()
			end
			
			if (self.attacktype == 2) then
				self.maxtime = 5
				SHURIKENID = MainLevel:addEnemy(PLAYER_X + DIR_X/2, PLAYER_Y + DIR_Y/2, 5)
				MainLevel:setDirection(DIR_X, DIR_Y, SHURIKENID)
				MainLevel:setVelocity(4.0, SHURIKENID)
				MainLevel:setOriginator(SHURIKENID, -1) --player id
				
				sounds['shot']:play()
			end
			
		end
		
		if ((self.fire == false and ATTACKTYPE == 0) or (ATTACKTYPE == 1) or (ATTACKTYPE == 2) ) then
			self:updatePos(dt)
			self:updateSector()
		end
		
		-- reset all keys pressed and released this frame
		love.keyboard.keysPressed = {}
		love.keyboard.keysReleased = {}

		-- update enemies in MainLevel
		MainLevel:update(dt)
		
	elseif (gamestate == 'welcome') then
	    --in the intro only rotate camera
		self:rotateCam('left', dt*0.1)
		
		-- reset all keys pressed and released this frame
		love.keyboard.keysPressed = {}
		love.keyboard.keysReleased = {}
	end
	
end

function Engine:isFiring()
	return self.fire
end

function Engine:getAttackMode()
	return self.attacktype
end

function Engine:viewChange(dir, dt)
	if dir == 'up' then
		BOTTOMVIEW = BOTTOMVIEW + 300*dt
		--SLOPE = SLOPE + 1* dt
	elseif dir == 'down' then
		BOTTOMVIEW = BOTTOMVIEW - 300*dt
		--SLOPE = SLOPE - 1* dt
	end
	
	--print(SLOPE)
end

function Engine:floorChange(dir, dt)
	if dir == 'up' then
		MainLevel:getSectors()[2]['floorz'] = MainLevel:getSectors()[2]['floorz'] + 10*dt
	elseif dir == 'down' then
		MainLevel:getSectors()[2]['floorz'] = MainLevel:getSectors()[2]['floorz'] - 10*dt
	end
end

function Engine:toggleChange(dir, dt)
	if dir == 'up' then
		--MainLevel:getSectors()[1]['slopedangle'] = MainLevel:getSectors()[1]['slopedangle'] + 0.01*dt
		MainLevel:getSectors()[24]['slopedangle'] = MainLevel:getSectors()[24]['slopedangle'] + 0.1*dt
	elseif dir == 'down' then
		--MainLevel:getSectors()[1]['slopedangle'] = MainLevel:getSectors()[1]['slopedangle'] - 0.01*dt
		MainLevel:getSectors()[24]['slopedangle'] = MainLevel:getSectors()[24]['slopedangle'] - 0.1*dt
	end
	print(MainLevel:getSectors()[24]['slopedangle'])
end

function Engine:toggleSlope()
	if MainLevel:getSectors()[1]['sloped'] == 0 then
		MainLevel:getSectors()[1]['sloped'] = 1
	else
		MainLevel:getSectors()[1]['sloped'] = 0
	end
end

function Engine:setAttackMode(i)
	if (i == 1) then
		self.attacktype = 0
		ATTACKTYPE = 0
	elseif (i == 2) then
		self.attacktype = 1
		ATTACKTYPE = 1
	elseif (i == 3) then
		self.attacktype = 2
		ATTACKTYPE = 2
	end
end

function Engine:getShieldSize()
	return self.localtime * 2
end

function Engine:clearCollisionData()
	for k in pairs(collisionsectors) do
		collisionsectors[k] = nil
	end
end

function Engine:initOcclussion()
	umost = {}
	dmost = {}
	
	for k = 0, VIRTUAL_WIDTH do
		umost[k] = 0
		dmost[k] = 0
	end
end

function Engine:initZbuffer()
	--for k in pairs(ZBUFFER) do
	for k = 0, VIRTUAL_WIDTH do
		ZBUFFER[k] = 10000 --init with a far away unit
	end
end

function Engine:getPointSector(PX,PY)
	--local nextsector = self:pointInside(LAST_SECTOR_ID, PX, PY)
	
	--if nextsector ~= -1 then
	--	return nextsector
	--end
	
	local nextsector = self:checkPointNeighbour(PX, PY)
	
	if nextsector ~= -1 then
		return nextsector
	end
	
	nextsector = self:checkPointAllSectors(PX, PY)
	
	if nextsector ~= -1 then
		return nextsector
	end
	
	return -1
end

function Engine:draw()
	self:displayRoom()
end

function Engine:calcBottom(sectorid, rayDirX, rayDirY, wallratio, zdiff)
	local elem = MainLevel:getSlopedBasewall(sectorid)
	
	local wx0 = MainLevel:getWalls()[elem]['x0']
	local wy0 = MainLevel:getWalls()[elem]['y0']
	local wx1 = MainLevel:getWalls()[elem]['x1']
	local wy1 = MainLevel:getWalls()[elem]['y1']
					
					
	wx1 = wx1 - wx0 -- wall direction
	wy1 = wy1 - wy0 -- wall direction
					
	--raytracing
	local dx = wx0 - PLAYER_X
	local dy = wy0 - PLAYER_Y
	local det = wx1 * rayDirY - wy1 * rayDirX
	local u = (dy * wx1 - dx * wy1) / det
	
	local wallheight = 100/u
	local floorheight = wallheight/wallratio
					
								
	--get all datapoints to render floor
	local ftextureheight = MainLevel:floorHeight(sectorid) + zdiff*10
	local floorwheight = ftextureheight * floorheight
	local ceilingheight = (VIRTUAL_HEIGHT - floorwheight)/2
	
	local bottomWall = VIRTUAL_HEIGHT / (2.0 * (ceilingheight + floorwheight) - VIRTUAL_HEIGHT)
	
	return bottomWall 	
end

--[[
    Cast some rays to fill camera view
]]
function Engine:drawWalls(bunchid)
	wallheight = 100

	local wallratio = 40
	local playerheight = 20
	
	local currentsector = -1
	
	local floorpoints = {}
	
	local slopedist = MainLevel:getSectorSlope(LAST_SECTOR_ID, PLAYER_X, PLAYER_Y)
	
	MainLevel:clearWallStrips()
	
	for x = 0, VIRTUAL_WIDTH do
	
		cameraX = 2 * x / VIRTUAL_WIDTH - 1 --x-coordinate in camera space
		rayDirX = DIR_X + CAM_X_PLANE * cameraX
		rayDirY = DIR_Y + CAM_Y_PLANE * cameraX
		
		--print('attempting to draw: ' .. bunchid .. ' is nil? ' .. tostring(bunchstack[bunchid]))
		
			
		--end
		
		for v in pairs(bunchstack[bunchid]['walls']) do
			elem = bunchstack[bunchid]['walls'][v]['wallid']
			currentsector = bunchstack[bunchid]['sector']
			
			--occlusion sector over sector
			--if (dmost[x] < VIRTUAL_HEIGHT) then
			
				--if MainLevel:getWalls()[elem]['nextsector'] == -1 or (MainLevel:getWalls()[elem]['nextsector'] ~= -1 and MainLevel:getWalls()[elem]['drawable'] == 1) then
					wx0 = MainLevel:getWalls()[elem]['x0']
					wy0 = MainLevel:getWalls()[elem]['y0']
					wx1 = MainLevel:getWalls()[elem]['x1']
					wy1 = MainLevel:getWalls()[elem]['y1']
					
					
					wx1 = wx1 - wx0 -- wall direction
					wy1 = wy1 - wy0 -- wall direction
					
					--raytracing
					dx = wx0 - PLAYER_X
					dy = wy0 - PLAYER_Y
					det = wx1 * rayDirY - wy1 * rayDirX
					u = (dy * wx1 - dx * wy1) / det
					v = (dy * rayDirX - dx * rayDirY) / det
								
					--if (elem == 10) then
					--	print('u ' .. u .. ' v ' .. v .. ' ' .. ZBUFFER[x])
					--end
					--print('render wall: ' .. elem)
					--u will be the distance from player to plane
					--v will be the position in the wall						
					if (u > 0 and v >= 0 and v < 1.0 ) then
						local zdiff = CURR_Z - MainLevel:getSectorZ(bunchstack[bunchid]['sector'])
						local slopedpixel = 0
						
						hitx = PLAYER_X + u*rayDirX
						hity = PLAYER_Y + u*rayDirY	
						
						if (MainLevel:isSloped(bunchstack[bunchid]['sector'])) then			
							slopedpixel = MainLevel:getSectorSlope(bunchstack[bunchid]['sector'], hitx, hity)

							wallheight = (100 + slopedpixel/1.2) / u
						else
							wallheight = 100/u
						end
						
						floorheight = wallheight/wallratio
						attenuation = math.min(math.floor(u),10)
						
						--hitx = PLAYER_X + u*rayDirX
						--hity = PLAYER_Y + u*rayDirY	
							
						--get all datapoints to render floor
						ftextureheight = MainLevel:floorHeight(bunchstack[bunchid]['sector']) + zdiff*10 
						floorwheight = ftextureheight * floorheight - slopedist/u
						ceilingheight = (VIRTUAL_HEIGHT - floorwheight)/2 - (0.105*slopedpixel/u*zdiff)
						allfloor = VIRTUAL_HEIGHT - ceilingheight - floorwheight - BOTTOMVIEW
						
						bottomWall = VIRTUAL_HEIGHT / (2.0 * (ceilingheight + floorwheight) - VIRTUAL_HEIGHT)
						--get all datapoints to render floor			
						
						if ((ceilingheight + floorwheight + HORIZ + BOTTOMVIEW) < (VIRTUAL_HEIGHT - dmost[x])) then
							if (ceilingheight + floorwheight + allfloor + HORIZ + BOTTOMVIEW) > (VIRTUAL_HEIGHT - dmost[x]) then
								allfloor = VIRTUAL_HEIGHT - dmost[x] - (ceilingheight + floorwheight + HORIZ + BOTTOMVIEW)
							end
							
							if (MainLevel:isSloped(bunchstack[bunchid]['sector'])) then

								--raster each floor pixel
								for n = 0, allfloor do
									scany = ceilingheight + floorwheight + n
									
									color = MainLevel:sectorColorWithSlope(bunchstack[bunchid]['sector'], PLAYER_X, PLAYER_Y, VIRTUAL_HEIGHT, scany,rayDirX, rayDirY, (slopedist+zdiff*10*-2.5))
									
									--table.insert(floorpoints, {x, ceilingheight + floorwheight + n + HORIZ + BOTTOMVIEW, color[1]/255, color[2]/255, color[3]/255, 255/255})
									table.insert(floorpoints, {x, ceilingheight + floorwheight + n + HORIZ + BOTTOMVIEW, color[1], color[2], color[3], 255})
									
									dmost[x] = dmost[x] + 1
								end
								--get all datapoints to render floor 
							
							else
								--raster each floor pixel
								for n = 0, allfloor do
									scany = ceilingheight + floorwheight + n
									
									color = MainLevel:sectorColor(bunchstack[bunchid]['sector'], PLAYER_X, PLAYER_Y, hitx, hity, VIRTUAL_HEIGHT, scany, bottomWall)
									
									
									--table.insert(floorpoints, {x, ceilingheight + floorwheight + n + HORIZ + BOTTOMVIEW, color[1]/255, color[2]/255, color[3]/255, 255/255})
									table.insert(floorpoints, {x, ceilingheight + floorwheight + n + HORIZ + BOTTOMVIEW, color[1], color[2], color[3], 255})
									

									dmost[x] = dmost[x] + 1
								end
								--get all datapoints to render floor 
							end
							
							
							
						end
						
				
						if MainLevel:getWalls()[elem]['nextsector'] == -1 then
							if MainLevel:getWalls()[elem]['drawable'] == 1 then
								
								renderdata = MainLevel:wallColumn(elem, v, 0, wallheight, attenuation*20/255, wallratio, 0)
								wallheight = wallheight/ wallratio
								centerwall = (VIRTUAL_HEIGHT - renderdata[3] * wallheight) / 2
								
								
								if (MainLevel:isSloped(bunchstack[bunchid]['sector'])) then
									centerwall = centerwall + (slopedpixel/2)/u
								end
								
								local maxtexture = 48
								 
								
								if (zdiff == 0) then
								
									if (math.floor(centerwall + HORIZ + BOTTOMVIEW + wallheight * 48 - slopedist/u/2) > (VIRTUAL_HEIGHT - dmost[x])) then
										--cut the texture if not completely visible
										local texturecut = (VIRTUAL_HEIGHT - dmost[x]) - math.floor(centerwall + HORIZ + BOTTOMVIEW - slopedist/u/2) 
										
										texturecut = texturecut / math.floor(wallheight * 48)
										
										local r1,r2,r3,r4 = renderdata[2]:getViewport()
										renderdata[2] = love.graphics.newQuad(r1, r2, 1, texturecut * 48, 48, 48)
										
										maxtexture = texturecut * 48
									end
								
								
									if ((centerwall + HORIZ + BOTTOMVIEW - slopedist/u/2) < (VIRTUAL_HEIGHT - dmost[x])) then
										--render wall
										MainLevel:addWallStrip(renderdata, x, centerwall + HORIZ + BOTTOMVIEW - slopedist/u/2, 0, 1, wallheight, attenuation*20/255, 0)
										--render wall	
										dmost[x] = dmost[x] + wallheight * maxtexture -- HARDCODED BAD THING 
										--dmost[x] = 1000 --complete occlude with ceiling
									end
									
								else
								
									if (math.floor(ceilingheight + floorwheight + HORIZ + BOTTOMVIEW + wallheight * 48 + slopedpixel/u/1.96) > (VIRTUAL_HEIGHT - dmost[x])) then
										--cut the texture if not completely visible
										local texturecut = math.floor(ceilingheight + floorwheight + HORIZ + BOTTOMVIEW + slopedpixel/u/1.96) - (VIRTUAL_HEIGHT - dmost[x])
										
										texturecut = 1 - texturecut / math.floor(wallheight * 48)
										
										if (texturecut < 0) then
											texturecut = 0 --patch a problem with my math
										end
																				
										local r1,r2,r3,r4 = renderdata[2]:getViewport()
										renderdata[2] = love.graphics.newQuad(r1, r2, 1, texturecut * 48, 48, 48)
										
										maxtexture = texturecut * 48
									end
									
										--render wall
										MainLevel:addWallStrip(renderdata, x, ceilingheight + floorwheight + HORIZ + BOTTOMVIEW - wallheight*48 + slopedpixel/u/1.96, 0, 1, wallheight, attenuation*20/255, 0)
										
										--render wall	
										dmost[x] = dmost[x] + wallheight * maxtexture -- HARDCODED BAD THING 
										--dmost[x] = 1000 --complete occlude with ceiling
								end
							end
						else
							local nextsector = MainLevel:getWalls()[elem]['nextsector']
									
							
							if (MainLevel:getSectors()[nextsector]['floorz'] > ((MainLevel:getSectors()[currentsector]['floorz']) - slopedpixel/26)) then
								local othersectorsloped = MainLevel:getSectorSlope(nextsector, hitx, hity)
								local stepheight =((MainLevel:getSectors()[nextsector]['floorz'] - othersectorsloped/26) - (MainLevel:getSectors()[currentsector]['floorz'] - slopedpixel/26))*24
								stepheight = stepheight/91.5				--render floorup
								local renderdata = MainLevel:wallColumn(elem, v, 0, stepheight, attenuation*20/255, wallratio, 1)
								--local wallheight = wallheight / 10 / wallratio * stepheight 
								local wallheight = stepheight / u
								local centerwall = ceilingheight + floorwheight - 50*wallheight
								
								
								if ((centerwall + HORIZ + BOTTOMVIEW) < (VIRTUAL_HEIGHT - dmost[x])) then
									
								local maxtexture = 48
								
								if (math.floor(centerwall + HORIZ + BOTTOMVIEW + wallheight * 48) > (VIRTUAL_HEIGHT - dmost[x])) then
										--cut the texture if not completely visible
										local texturecut = (VIRTUAL_HEIGHT - dmost[x]) - math.floor(centerwall + HORIZ + BOTTOMVIEW)
										
										texturecut = texturecut / math.floor(wallheight * 48)
									
										
										local r1,r2,r3,r4 = renderdata[2]:getViewport()
										renderdata[2] = love.graphics.newQuad(r1, r2, 1, texturecut * 48, 48, 48)
										
										maxtexture = texturecut * 48
								end
								
								
								
								
								MainLevel:addWallStrip(renderdata, x, centerwall + HORIZ + BOTTOMVIEW, 0, 1, wallheight, attenuation*20/255, 1)
								--render floorup
								if (centerwall + HORIZ + BOTTOMVIEW + wallheight * maxtexture > VIRTUAL_HEIGHT) then
									dmost[x] = dmost[x] + (VIRTUAL_HEIGHT - (centerwall + HORIZ + BOTTOMVIEW))
								else
									dmost[x] = dmost[x] +  wallheight * maxtexture -- HARDCODED BAD THING
								end
								
								end
							end
							
							
							if (MainLevel:getSectors()[nextsector]['ceilingz'] > MainLevel:getSectors()[LAST_SECTOR_ID]['ceilingz']) then
								local stepheight = MainLevel:getSectors()[nextsector]['ceilingz'] - MainLevel:getSectors()[LAST_SECTOR_ID]['ceilingz']
								--render ceilingdown
								local renderdata = MainLevel:wallColumn(elem, v, 0, stepheight, attenuation*20/255, wallratio, 2)
								local wallheight = wallheight / 10 / wallratio * stepheight
								local centerwall = ceilingheight
								
								MainLevel:addWallStrip(renderdata, x, centerwall + HORIZ + BOTTOMVIEW, 0, 1, wallheight, attenuation*20/255, 2)
								--render ceilingdown	
							end
							
					
						end
						
						umost[x] = VIRTUAL_HEIGHT
						--dmost[x] = allfloor + wallheight
						
						--zbuffer for sprites
						if (u < ZBUFFER[x] and MainLevel:getWalls()[elem]['nextsector'] == -1) then
							ZBUFFER[x] = u
						end
						
						--if (elem == 7 and x == VIRTUAL_WIDTH/2) then
						--	print(dmost[x])
						--end
						
					end
					
					
				--end
			
			--end
		end
		
		--occlussion mask
		--love.graphics.rectangle('fill', x, VIRTUAL_HEIGHT - dmost[x], 1, dmost[x])
	end

	--finally render floor
	love.graphics.points(floorpoints)
	--self:drawInstance(floorpoints)
	
	--love.graphics.setColor(1.0, 1.0, 1.0, 1.0) 
	
	--and render walls
	love.graphics.draw(MainLevel:getWallStrips())
	
	--and render steps
	love.graphics.draw(MainLevel:getWallStripsFloor())
	love.graphics.draw(MainLevel:getWallStripsCeiling())
	
	
	
end

function Engine:drawInstance(fp)
	local vertices = {
		{0, 0,  0,0, 1.0,0.0,0.0,1.0},
		{1, 0,  0,0, 1.0,0.0,0.0,1.0},
		{1, 1,  0,0, 1.0,0.0,0.0,1.0},
		{0, 1,  0,0, 1.0,0.0,0.0,1.0},
	}
	
	local mesh = love.graphics.newMesh(vertices, "triangles", "static")
	local instancemesh = love.graphics.newMesh({{"InstancePosition", "float", 2},{"InstanceColor","float", 4}}, fp, nil, "static")
	
	mesh:attachAttribute("InstancePosition", instancemesh, "perinstance")
	mesh:attachAttribute("InstanceColor", instancemesh, "perinstance")
	
	love.graphics.setShader(PIXELSHADER)
 
	-- Draw the mesh many times in one draw call, using instancing.
	local instancecount = #fp
	love.graphics.drawInstanced(mesh, instancecount, 0, 0)
	
	love.graphics.setShader()
end

--[[
    Cast a ray to fill camera view
]]
function Engine:displayRoom()
	
	for k in pairs(alreadyvisited) do
		alreadyvisited[k] = nil
	end
	
	for k in pairs(bunchstack) do
		bunchstack[k] = nil
	end
		
		
	self:initOcclussion()
	self:initZbuffer()

	numbunches = 0
	
	--print('sector starting:' .. LAST_SECTOR_ID)
	self:scanSector(LAST_SECTOR_ID) --generate a bunch list
	
	--print('player x: ' .. PLAYER_X)
	--print('player y: ' .. PLAYER_Y)
	--print(DIR_X)
	--print(DIR_Y)
	--print(CAM_X_PLANE)
	--print(CAM_Y_PLANE)
	
	--print('number of bunches:' .. numbunches)
	--for k in pairs(bunchstack) do
	--	for w in pairs(bunchstack[k]['walls']) do
	--		print('bunch n ' .. k .. ' wall:' .. bunchstack[k]['walls'][w]['wallid'])
	--	end
	--end

	localnumbunches = numbunches - 1
		
	while( localnumbunches > 0 ) do
		--pick the closest bunch	
		local closest = 0	
		local tempbuf = {}
		tempbuf[closest] = 1
		
		for i=1, localnumbunches do
			local j
			--print('compare index: ' .. i .. ' with ' .. closest)
			j = self:bunchfront(i, closest)
			--print('result: ' .. j)
			
			if (j >= 0) then 
				tempbuf[i] = 1

				if (j == 1) then
					tempbuf[closest] = 1
					closest = i
				end
			end 
		end
		
		-- Double-check */
		local checkagain = true
		while (checkagain == true) do
			checkagain = false
			for i=0 , localnumbunches do 
				local j
				if (tempbuf[i] == nil ) then
					--print('compare index: ' .. i .. ' with ' .. closest)
					j = self:bunchfront(i,closest)
					--print('result: ' .. j)
					if( j >= 0) then
						tempbuf[i] = 1
						if (j == 1) then
							tempbuf[closest] = 1
							closest = i 
							--i = 0 --loop again -- this is wrong in LUA so need to put everything inside a loop
							checkagain = true
							break
						end
					end
				end
			end
		end
		
		--print('draw bunch index:' .. closest)
		self:drawWalls(closest)
		
		
		tempbunch = bunchstack[localnumbunches]
		bunchstack[localnumbunches] = bunchstack[closest]
		bunchstack[closest] = tempbunch
		
		localnumbunches = localnumbunches - 1
		
	
	end
	
	self:drawWalls(0)
	
	--self:animateSprites()
	
	self:drawSprites()

	if ISFIRING == true then
		if (ATTACKTYPE == 0) then
			self:drawShield()
		end

	end
end


function Engine:drawShield()
	if (SHIELD ~= nil) then
		SHIELD:render(PLAYER_X, PLAYER_Y, DIR_X, DIR_Y, CAM_X_PLANE, CAM_Y_PLANE, VIRTUAL_WIDTH, VIRTUAL_HEIGHT,ZBUFFER, HORIZ, BOTTOMVIEW)
	end
end

function Engine:drawShuriken()
	if (SHURIKEN ~= nil) then
		SHURIKEN:render(PLAYER_X, PLAYER_Y, DIR_X, DIR_Y, CAM_X_PLANE, CAM_Y_PLANE, VIRTUAL_WIDTH, VIRTUAL_HEIGHT,ZBUFFER, HORIZ, BOTTOMVIEW)
	end
end


function Engine:drawSprites()
	MainLevel:drawSprites(PLAYER_X, PLAYER_Y, DIR_X, DIR_Y, CAM_X_PLANE, CAM_Y_PLANE, VIRTUAL_WIDTH, VIRTUAL_HEIGHT,ZBUFFER, HORIZ, BOTTOMVIEW)
end

--Please Trust this function cause is the only one that works :)
function Engine:isFront(x0, y0, x1, y1, x2, y2)
     return ((x1 - x0)*(y2 - y0) - (y1 - y0)*(x2 - x0))
end

function Engine:angleBetween(x, y)
	walltoplayerx = x - PLAYER_X
	walltoplayery = y - PLAYER_Y
	hip = math.sqrt(walltoplayerx*walltoplayerx + walltoplayery*walltoplayery)
	cosang = (walltoplayerx * DIR_X + walltoplayery * DIR_Y) / hip --projection over direction
	
	return cosang
end

function Engine:toScreenCoord2(x, y)
	walltoplayerx = x - PLAYER_X
	walltoplayery = y - PLAYER_Y
	hip = math.sqrt(walltoplayerx*walltoplayerx + walltoplayery*walltoplayery)
	cosang = (walltoplayerx * DIR_X + walltoplayery * DIR_Y) / hip --projection over direction
	proymodule = hip * cosang --point is at the back?
	angle = math.acos(cosang)
	
	oposite = math.abs(math.tan(angle)) -- dont mult by hip, that will proyect the vector over the wall...we only want cam plane
	side1 = self:isFront(PLAYER_X, PLAYER_Y, PLAYER_X + DIR_X, PLAYER_Y + DIR_Y, x, y)
	
	if (proymodule < 0 ) then
		return 666 --evil point
	end
	--if (proymodule > 0 ) then --is in front
		if (side1 < 0) then
			oposite = -oposite --clamp values
		else
			oposite = oposite
		end
	
	
	return oposite
end

function Engine:toScreenCoord(x, y, debug) --works! do not touch
	--translate sprite position to relative to camera
    local spriteX = x - PLAYER_X
    local spriteY = y - PLAYER_Y

    --transform sprite with the inverse camera matrix
    -- [ planeX   dirX ] -1                                       [ dirY      -dirX ]
    -- [               ]       =  1/(planeX*dirY-dirX*planeY) *   [                 ]
    -- [ planeY   dirY ]                                          [ -planeY  planeX ]

    local invDet = 1.0 / (CAM_X_PLANE * DIR_Y - DIR_X * CAM_Y_PLANE) --required for correct matrix multiplication

    local transformX = invDet * (DIR_Y * spriteX - DIR_X * spriteY)
    local transformY = invDet * (-CAM_Y_PLANE * spriteX + CAM_X_PLANE * spriteY)  --this is actually the depth inside the screen, that what Z is in 3D

    spriteScreenX = math.floor((VIRTUAL_WIDTH / 2) * (1 + transformX / transformY))
	
	if (debug == 1) then
		--print('------------------------------################################')
		--print(' x y ' .. x .. ' ' .. y)
		--print('isback:' .. transformY)
		--print('screencoord ' .. (-spriteScreenX + VIRTUAL_WIDTH ))
		--print('screencoord ' .. spriteScreenX)
	end
	
	if (transformY < 0) then
		--return (-spriteScreenX + VIRTUAL_WIDTH)
		return nil
	else
	return spriteScreenX 
	end
end

function Engine:scanSector(sectorid)
	alreadyvisited[sectorid] = 1
	
	--print('visiting sector id: ' .. sectorid)
	
	local firstwall = MainLevel:getSectors()[sectorid]['startWall']
	local howmanywalls = MainLevel:getSectors()[sectorid]['numWalls']
	
	local bunch = {}

	local wallcount = 0
	local cross = 0
	local isportal = -1
	
	local bunchxmin = 1000  --bunch min x coordinate in screenspace
	local bunchxmax = -1000 --bunch max x coordinate in screenspace
	
	local screenpoint1 = nil
	local screenpoint2 = nil
	
	local xant01 = nil
	local yant01 = nil
	local xant02 = nil
	local yant02 = nil
	
	local x1
	local y1
	local x2
	local y2
	
	rayDir1X = DIR_X - CAM_X_PLANE
	rayDir1Y = DIR_Y - CAM_Y_PLANE
	rayDir2X = DIR_X + CAM_X_PLANE 
	rayDir2Y = DIR_Y + CAM_Y_PLANE
	
	repeat
		isportal = MainLevel:getWalls()[firstwall]['nextsector']
		
		x1 = MainLevel:getWalls()[firstwall]['x0'] --point 1 wall
		y1 = MainLevel:getWalls()[firstwall]['y0']
	
		x2 = MainLevel:getWalls()[firstwall]['x1'] --point 2 wall
		y2 = MainLevel:getWalls()[firstwall]['y1']
		

		cross = self:isFront(x1,y1, x2,y2, PLAYER_X, PLAYER_Y)
		
		
		if (cross < 0.6) then -- this value is to prevent some sectors not showing when the portal is in diagonal of the viewer perspective
			if (isportal ~= -1) then
				if (alreadyvisited[isportal] == nil) then	
					self:scanSector(isportal)	
				end
			end

		end
		
		-- viewfrustrum 
		wx0 = MainLevel:getWalls()[firstwall]['x0']
		wy0 = MainLevel:getWalls()[firstwall]['y0']
		wx1 = MainLevel:getWalls()[firstwall]['x1']
		wy1 = MainLevel:getWalls()[firstwall]['y1']
		
		wx1 = wx1 - wx0 -- wall direction --be careful because it is not unit vector
		wy1 = wy1 - wy0 -- wall direction --be careful because it is not unit vector
		
		walllenght = math.sqrt(wx1*wx1 + wy1*wy1)

		--raytracing
		dx = wx0 - PLAYER_X
		dy = wy0 - PLAYER_Y
		det1 = wx1 * rayDir1Y - wy1 * rayDir1X
		u1 = (dy * wx1 - dx * wy1) / det1
		v1 = (dy * rayDir1X - dx * rayDir1Y) / det1
		
		det2 = wx1 * rayDir2Y - wy1 * rayDir2X
		u2 = (dy * wx1 - dx * wy1) / det2
		v2 = (dy * rayDir2X - dx * rayDir2Y) / det2
					
		--if (firstwall == 14 ) then
		--	print('u1 ' .. u1 .. ' v1 ' .. v1 .. ' u2 ' ..u2 .. ' v2 ' .. v2)
		--end
		
		if ((u1 >0 and u1 < 100 ) or (u2 >0 and u2 < 100)) then --viewfrustrum no more than 100 units in front
		
			planeleftpoint1 = self:isFront(PLAYER_X,PLAYER_Y, PLAYER_X + DIR_X - CAM_X_PLANE, PLAYER_Y + DIR_Y - CAM_Y_PLANE, x1, y1)
			planeleftpoint2 = self:isFront(PLAYER_X,PLAYER_Y, PLAYER_X + DIR_X - CAM_X_PLANE, PLAYER_Y + DIR_Y - CAM_Y_PLANE, x2, y2)
				
			planerighpoint1 = self:isFront(PLAYER_X,PLAYER_Y, PLAYER_X + DIR_X + CAM_X_PLANE, PLAYER_Y + DIR_Y + CAM_Y_PLANE, x1, y1)
			planerighpoint2 = self:isFront(PLAYER_X,PLAYER_Y, PLAYER_X + DIR_X + CAM_X_PLANE, PLAYER_Y + DIR_Y + CAM_Y_PLANE, x2, y2)
			
			--if (firstwall == 10 ) then
			--	print('point1x ' .. x1 .. ' point1y ' .. y1)
			--	print('point2x ' .. x2 .. ' point2y ' .. y2)
			--	print('l: point1 ' .. planeleftpoint1 .. ' point2 ' .. planeleftpoint2)
			--	print('r: point1 ' .. planerighpoint1 .. ' point2 ' .. planerighpoint2)
			--end
		
			if (planeleftpoint1 < 0 and planeleftpoint2 < 0) or (planerighpoint1 > 0 and planerighpoint2 > 0) then
				--this is completely at the back
				cross = 1000 ---so hide
			end
			
			--if (isportal ~= -1) then
			--	cross = -1 --dont check the cross product if it is a portal and if its drawable
			--end
	
			if (cross < 0) then --if facing player
					screenpoint1 = self:toScreenCoord(x1, y1, 0)
					screenpoint2 = self:toScreenCoord(x2, y2, 0)
					if (screenpoint1 == nil) then
						if (u1 >= 0 and u2 >=0 and v1 >= 0 and v2 >=0 and v1 < walllenght and v2 < walllenght) then
							local wichside = self:isFront(PLAYER_X, PLAYER_Y, PLAYER_X + DIR_X, PLAYER_Y + DIR_Y, x1, y1)
							
							if (wichside < 0) then
								screenpoint1 = -1000
							else
								screenpoint1 = 1000
							end
						elseif (planeleftpoint1 >= 0 and planeleftpoint2 < 0) or (planeleftpoint1 < 0 and planeleftpoint2 >= 0) and 
							u1 >= 0 and v1 >= 0 and v1 < walllenght then
							screenpoint1 = -1000
						elseif (planerighpoint1 >= 0 and planerighpoint2 < 0) or (planerighpoint1 < 0 and planerighpoint2 >= 0) and 
							u2 >= 0 and v2 >= 0 and v2 < walllenght then
							screenpoint1 = 1000
						end
					end
					
					if (screenpoint2 == nil) then
						if (u1 >= 0 and u2 >=0 and v1 >= 0 and v2 >=0 and v1 < walllenght and v2 < walllenght) then
							local wichside = self:isFront(PLAYER_X, PLAYER_Y, PLAYER_X + DIR_X, PLAYER_Y + DIR_Y, x2, y2)
							
							if (wichside < 0) then
								screenpoint2 = -1000
							else
								screenpoint2 = 1000
							end
						elseif (planeleftpoint1 >= 0 and planeleftpoint2 < 0) or (planeleftpoint1 < 0 and planeleftpoint2 >= 0) and 
							u1 >= 0 and v1 >= 0 and v1 < walllenght then
							screenpoint2 = -1000
						elseif (planerighpoint1 >= 0 and planerighpoint2 < 0) or (planerighpoint1 < 0 and planerighpoint2 >= 0) and 
							u2 >= 0 and v2 >= 0 and v2 < walllenght then
							screenpoint2 = 1000
						end
					end
					
					
					--fix min max inverted
					if (screenpoint1 > screenpoint2) then
						auxscreen = screenpoint1
						screenpoint1 = screenpoint2
						screenpoint2 = auxscreen
					end
					
					--print(screenpoint1 .. ' for wall ' .. firstwall)
					--print(screenpoint2 .. ' for wall ' .. firstwall)
					
						--this will check bunch continuity
					if (xant01 == nil and yant01 == nil) or 
					   (xant01 == x1 and yant01 == y1 or xant01 == x2 and yant01 == y2) or 
					   (xant02 == x1 and yant02 == y1 or xant02 == x2 and yant02 == y2) then
						if (bunchxmax < screenpoint1) then
							bunchxmax = screenpoint1
						end
						if (bunchxmax < screenpoint2) then
							bunchxmax = screenpoint2
						end
						
						if (bunchxmin > screenpoint1) then
							bunchxmin = screenpoint1
						end
						if (bunchxmin > screenpoint2) then
							bunchxmin = screenpoint2
						end
						
						
						bunch[wallcount] = 	{
										wallid = firstwall,
										minpoint = screenpoint1,
										maxpoint = screenpoint2
									}
									
						wallcount = wallcount + 1
						
						xant01 = x1
						yant01 = y1
						xant02 = x2
						yant02 = y2
					else
						--if bunch not continue then split
						
						if next(bunch) ~= nil then
							bunchstack[numbunches] = {	
														walls = bunch,
														wallslength = wallcount,
														minbunch = bunchxmin,
														maxbunch = bunchxmax,
														sector = sectorid
													 }
							numbunches = numbunches + 1
						end
						
						bunch = {}

						wallcount = 0
						cross = 0
						isportal = -1
						
						bunchxmin = 1000  --bunch min x coordinate in screenspace
						bunchxmax = -1000 --bunch max x coordinate in screenspace
						
						xant01 = nil
						yant01 = nil
						xant02 = nil
						yant02 = nil
						
						if (bunchxmax < screenpoint1) then
							bunchxmax = screenpoint1
						end
						if (bunchxmax < screenpoint2) then
							bunchxmax = screenpoint2
						end
						
						if (bunchxmin > screenpoint1) then
							bunchxmin = screenpoint1
						end
						if (bunchxmin > screenpoint2) then
							bunchxmin = screenpoint2
						end
						
				
						bunch[wallcount] = 	{
										wallid = firstwall,
										minpoint = screenpoint1,
										maxpoint = screenpoint2
									}
									
						wallcount = wallcount + 1
						
						xant01 = x1
						yant01 = y1
						xant02 = x2
						yant02 = y2
					end
					
			end
		end
		
		firstwall = firstwall + 1
        howmanywalls = howmanywalls -1
	
	until howmanywalls == 0
			
	if next(bunch) ~= nil then
		bunchstack[numbunches] = {	
									walls = bunch,
									wallslength = wallcount,
									minbunch = bunchxmin,
									maxbunch = bunchxmax,
									sector = sectorid
								 }
		numbunches = numbunches + 1
	end
end


function Engine:bunchfront(id1, id2)
	
	local x1b1
	local x2b1
	local x1b2
	local x2b2
	local returnedbunch = -1
	local flipped = 0
	
	x1b1 = bunchstack[id1]['minbunch']
    x2b2 = bunchstack[id2]['maxbunch'] 
	
	--print('-----------------------------------')
	--print(bunchstack[id1]['minbunch'])
	--print(bunchstack[id1]['maxbunch'])
	--print(bunchstack[id2]['minbunch'])
	--print(bunchstack[id2]['maxbunch'])
	--print('-----------------------------------')
	
	if (x1b1 >= x2b2) then
        return(-1)
	end
	
	x1b2 = bunchstack[id2]['minbunch']
    x2b1 = bunchstack[id1]['maxbunch']
    
	if (x1b2 >= x2b1) then
		return(-1)
	end
	
	
	for wallindex = 0, bunchstack[id1]['wallslength'] - 1 do	
		local countmax = bunchstack[id2]['wallslength'] - 1
		local wallid = -1
		local wallid2 = -1
		
		if (bunchstack[id1]['walls'][wallindex]['minpoint'] ~= bunchstack[id1]['walls'][wallindex]['maxpoint']) then --not use perpendicular walls
			for count = 0, countmax do
				
				if (bunchstack[id2]['walls'][count]['minpoint'] ~= bunchstack[id2]['walls'][count]['maxpoint']) then --not use perpendicular walls
				
					if bunchstack[id1]['walls'][wallindex]['minpoint'] == bunchstack[id2]['walls'][count]['minpoint'] then
						wallid = bunchstack[id2]['walls'][count]['wallid']
						wallid2 = count
						break

					elseif bunchstack[id1]['walls'][wallindex]['maxpoint'] == bunchstack[id2]['walls'][count]['maxpoint'] then
						wallid = bunchstack[id2]['walls'][count]['wallid']
						wallid2 = count
						break
					else
						
						if bunchstack[id1]['walls'][wallindex]['minpoint'] < bunchstack[id2]['walls'][count]['maxpoint'] and
						   bunchstack[id1]['walls'][wallindex]['minpoint'] > bunchstack[id2]['walls'][count]['minpoint'] then
							wallid = bunchstack[id2]['walls'][count]['wallid']
							wallid2 = count
							break
						elseif bunchstack[id1]['walls'][wallindex]['maxpoint'] < bunchstack[id2]['walls'][count]['maxpoint'] and
						   bunchstack[id1]['walls'][wallindex]['maxpoint'] > bunchstack[id2]['walls'][count]['minpoint'] then 
							wallid = bunchstack[id2]['walls'][count]['wallid']
							wallid2 = count
							break
						elseif bunchstack[id2]['walls'][count]['minpoint'] < bunchstack[id1]['walls'][wallindex]['maxpoint'] and
						   bunchstack[id2]['walls'][count]['minpoint'] > bunchstack[id1]['walls'][wallindex]['minpoint'] then 
							wallid = bunchstack[id2]['walls'][count]['wallid']
							wallid2 = count
							break
						elseif bunchstack[id2]['walls'][count]['maxpoint'] < bunchstack[id1]['walls'][wallindex]['maxpoint'] and
						   bunchstack[id2]['walls'][count]['maxpoint'] > bunchstack[id1]['walls'][wallindex]['minpoint'] then 
							wallid = bunchstack[id2]['walls'][count]['wallid']
							wallid2 = count
							break
						end
					end
				end
				
			end
			
			if (wallid ~= -1) then
				--print('wall found:' .. wallid)
				--print('wall to compare: ' .. bunchstack[id1]['walls'][wallindex]['wallid'])
				--print(bunchstack[id1]['walls'][wallindex]['minpoint'])
				--print(bunchstack[id1]['walls'][wallindex]['maxpoint'])
				--print(bunchstack[id2]['walls'][wallid2]['minpoint'])
				--print(bunchstack[id2]['walls'][wallid2]['maxpoint'])
				
				returnedbunch = self:wallFront(bunchstack[id1]['walls'][wallindex]['wallid'], wallid)
				
				
				if (returnedbunch == 1) then
					--return id1 --I was returning ids---just return 1 or 0
					return 1
				else
					--return id2 --I was returning ids---just return 1 or 0
					return 0
				end
				
			end
		end
	end
	
	
	--print('---------------------------------------------IHATETHIS_-------------------------')
	return -1
end

function Engine:wallFront(wallid1, wallid2)

	--print('wallid1 ' .. wallid1)
	--print('wallid2 ' .. wallid2)
	
	wx0 = MainLevel:getWalls()[wallid1]['x0']
	wy0 = MainLevel:getWalls()[wallid1]['y0']
	wx1 = MainLevel:getWalls()[wallid1]['x1']
	wy1 = MainLevel:getWalls()[wallid1]['y1']
	
	--wx1 = wx1 - wx0 -- wall1 direction
	--wy1 = wy1 - wy0 -- wall1 direction
	
	hx0 = MainLevel:getWalls()[wallid2]['x0']
	hy0 = MainLevel:getWalls()[wallid2]['y0']
	hx1 = MainLevel:getWalls()[wallid2]['x1']
	hy1 = MainLevel:getWalls()[wallid2]['y1']
	
	--hx1 = hx1 - hx0 -- wall2 direction
	--hy1 = hy1 - hy0 -- wall2 direction
	
	--This is a cross-product between Wall 1 vector and the [Wall 1 Point 1-> Wall 2 Point 1] vector 
    local t1 = self:isFront(wx0, wy0, wx1, wy1, hx0, hy0)
	--This is a cross-product between Wall 1 vector and the [Wall 1 Point 1-> Wall 2 Point 2] vector 
    local t2 = self:isFront(wx0, wy0, wx1, wy1, hx1, hy1)
	
	--If the vectors a parallel, then the cross-product is zero.
    if (t1 == 0) then
		--wall2's point1 is on wall1's plan.
        t1 = t2
        if (t1 == 0) then --// Those two walls are on the same plan.
			--//Wall 2's point 2 is on wall1's plan.
			return(-1)
		end
    end
	
    if (t2 == 0) then 
		t2 = t1
	end
	
	if ((t1 >= 0 and t2 >= 0) or (t1 < 0 and t2 < 0)) then
    
		--cross-product have the same sign: Both points of wall2 are on the same side of wall1 : An answer is possible !!

		--Now is time to take into account the camera position and determine which of wall1 or wall2 is seen first.
        --t2 = dmulscale2(globalposx-x11,dy,-dx,globalposy-y11); /* pos vs. l1 */
		t2 = self:isFront(wx0, wy0, wx1, wy1, PLAYER_X, PLAYER_Y)

		--Test the cross product sign difference.
		--If (t2^t1) >= 0 then  both cross product had different sign so wall1 is in front of wall2
		--otherwise wall2 is in front of wall1
        
		if (t2 < 0 and t1 >= 0) or (t2 >= 0 and t1 < 0) then
			return 1
		else
			return 0
		end
		--return((t2^t1) >= 0);
    end
	
	
	--This is a cross-product between Wall 1 vector and the [Wall 1 Point 1-> Wall 2 Point 1] vector 
    local t1 = self:isFront( hx0, hy0, hx1, hy1, wx0 , wy0)
	--This is a cross-product between Wall 1 vector and the [Wall 1 Point 1-> Wall 2 Point 2] vector 
    local t2 = self:isFront( hx0, hy0, hx1, hy1, wx1 , wy1)
	
	--If the vectors a parallel, then the cross-product is zero.
    if (t1 == 0) then
		--wall2's point1 is on wall1's plan.
        t1 = t2
        if (t1 == 0) then --// Those two walls are on the same plan.
			--//Wall 2's point 2 is on wall1's plan.
			return(-1)
		end
    end
	
    if (t2 == 0) then 
		t2 = t1
	end
	
	if ((t1 >= 0 and t2 >= 0) or (t1 < 0 and t2 < 0)) then
    
		--cross-product have the same sign: Both points of wall2 are on the same side of wall1 : An answer is possible !!

		--Now is time to take into account the camera position and determine which of wall1 or wall2 is seen first.
        --t2 = dmulscale2(globalposx-x11,dy,-dx,globalposy-y11); /* pos vs. l1 */
		t2 = self:isFront(hx0, hy0, hx1, hy1, PLAYER_X, PLAYER_Y)

		--Test the cross product sign difference.
		--If (t2^t1) >= 0 then  both cross product had different sign so wall1 is in front of wall2
		--otherwise wall2 is in front of wall1
        
		if (t2 < 0 and t1 >= 0) or (t2 >= 0 and t1 < 0) then
			return 0
		else
			return 1
		end
		--return((t2^t1) >= 0);
    end
	

end

--[[function Engine:wallFront(wallid1, wallid2)
	
	--print('wall: ' .. wallid1)
	--print('otherwall: ' .. wallid2)
	
	if (wallid2 == -1) then
		return -2
	end
	
	wx0 = MainLevel:getWalls()[wallid1]['x0']
	wy0 = MainLevel:getWalls()[wallid1]['y0']
	wx1 = MainLevel:getWalls()[wallid1]['x1']
	wy1 = MainLevel:getWalls()[wallid1]['y1']
	
	wx1 = wx1 - wx0 -- wall1 direction
	wy1 = wy1 - wy0 -- wall1 direction
	
	hx0 = MainLevel:getWalls()[wallid2]['x0']
	hy0 = MainLevel:getWalls()[wallid2]['y0']
	hx1 = MainLevel:getWalls()[wallid2]['x1']
	hy1 = MainLevel:getWalls()[wallid2]['y1']
	
	hx1 = hx1 - hx0 -- wall2 direction
	hy1 = hy1 - hy0 -- wall2 direction

	--raytracing
	dx = wx0 - hx0  --everything centered in wall 2
	dy = wy0 - hy0  --everything centered in wall 2
	det1 = wx1 * hy1 - wy1 * hx1
	u1 = (dy * wx1 - dx * wy1) / det1 --module of ray from wall2 to wall1
	v1 = (dy * hx1 - dx * hy1) / det1 --module of ray inside wall1
	
	wall2lenght = math.sqrt(hx1 * hx1 + hy1 *hy1)
	
	--if (wallid1 == 3 and wallid2 == 8) then
	--	print('------------------------------------------------whachooooosss')
	--	print('u1: ' .. u1 .. ' wallid2 ' .. wallid2)
	--end
	
	--if (u1 <= 0) or (u1 >= 1) then
	if (v1 <= 0) or (v1 >= 1) then
		--print('they dont intersect')
		local wx0 = MainLevel:getWalls()[wallid1]['x0']
		local wy0 = MainLevel:getWalls()[wallid1]['y0']
		local wx1 = MainLevel:getWalls()[wallid1]['x1']
		local wy1 = MainLevel:getWalls()[wallid1]['y1']
		
		local hx0 = MainLevel:getWalls()[wallid2]['x0']
		local hy0 = MainLevel:getWalls()[wallid2]['y0']
		local hx1 = MainLevel:getWalls()[wallid2]['x1']
		local hy1 = MainLevel:getWalls()[wallid2]['y1']
	
		
		--local crosswall = self:isFront(wx0,wy0, wx1, wy1, hx0, hy0)
		local crosswall = self:isFront(hx0, hy0, hx1, hy1, wx0, wy0)
		
		if (wallid1 == 6 and wallid2 == 1) then
			--print(wx0)
			--print(wy0)
			--print(wx1)
			--print(wy1)
			
			--print(hx0)
			--print(hy0)
			--print(hx1)
			--print(hy1)
			print('wall plane: ' .. wallid1 ..' cross wall: ' .. crosswall )
		end
		
		
		if (crosswall == 0) then --prevent cross product with points in the same 'line'
			--crosswall = self:isFront(wx0,wy0, wx1, wy1, hx1, hy1)
			crosswall = self:isFront(hx0, hy0, hx1, hy1, wx1, wy1)
			
			if (wallid1 == 6 and wallid2 == 1) then	
				print('wall plane: ' .. wallid1 ..' cross wall: ' .. crosswall )
			end
		end
		
		
		--local crossplayer = self:isFront(wx0,wy0, wx1, wy1, PLAYER_X, PLAYER_Y)
		local crossplayer = self:isFront(hx0,hy0, hx1, hy1, PLAYER_X, PLAYER_Y)
		
		if (wallid1 == 6 and wallid2 == 1) then	
			print('wall plane: ' .. wallid1 ..' cross wall: ' .. crosswall .. ' cross play: ' .. crossplayer)
		end
		
		if (crosswall < 0 and crossplayer < 0 or crosswall > 0 and crossplayer > 0) then
			return 1 --returns 1 if wallid1 front of wallid2
		else
			return 0 --return 0 otherwise
		end
	else
		--print('error')
		return -2
	end
end
]]

function Engine:updateSector()
	--debug.debug()
	if self:inside(LAST_SECTOR_ID) == 0 then
		if self:checkNeighbour() == 0 then
			self:checkAllSectors() --worst case scenario
		end
	end
end

function Engine:nearestWall(sectorid, posx, posy)
	local firstwall = MainLevel:getSectors()[sectorid]['startWall']
	local howmanywalls = MainLevel:getSectors()[sectorid]['numWalls']
	local cross
	
	if (sectorid == LAST_SECTOR_ID) then
		DISTANCE_TO_WALL = 9999
	end
	
	collisionsectors[sectorid] = 1
	--debug.debug()
	repeat

		nextsector = MainLevel:getWalls()[firstwall]['nextsector'] 
		
		if (nextsector ~= -1) then
			if (collisionsectors[nextsector] == nil) then
				self:nearestWall(nextsector, posx, posy)
			end
		else
			x1 = MainLevel:getWalls()[firstwall]['x0'] --point 1 wall
			y1 = MainLevel:getWalls()[firstwall]['y0']
		
			x2 = MainLevel:getWalls()[firstwall]['x1'] --point 2 wall
			y2 = MainLevel:getWalls()[firstwall]['y1']
			
			cross = self:isFront(x1,y1, x2,y2, PLAYER_X, PLAYER_Y)
		
		
			wx0 = MainLevel:getWalls()[firstwall]['x0']
			wy0 = MainLevel:getWalls()[firstwall]['y0']
			wx1 = MainLevel:getWalls()[firstwall]['x1']
			wy1 = MainLevel:getWalls()[firstwall]['y1']
			
			wx1 = wx1 - wx0 -- wall direction
			wy1 = wy1 - wy0 -- wall direction

			lengthvectorwall = math.sqrt(wx1 * wx1 + wy1 * wy1)
			wallbunitx = wx1 / lengthvectorwall
			wallbunity = wy1 / lengthvectorwall
		
		
			dx = posx - wx0
			dy = posy - wy0
			
			
			projamodule = dx * wallbunitx + dy * wallbunity
		
			
			projx = wallbunitx * projamodule
			projy = wallbunity * projamodule
			
			
			distancetowallx = dx - projx
			distancetowally = dy - projy
		
			
			finaldistance = math.sqrt(distancetowallx* distancetowallx + distancetowally* distancetowally)
			
			distancetowallunitx = distancetowallx / finaldistance
			distancetowallunity = distancetowally / finaldistance
			
			--if (finaldistance < DISTANCE_TO_WALL and finaldistance ~= 0 and projamodule > (0 - COL_RADIUS/2) and projamodule < (lengthvectorwall + COL_RADIUS/2)) then
			if (finaldistance < DISTANCE_TO_WALL and finaldistance ~= 0 and projamodule > 0  and projamodule < lengthvectorwall) then
				--print('colliding with sector: ' .. sectorid)
				--print('wall: ' .. firstwall)
				--print('distance: ' .. finaldistance)
				DISTANCE_TO_WALL = finaldistance
				DISTANCE_TO_WALL_X = wallbunitx * 2
				DISTANCE_TO_WALL_Y = wallbunity * 2
				ATTACK_ANGLE = (DIR_X * wallbunitx + DIR_Y * wallbunity)
				UNLOCK_ANGLE = (DIR_X * distancetowallunitx + DIR_Y * distancetowallunity)
				--print(UNLOCK_ANGLE)
				if CANT_MOVE ~= 0 and UNLOCK_ANGLE > 0.2 then
					--print('reset view')
					CANT_MOVE = 0
				end
				
				
			end
		end
		
		firstwall = firstwall + 1
		howmanywalls = howmanywalls - 1
	until howmanywalls == 0
	
	return 0
end

function Engine:checkPointNeighbour(PX, PY)
	local firstwall = MainLevel:getSectors()[LAST_SECTOR_ID]['startWall']
	local howmanywalls = MainLevel:getSectors()[LAST_SECTOR_ID]['numWalls']
	
	--debug.debug()
	repeat

		local nextsector = MainLevel:getWalls()[firstwall]['nextsector']
		
		if nextsector ~= -1 and nextsector ~= LAST_SECTOR_ID then
			local isinside = self:pointInside(nextsector, PX, PY)
			
			if isinside == 1 then
				return nextsector
			end
		end
		
		firstwall = firstwall + 1
		howmanywalls = howmanywalls - 1
	until howmanywalls == 0
	
	return -1
end

function Engine:checkNeighbour()
	local firstwall = MainLevel:getSectors()[LAST_SECTOR_ID]['startWall']
	local howmanywalls = MainLevel:getSectors()[LAST_SECTOR_ID]['numWalls']
	
	--debug.debug()
	repeat

		nextsector = MainLevel:getWalls()[firstwall]['nextsector']
		
		if nextsector ~= -1 and nextsector ~= LAST_SECTOR_ID then
			isinside = self:inside(nextsector)
			
			if isinside == 1 then
				LAST_SECTOR_ID = nextsector
				CURR_Z = MainLevel:getSectors()[LAST_SECTOR_ID]['floorz']
				return 1
			end
		end
		
		firstwall = firstwall + 1
		howmanywalls = howmanywalls - 1
	until howmanywalls == 0
	
	return 0
end

function Engine:checkPointAllSectors(PX, PY)
	
	for index, s in ipairs(MainLevel:getSectors()) do
		
		local sectorid = s['id']
		local isinside = self:pointInside(sectorid, PX, PY)
		
		if isinside == 1 then
			return sectorid
		end
	end
	
	--debug.debug()
	return -1
end

function Engine:checkAllSectors()
	
	for index, s in ipairs(MainLevel:getSectors()) do
		
		sectorid = s['id']
		isinside = self:inside(sectorid)
		
		if isinside == 1 then
			LAST_SECTOR_ID = nextsector
			CURR_Z = MainLevel:getSectors()[LAST_SECTOR_ID]['floorz']
			return 1
		end
	end
	
	--debug.debug()
	return 0
end

function Engine:sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

function Engine:pointInside(sectorid, PX, PY)
	local wallCrossed = 0
	local firstwall = MainLevel:getSectors()[sectorid]['startWall']
	local howmanywalls = MainLevel:getSectors()[sectorid]['numWalls']
	local y1
	local y2
	
	local x1
	local x2
	local crossed = 0
	
	--bit xor tells if the number signs are equal or not , if result negative then signs are different
	repeat
		y1 = MainLevel:getWalls()[firstwall]['y0']-PY
        y2 = MainLevel:getWalls()[firstwall]['y1']-PY
		
		--Compare the sign of y1 and y2.
        --If (y1^y2) < 0 : y1 and y2 have different sign bit:  y is between wal->y and wall[wal->point2].y.
        --The goal is to not take into consideration any wall that is totally above or totally under the point [x,y].
		--if (bit.bxor(y1,y2) < 0) then
		if (self:sign(y1) ~= self:sign(y2)) then
			x1 = MainLevel:getWalls()[firstwall]['x0']-PX
            x2 = MainLevel:getWalls()[firstwall]['x1']-PX
			
		
			--If (x1^x2) >= 0 x1 and x2 have identic sign bit: x is on the left or the right of both wal point 1 x and wall point 2 x
			--if (bit.bxor(x1,x2) >= 0) then
			if (self:sign(x1) == self:sign(x2)) then
		
                -- If (x,y) is totally on the left or on the right, just count x1 (which indicate if we are on
                -- on the left or on the right.
                --wallCrossed = bit.bxor(wallCrossed, x1) -- sum?
				--if ((MainLevel:getWalls()[firstwall]['x0'] - PLAYER_X) < 0) then
				if (x1 < 0) then
					wallCrossed = wallCrossed + 1
				end
            else
                -- This is the most complicated case: X is between x1 and x2, we need a fine grained test.
                -- We need to know exactly if it is on the left or on the right in order to know if the ray
                -- is crossing the wall or not,
                -- The sign of the Cross-Product can answer this case :) !
                --wallCrossed = bit.bxor(wallCrossed,bit.bxor((x1*y2-x2*y1),y2))
				--x1 = MainLevel:getWalls()[firstwall]['x0'] - PLAYER_X --point 1 wall
				--y1 = MainLevel:getWalls()[firstwall]['y0'] - PLAYER_Y
		
				--x2 = MainLevel:getWalls()[firstwall]['x1'] - PLAYER_X--point 2 wall
				--y2 = MainLevel:getWalls()[firstwall]['y1'] - PLAYER_Y
				
				x1 = MainLevel:getWalls()[firstwall]['x0'] --point 1 wall
				y1 = MainLevel:getWalls()[firstwall]['y0']
		
				x2 = MainLevel:getWalls()[firstwall]['x1'] --point 2 wall
				y2 = MainLevel:getWalls()[firstwall]['y1']
			
				if (MainLevel:getWalls()[firstwall]['innerportal'] ~= nil) then
					cross = self:isFront(x2,y2, x1,y1, PX, PY)
				else
					cross = self:isFront(x1,y1, x2,y2, PX, PY)
				end
				
				if (cross < 0) then
					wallCrossed = wallCrossed + 1
				end	
			end
		end
		
		firstwall = firstwall + 1
        howmanywalls = howmanywalls -1
	
	until howmanywalls == 0	
	
	--return bit.rshift(wallCrossed, 31)
	return wallCrossed % 2
end


function Engine:inside(sectorid)
	local wallCrossed = 0
	local firstwall = MainLevel:getSectors()[sectorid]['startWall']
	local howmanywalls = MainLevel:getSectors()[sectorid]['numWalls']
	local y1
	local y2
	
	local x1
	local x2
	local crossed = 0
	
	--bit xor tells if the number signs are equal or not , if result negative then signs are different
	repeat
		y1 = MainLevel:getWalls()[firstwall]['y0']-PLAYER_Y
        y2 = MainLevel:getWalls()[firstwall]['y1']-PLAYER_Y
		
		--Compare the sign of y1 and y2.
        --If (y1^y2) < 0 : y1 and y2 have different sign bit:  y is between wal->y and wall[wal->point2].y.
        --The goal is to not take into consideration any wall that is totally above or totally under the point [x,y].
		--if (bit.bxor(y1,y2) < 0) then
		if (self:sign(y1) ~= self:sign(y2)) then
			x1 = MainLevel:getWalls()[firstwall]['x0']-PLAYER_X
            x2 = MainLevel:getWalls()[firstwall]['x1']-PLAYER_X
			
		
			--If (x1^x2) >= 0 x1 and x2 have identic sign bit: x is on the left or the right of both wal point 1 x and wall point 2 x
			--if (bit.bxor(x1,x2) >= 0) then
			if (self:sign(x1) == self:sign(x2)) then
		
                -- If (x,y) is totally on the left or on the right, just count x1 (which indicate if we are on
                -- on the left or on the right.
                --wallCrossed = bit.bxor(wallCrossed, x1) -- sum?
				--if ((MainLevel:getWalls()[firstwall]['x0'] - PLAYER_X) < 0) then
				if (x1 < 0) then
					wallCrossed = wallCrossed + 1
				end
            else
                -- This is the most complicated case: X is between x1 and x2, we need a fine grained test.
                -- We need to know exactly if it is on the left or on the right in order to know if the ray
                -- is crossing the wall or not,
                -- The sign of the Cross-Product can answer this case :) !
                --wallCrossed = bit.bxor(wallCrossed,bit.bxor((x1*y2-x2*y1),y2))
				--x1 = MainLevel:getWalls()[firstwall]['x0'] - PLAYER_X --point 1 wall
				--y1 = MainLevel:getWalls()[firstwall]['y0'] - PLAYER_Y
		
				--x2 = MainLevel:getWalls()[firstwall]['x1'] - PLAYER_X--point 2 wall
				--y2 = MainLevel:getWalls()[firstwall]['y1'] - PLAYER_Y
				
				x1 = MainLevel:getWalls()[firstwall]['x0'] --point 1 wall
				y1 = MainLevel:getWalls()[firstwall]['y0']
		
				x2 = MainLevel:getWalls()[firstwall]['x1'] --point 2 wall
				y2 = MainLevel:getWalls()[firstwall]['y1']
			
				if (MainLevel:getWalls()[firstwall]['innerportal'] ~= nil) then
					cross = self:isFront(x2,y2, x1,y1, PLAYER_X, PLAYER_Y)
				else
					cross = self:isFront(x1,y1, x2,y2, PLAYER_X, PLAYER_Y)
				end
				
				if (cross < 0) then
					wallCrossed = wallCrossed + 1
				end	
			end
		end
		
		firstwall = firstwall + 1
        howmanywalls = howmanywalls -1
	
	until howmanywalls == 0	
	
	--return bit.rshift(wallCrossed, 31)
	return wallCrossed % 2
end
