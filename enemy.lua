--[[
    Enemy class
]]



Enemy = Class{}

function Enemy:init(x, y, type, id, atype)
	self.x = x
	self.y = y
	self.size = 0
	self.yoffset = 0
	self.internalid = id
	self.attacktype = atype
	
	self.directionX = 0
	self.directionY = 0
	--self.velocity = 0.75
	self.velocity = 0.25
	self.type = type
	
	self.threatDistance = 0 --distance to another entity that could hit the enemy
	self.threatDirectionX = 0 --direction of Threat
	self.threatDirectionY = 0 --direction of Threat
	self.threatId = 0 --id of the enemy
	
	if (self.type == 0) then
		self.texture01 = love.graphics.newImage('enemies/Ninja Frog/Idle (32x32).png')
		self.texture02 = love.graphics.newImage('enemies/Ninja Frog/Run (32x32).png')
		self.texture03 = love.graphics.newImage('enemies/Ninja Frog/Jump (32x32).png')
		self.size = 32
		self.xoffset = 0
		self.transformxoffset = 0.3
		self.yoffset = 15
		self.sizefactor = 4
	elseif(self.type == 1) then
		self.texture01 = love.graphics.newImage('enemies/Virtual Guy/Idle (32x32).png')
		self.texture02 = love.graphics.newImage('enemies/Virtual Guy/Run (32x32).png')
		self.texture03 = love.graphics.newImage('enemies/Virtual Guy/Jump (32x32).png')
		self.size = 32
		self.xoffset = 0
		self.transformxoffset = 0.3
		self.yoffset = 15
		self.sizefactor = 4
	elseif(self.type == 2) then
		self.texture01 = love.graphics.newImage('items/flag/Checkpoint (Flag Idle)(64x64).png')
		self.size = 64
		self.xoffset = 5
		self.transformxoffset = 0
		self.yoffset = 50
		self.sizefactor = 4
	elseif(self.type == 3) then
		self.texture01 = love.graphics.newImage('items/shield/shield01.png')
		self.size = 128
		self.xoffset = 0
		self.yoffset = 90
		self.transformxoffset = 1.4
		self.sizefactor = 8
	elseif(self.type == 4) then
		self.texture01 = love.graphics.newImage('items/shield/shield.png')
		self.size = 128
		self.xoffset = 0.5
		self.yoffset = 90
		self.transformxoffset = 1.4
		self.sizefactor = 3.5
	elseif(self.type == 5) then
		self.texture01 = love.graphics.newImage('items/shuriken/shuriken.png')
		self.size = 50
		self.xoffset = 0
		self.yoffset = 0
		self.transformxoffset = 0.4
		self.sizefactor = 2.5
	end
	
    self.currentFrame = nil
    self.state = 'idle'
		
	if (self.type == 0 or self.type == 1) then
		self.animations = 	{
									['idle'] = Animation({
										texture = self.texture01,
										frames = {
											love.graphics.newQuad(0, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(32, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(64, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(96, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(128, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(160, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(192, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(224, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(256, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(288, 0, 32, 32, self.texture01:getDimensions()),
											love.graphics.newQuad(320, 0, 32, 32, self.texture01:getDimensions())
										}
									}),
									['walking'] = Animation({
										texture = self.texture02,
										frames = {
											love.graphics.newQuad(0, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(32, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(64, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(96, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(128, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(160, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(192, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(224, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(256, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(288, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(320, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(352, 0, 32, 32, self.texture02:getDimensions())
										},
										interval = 0.15
									}),
									['jumping'] = Animation({
										texture = self.texture03,
										frames = {
											love.graphics.newQuad(0, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(32, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(0, 0, 32, 32, self.texture02:getDimensions()),
											love.graphics.newQuad(32, 0, 32, 32, self.texture02:getDimensions())
										}
									})
						}
	elseif (self.type == 2) then
		self.animations = 	{
									['idle'] = Animation({
										texture = self.texture01,
										frames = {
											love.graphics.newQuad(0, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(64, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(128, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(192, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(256, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(320, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(384, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(448, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(512, 0, 64, 64, self.texture01:getDimensions()),
											love.graphics.newQuad(576, 0, 64, 64, self.texture01:getDimensions())
										}
									})	
						}
	elseif (self.type == 3) then
		self.animations = 	{
									['idle'] = Animation({
										texture = self.texture01,
										frames = {
											love.graphics.newQuad(0, 0, 128, 128, self.texture01:getDimensions())
										}
									})	
							}
	elseif (self.type == 4) then
		self.animations = 	{
									['idle'] = Animation({
										texture = self.texture01,
										frames = {
											love.graphics.newQuad(0, 0, 128, 128, self.texture01:getDimensions())
										}
									})	
							}
	elseif (self.type == 5) then
		self.animations = 	{
									['idle'] = Animation({
										texture = self.texture01,
										frames = {
											love.graphics.newQuad(0, 0, 50, 23, self.texture01:getDimensions()),
											love.graphics.newQuad(50, 0, 50, 23, self.texture01:getDimensions()),
											love.graphics.newQuad(0, 0, 50, 23, self.texture01:getDimensions()),
											love.graphics.newQuad(50, 0, 50, 23, self.texture01:getDimensions())
										}
									})	
							}
	end
	
	
	self.animation = self.animations['idle']
    self.currentFrame = self.animation:getCurrentFrame()
	self.currentDistance = 0
	
	self.localtime = 0
	
	if (self.type ~= 5) then
		self.attacktime = 2
	else
		self.attacktime = 5
	end

	self.hitTime = 0
	self.hitMax = 0.5
	self.beenHit = false
	self.fire = false
end

function Enemy:getType()
	return self.type
end

function Enemy:update(dt, enemylist)
	self.threatDistance = 100000 --distance to another entity that could hit the enemy
	self.localtime = self.localtime + dt
    self.animation:update(dt)
	self.texture = self.animation:getTexture()
    self.currentFrame = self.animation:getCurrentFrame()
	
	if (enemylist ~= nil) then --in case that the update comes from the Shield from the player
		--check other enemies like shurikens if it cant hit the enemy
		local dst = self.threatDistance
		for r in pairs(enemylist) do
			if (enemylist[r]:getType() == 5 and enemylist[r]:getOriginator() ~= self.internalid) then --if enemy type is shuriken
				
				dst = enemylist[r]:distanceTo(self.x, self.y) 
				if ( dst < self.threatDistance) then
					self.threatDistance = dst
					self.threatId = r
					self.threatDirectionX , self.threatDirectionY = enemylist[r]:getDirection() 
				end
			end
		end
	end
		
	if (self.currentDistance < 4.5) then
		if self.type == 0 or self.type == 1 then
			
			if (self.beenHit == false) then
				if (self.currentDistance > 1.5) then
					if (self.fire == false) then
						--change to attack mode
						self.state = 'attack'
						self.animation = self.animations['walking']
					end
				else
					if self.type == 0 or self.type == 1 and self.state == 'attack' then
						--change to iddle mode
						self.state = 'idle'
						self.animation = self.animations['idle']	
					end
				end
				
				if (self.currentDistance < 0.5) then --too close to enemy push back
					MainEngine:pushPlayer(0, self.x, self.y, 0.3)
				end
				
				if (MainEngine:getAttackMode() == 0 and MainEngine:isFiring()) then
				
					if ((self.currentDistance - MainEngine:getShieldSize()) < 0) then
						self.state = 'beenhit'
						self.beenHit = true
						self.hitTime = 0
						self.directionX = -self.directionX
						self.directionY = -self.directionY
						self.velocity = 3
					end				
				end
			end
		end
		
		if (self.type == 2 and self.currentDistance < 1) then
			advanceLevel() --------call main function to advance a level
		end
	else
		if self.type == 0 or self.type == 1 and self.state == 'attack' then
			--change to iddle mode
			self.state = 'idle'
			self.animation = self.animations['idle']	
		end
	end
	
	if (self.state == 'attack' or self.state == 'jumping') then
		self.x = self.x + self.directionX * dt * self.velocity
		self.y = self.y + self.directionY * dt * self.velocity
	end
	
	if (self.state == 'beenhit') then
		self.x = self.x + self.directionX * dt * self.velocity
		self.y = self.y + self.directionY * dt * self.velocity
	end
	
	--logic with force shield in enemy
	if (self.type == 3) then
		if self.localtime > self.attacktime then	
			-- kill shield
			MainLevel:killEnemy(self.internalid)
			self.localtime = -100
		else
			self.sizefactor = (self.localtime/self.attacktime)*16
			self.transformxoffset = (self.localtime/self.attacktime)*6 --this value is broken if I change resolution
			
			self.eventHorizon = (self.localtime/self.attacktime)*3.25
		end
		
		--print(self.currentDistance)
		if (self.currentDistance - self.eventHorizon < 0 and self.localtime > (self.attacktime/3)) then
			MainEngine:pushPlayer(0, self.x, self.y, 0.3)
		end
	end
	
	--logic with force shield in player
	if (self.type == 4) then
		if self.localtime > self.attacktime then	
			-- kill shield
			self.localtime = -100
		else
			self.yoffset = 45 + (self.localtime/self.attacktime)*45 
		end
	end
	
	--logic with shuriken
	if (self.type == 5) then
		self.x = self.x + self.directionX * dt * self.velocity
		self.y = self.y + self.directionY * dt * self.velocity
		
		--print('localtime ' .. self.localtime .. ' ' .. self.attacktime/3 .. ' ' ..self.currentDistance)
		if self.localtime > self.attacktime then	
			-- kill shuriken
			MainLevel:killEnemy(self.internalid)
			self.localtime = -100
		end
		
		if (self.currentDistance < 0.5 and self.localtime > 0.1) then
			MainEngine:pushPlayer(1, -self.directionX, -self.directionY, 0.3)
			
			-- kill shiriken 
			MainLevel:killEnemy(self.internalid)
			self.localtime = -100
		end
	end	
	
	--logic with enemies trying to attack
	if (self.type == 0 or self.type == 1) then
		if (self.fire == false and  math.random(0,1000) < 10) then
			self.fire = true
			self.localtime = 0
			
			--this comes from the constructor
			--self.attacktype = 2 --attack type 0 means force shield
								--attack type 1 means jumping
								--attacl type 2 means shoot
			
			if (self.attacktype == 0) then
				self.attacktime = 2
				MainLevel:addEnemy(self.x, self.y, 3)
				
				--change to iddle mode
				self.state = 'idle'
				self.animation = self.animations['idle']
				
				sounds['shield']:play()
			end

			if (self.attacktype == 1) then
				self.attacktime = MAXJUMPTIME
				self.state = 'jumping'
				self.animation = self.animations['jumping']
				
				sounds['jump']:play()
			end	

			if (self.attacktype == 2 and self.currentDistance < 4.5) then
				self.attacktime = 2
				local shuriid = MainLevel:addEnemy(self.x, self.y, 5)
				MainLevel:setDirection(self.directionX, self.directionY, shuriid)
				MainLevel:setVelocity(4.0, shuriid)
				MainLevel:setOriginator(shuriid, self.internalid)
				
				sounds['shot']:play()
			end
		end
		
		if (self.fire == true) then
			if (self.attacktype == 1) then	 --jumping
				self.yoffset = 15 + (INITIALVEL * self.localtime + 0.5*GRAVITY*self.localtime*self.localtime)*1000
			end
			
			if (self.localtime > self.attacktime) then
				self.fire = false
				self.localtime = 0
				
				if (self.attacktype == 1) then --stop jumping
					self.yoffset = 15
					self.state = 'attack'
				end
			end
		end
		
		if (self.beenHit == true) then
			if (self.hitTime > self.hitMax) then
				self.beenHit = false
				self.velocity = 0.25
				self.state = 'attack'
			else
				self.hitTime = self.hitTime + dt
			end
		end
		
		if (self.threatDistance < 0.5 and (self.attacktype == 0 or self.attacktype == 2 or (self.attacktype == 1 and self.fire == false))) then
			self.state = 'beenhit'
			self.beenHit = true
			self.hitTime = 0
			self.directionX = self.threatDirectionX
			self.directionY = self.threatDirectionY
			self.velocity = 3
			-- kill shuriken 
			MainLevel:killEnemy(self.threatId)
		end
	end
	
end

function Enemy:render(player_x, player_y, dir_x, dir_y, cam_x_plane, cam_y_plane, width, height, zbuffer, horiz, bottomview)

	--translate sprite position to relative to camera
    spriteX = self.x - player_x
    spriteY = self.y - player_y

    --transform sprite with the inverse camera matrix
    -- [ planeX   dirX ] -1                                       [ dirY      -dirX ]
    -- [               ]       =  1/(planeX*dirY-dirX*planeY) *   [                 ]
    -- [ planeY   dirY ]                                          [ -planeY  planeX ]

    invDet = 1.0 / (cam_x_plane * dir_y - dir_x * cam_y_plane) --required for correct matrix multiplication

    transformX = invDet * (dir_y * spriteX - dir_x * spriteY) - self.transformxoffset -- offset to correct sprite pos
    transformY = invDet * (-cam_y_plane * spriteX + cam_x_plane * spriteY)  --this is actually the depth inside the screen, that what Z is in 3D

    spriteScreenX = math.floor((width / 2) * (1 + transformX / transformY)) 
	
	if (self.texture == nil) then
		return
	end
	
	local twidth, theight = self.texture:getDimensions()
	local tqx, tqy, tqw, tqh = self.currentFrame:getViewport()
	local finalxcoord = 0
	local sizefactor = self.sizefactor
	local bufferindex = 0
	
	--calculate height of the sprite on screen
	spriteHeight = sizefactor/transformY --using 'transformY' instead of the real distance prevents fisheye

	
	for stripe = tqx, (tqx + tqw) do
		column = love.graphics.newQuad(stripe, 0, 1, tqh, twidth, theight)
		
		finalxcoord = spriteScreenX + (stripe - tqx)*spriteHeight
		bufferindex = math.floor(finalxcoord)

		if (bufferindex < width and bufferindex >= 0) then
			if(transformY > 0 and finalxcoord > 0 and finalxcoord < (width + self.size) and transformY < zbuffer[bufferindex]) then
				love.graphics.draw(self.texture, column, finalxcoord, height/2 + horiz + bottomview, 0, spriteHeight, spriteHeight, self.xoffset, self.yoffset)
			end
		end	
	end
	
	if (self.type ~= 2 and self.type ~= 3) then
		local centerpoint = math.floor(spriteScreenX + tqw*spriteHeight/2)
		if zbuffer[centerpoint] ~= nil and math.abs(transformY - zbuffer[centerpoint]) < 0.75 then --cheap collision detection with walls
		
			local actualdistance = math.abs(transformY - zbuffer[centerpoint])
			local dirdistance1 = 0
			local dirdistance2 = 0
			local dirdistance3 = 0
			local dirdistance4 = 0
			local dir = -1
			
			--check foward/backward/left/right directions and choose the one that avoid walls
			spriteX = self.x - player_x
			spriteY = (self.y + 1) - player_y
			
			transformX = invDet * (dir_y * spriteX - dir_x * spriteY) - self.transformxoffset -- offset to correct sprite pos
			transformY = invDet * (-cam_y_plane * spriteX + cam_x_plane * spriteY)
			spriteScreenX = math.floor((width / 2) * (1 + transformX / transformY)) 
			centerpoint = math.floor(spriteScreenX + tqw*spriteHeight/2)
			
			if (zbuffer[centerpoint] ~= nil) then
				dirdistance1 = math.abs(transformY - zbuffer[centerpoint])
				
				if (dirdistance1 > actualdistance) then
					actualdistance = dirdistance1
					dir = 0
				end
			end
			
			------------------------------------------------------------------
			spriteX = (self.x + 1) - player_x
			spriteY = self.y  - player_y
			
			transformX = invDet * (dir_y * spriteX - dir_x * spriteY) - self.transformxoffset -- offset to correct sprite pos
			transformY = invDet * (-cam_y_plane * spriteX + cam_x_plane * spriteY)
			spriteScreenX = math.floor((width / 2) * (1 + transformX / transformY)) 
			centerpoint = math.floor(spriteScreenX + tqw*spriteHeight/2)
			
			if (zbuffer[centerpoint] ~= nil) then
				dirdistance2 = math.abs(transformY - zbuffer[centerpoint])
				
				if (dirdistance2 > actualdistance) then
					actualdistance = dirdistance2
					dir = 1
				end
			end
			------------------------------------------------------------------
			spriteX = self.x - player_x
			spriteY = (self.y - 1) - player_y
			
			transformX = invDet * (dir_y * spriteX - dir_x * spriteY) - self.transformxoffset -- offset to correct sprite pos
			transformY = invDet * (-cam_y_plane * spriteX + cam_x_plane * spriteY)
			spriteScreenX = math.floor((width / 2) * (1 + transformX / transformY)) 
			centerpoint = math.floor(spriteScreenX + tqw*spriteHeight/2)
			

			if (zbuffer[centerpoint] ~= nil) then
				dirdistance3 = math.abs(transformY - zbuffer[centerpoint])
				
				if (dirdistance3 > actualdistance) then
					actualdistance = dirdistance3
					dir = 2
				end
			end
		
			------------------------------------------------------------------
			spriteX = (self.x - 1) - player_x
			spriteY = self.y - player_y
			
			transformX = invDet * (dir_y * spriteX - dir_x * spriteY) - self.transformxoffset -- offset to correct sprite pos
			transformY = invDet * (-cam_y_plane * spriteX + cam_x_plane * spriteY)
			spriteScreenX = math.floor((width / 2) * (1 + transformX / transformY)) 
			centerpoint = math.floor(spriteScreenX + tqw*spriteHeight/2)
			
			if (zbuffer[centerpoint] ~= nil) then
				dirdistance4 = math.abs(transformY - zbuffer[centerpoint])
				
				if (dirdistance4 > actualdistance) then
					actualdistance = dirdistance4
					dir = 3
				end
			end
			
			------------------------------------------------------------------
			
			if (dir == 0) then
				self.directionX = 0
				self.directionY = 1
			elseif (dir == 1) then
				self.directionX = 1
				self.directionY = 0
			elseif (dir == 2) then
				self.directionX = 0
				self.directionY = - 1
			elseif (dir == 3) then
				self.directionX = - 1
				self.directionY = 0
			end
		end
	end
end

function Enemy:setVelocity(v)
	self.velocity = v
end

function Enemy:getDirection()
	return self.directionX, self.directionY
end

function Enemy:setDirection(x, y)
	self.directionX = x
	self.directionY = y
end

function Enemy:setOriginator(id)
	self.originator = id
end

function Enemy:getOriginator()
	return self.originator
end

function Enemy:calcDistanceTo(x, y)
	if (self.type ~= 5) then
		if (self.beenHit == false) then
			self.directionX = (x - self.x)/math.sqrt((x - self.x)*(x - self.x) + (y - self.y)*(y - self.y))
			self.directionY = (y - self.y)/math.sqrt((x - self.x)*(x - self.x) + (y - self.y)*(y - self.y))
		end
	end	
	
	self.currentDistance = math.sqrt((x - self.x)*(x - self.x) + (y - self.y)*(y - self.y))
end

function Enemy:distanceTo(x, y)
	return math.sqrt((x - self.x)*(x - self.x) + (y - self.y)*(y - self.y))
end

function Enemy:getDistance()
	return self.currentDistance
end

