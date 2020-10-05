--[[
    This is CS50 2019.
    Final Project

    -- Level Class --

    Author: Cristian Villalba
    cristian.villalba@gmail.com
]]

--ffi = require('ffi')

Level = Class{}

function Level:init(randlevel, currentlevel)
	self.sectorsize = 2.0
	self.sectorwalls = 24
	self.sectors = 	{}
	self.walls = {}
	self.textures = {}
	self.texturesData = {}
	self.texturesDataPointers = {}
	self.texturesStrip = {}
	self.enemies = {}
	self.enemyindex = 3
	self.flagpos = {0,0,0} --a table that saves the pos as far as the player can go to put the winning flag (x,y, steps)
	
	
	self:initTextures()
	
	self:initLevel(randlevel, currentlevel)
	
	if (randlevel == 1 and currentlevel ~= -1 and currentlevel ~= -2) then 
		self:initEnemies(currentlevel)
		self:initFlag()
	end
end

function Level:initTextures()

	self.texturesData[0]= love.image.newImageData('textures/brick.png')
	--self.texturesDataPointers[0] = ffi.cast("uint8_t*", self.texturesData[0]:getFFIPointer())
	self.textures[0] = love.graphics.newImage(self.texturesData[0])
	
	self.texturesData[1]= love.image.newImageData('textures/floor.png')
	--self.texturesDataPointers[1] = ffi.cast("uint8_t*", self.texturesData[1]:getFFIPointer())
	self.textures[1] = love.graphics.newImage(self.texturesData[1])
	
	self.texturesData[2]= love.image.newImageData('textures/step.png')
	--self.texturesDataPointers[2] = ffi.cast("uint8_t*", self.texturesData[2]:getFFIPointer())
	self.textures[2] = love.graphics.newImage(self.texturesData[2])
	
	self.wallStripsW = love.graphics.newSpriteBatch(self.textures[0], VIRTUAL_WIDTH, 'stream')
	self.wallStripsF = love.graphics.newSpriteBatch(self.textures[2], VIRTUAL_WIDTH, 'stream')
	self.wallStripsC = love.graphics.newSpriteBatch(self.textures[2], VIRTUAL_WIDTH, 'stream')
		
	--generate texture strips WARNING this is really hardcoded so the wall textures should be 48x48
	for i = 0, 48 do
		self.texturesStrip[i] = love.graphics.newQuad(i, 0, 1, 48, 48, 48)
	end
end

function Level:initLevel(randlevel, currentlevel)	

	if (randlevel == 1) then
		if (currentlevel == -1) then
			self:initDemoMap()
		elseif (currentlevel == -2) then
			--self:readMap('c:\\harvard\\buildtribute\\maps\\room.map')
			--self:readMap('c:\\harvard\\buildtribute\\maps\\duke.map')
			--self:readMap('c:\\harvard\\buildtribute\\maps\\redrock.map')
			self:readMap('c:\\harvard\\buildtribute\\maps\\1hit2kil.map')
		else
			self:initRandomMap(currentlevel)
		end
	else
		self.sectors[0] = 	{ 
						id = 0, 
						startWall = 0,
						textureidfloor = 1,
						sloped = 0,
						floorz = 0,
						numWalls = 6
						}
		self.walls[0] =	{
						x0 = 2,
						y0 = 1,
						x1 = 2,
						y1 = -1,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
		self.walls[1] =	{
							x0 = 2,
							y0 = -1,
							x1 = 0,
							y1 = -2,
							drawable = 1,
							textureid = 0,
							nextsector = -1
						}
		self.walls[2] =	{
							x0 = 0,
							y0 = -2,
							x1 = -2,
							y1 = -1,
							drawable = 1,
							textureid = 0,
							nextsector = -1
						}
		self.walls[3] =	{
							x0 = -2,
							y0 = -1,
							x1 = -2,
							y1 = 1,
							drawable = 1,
							textureid = 0,
							nextsector = -1
						}
		self.walls[4] =	{
							x0 = -2,
							y0 = 1,
							x1 = 0,
							y1 = 2,
							drawable = 1,
							textureid = 0,
							nextsector = -1
						}
		self.walls[5] =	{
							x0 = 0,
							y0 = 2,
							x1 = 2,
							y1 = 1,
							drawable = 1,
							textureid = 0,
							nextsector = -1
						}
	end
	
    
end


function Level:readMap(path)
	local conversion = 1500
	local inp = assert(io.open(path, "rb"))
	local mapversion
	local posx
	local posy
	local posz
	local ang
	local currsect
	local numsect
	local numwalls
	local issloped
	
	local wallptr
	local wallnum
	local ceilingz
	local floorz
	local ceilingstat
	local floorstat
	local ceilingpicnum
	local ceilingheinum
	local ceilingshade
	local ceilingpal
	local ceilingxpanning
	local ceilingypanning
	local floorpicnum
	local floorheinum
	local floorshade
	local floorpal
	local floorxpanning
	local floorypanning
	local visibility
	local filler
	local lotag
	local hitag
	local extra
	
	local x
	local y
	local point2
	local nextwall
	local nextsector
	local cstat
	local picnum
	local overpicnum
	local shade
	local pal
	local xrepeat
	local yrepeat
	local xpanning
	local ypanning
	local wlotag
	local whitag
	local wextra
	
	local bytes = inp:read(4)
	if bytes == nil then return end -- EOF
	mapversion = love.data.unpack("<i4", bytes)
	
	bytes = inp:read(4)
	posx = love.data.unpack("<i4", bytes)
	
	bytes = inp:read(4)
	posy = love.data.unpack("<i4", bytes)
	
	bytes = inp:read(4)
	posz = love.data.unpack("<i4", bytes)
	
	bytes = inp:read(2)
	ang = love.data.unpack("<i2", bytes)
	
	bytes = inp:read(2)
	currsect = love.data.unpack("<i2", bytes)
	
	bytes = inp:read(2)
	numsect = love.data.unpack("<i2", bytes)
		
	print('map version: ' .. mapversion)
	print('posx: ' .. posx)
	print('posy: ' .. posy)
	print('posz: ' .. posz)
	print('ang: ' .. ang)
	print('currentsector: ' .. currsect)
	print('numsectors: ' .. numsect)
	
	PLAYER_X = posx / conversion
	PLAYER_Y = posy / conversion
	LAST_SECTOR_ID = currsect
	
	for s = 1, numsect do
		bytes = inp:read(2)
		wallptr = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		wallnum = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(4)
		ceilingz = love.data.unpack("<i4", bytes)
		
		bytes = inp:read(4)
		floorz = love.data.unpack("<i4", bytes)
		
		bytes = inp:read(2)
		ceilingstat = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		floorstat = love.data.unpack("<i2", bytes)
		if (bit.band(0x00000002, floorstat) == 2) then
			issloped = 1
		else
			issloped = 0
		end
		
		bytes = inp:read(2)
		ceilingpicnum = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		ceilingheinum = love.data.unpack("<i2", bytes)
		
		ceilingshade = inp:read(1)
		ceilingpal = inp:read(1)
		ceilingxpanning = inp:read(1)
		ceilingypanning = inp:read(1)
		
		bytes = inp:read(2)
		floorpicnum = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		floorheinum = love.data.unpack("<i2", bytes)
		
		if ( s - 1 ) == 38 then
			print('slope in sector 38: ' .. floorheinum)
		end
		
		floorheinum = (floorheinum) / 2580 ---change range to 0 --- 1 with 1 equals PI
		
		--if (floorheinum <= 1 and floorheinum >= 0.5) then
		--	floorheinum = (floorheinum - 0.5) / 0.5 * 2
		--end
		
		floorheinum = -floorheinum * 3.14159
		
		if ( s - 1 ) == 38 then
			print('slope in sector: ' .. floorheinum)
		end
		
		floorshade = inp:read(1)
		floorpal = inp:read(1)
		floorxpanning = inp:read(1)
		floorypanning = inp:read(1)
		visibility = inp:read(1)
		filler = inp:read(1)
		
		bytes = inp:read(2)
		lotag = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		hitag = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		extra = love.data.unpack("<i2", bytes)
		
		self.sectors[(s - 1)] = 	{ 
						id = (s - 1), 
						startWall = wallptr,
						textureidfloor = 1,
						textureidceiling = 1,
						sloped = issloped,
						--slopedangle = -1.55,
						slopedangle = floorheinum,
						slopedindex = wallptr,
						ceilingz = 0,
						floorz = -(floorz - 8192)/(conversion),
						numWalls = wallnum
						}
	end
	
	bytes = inp:read(2)
	numwalls = love.data.unpack("<i2", bytes)
	
	print('numwalls: ' .. numwalls)
	local innerwalls = {}
	
	for s = 1, numwalls do
		bytes = inp:read(4)
		x = love.data.unpack("<i4", bytes)
			
		bytes = inp:read(4)
		y = love.data.unpack("<i4", bytes)
		
		bytes = inp:read(2)
		point2 = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		nextwall = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		nextsector = love.data.unpack("<i2", bytes)
		
		if (nextsector == 65535) then
			nextsector = -1
		end
		
		bytes = inp:read(2)
		cstat = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		picnum = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		overpicnum = love.data.unpack("<i2", bytes)
		
		shade = inp:read(1)
		pal = inp:read(1)
		xrepeat = inp:read(1)
		yrepeat = inp:read(1)
		xpanning = inp:read(1)
		ypanning = inp:read(1)
		
		bytes = inp:read(2)
		wlotag = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		whitag = love.data.unpack("<i2", bytes)
		
		bytes = inp:read(2)
		wextra = love.data.unpack("<i2", bytes)
		
		innerwalls[(s-1)] = {
			x0 = x,
			y0 = y,
			point = point2,
			next = nextsector
		}
		
		--print('x ' .. x .. ' y ' .. y .. ' point2 ' .. point2 .. ' nextsector: ' .. nextsector) 
		--[[self.walls[(s-1)] =	{
						x0 = 0,
						y0 = 0,
						x1 = 0,
						y1 = -1,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}]]
	end
	
	local index = 0
	
	for x in pairs(innerwalls) do
		innerwalls[x]['x1'] = innerwalls[innerwalls[x]['point']]['x0']
		innerwalls[x]['y1'] = innerwalls[innerwalls[x]['point']]['y0']
		
		self.walls[index] = {
			x1 = innerwalls[x]['x0'] / conversion,
			y1 = innerwalls[x]['y0'] / conversion,
			x0 = innerwalls[x]['x1'] / conversion,
			y0 = innerwalls[x]['y1'] / conversion,
			drawable = 1,
			textureid = 0,
			nextsector = innerwalls[x]['next']
		}
		
		
		index = index + 1
	end
	
	--[[
	for x in pairs(self.walls) do
		print( self.walls[x]['x0'])
		print( self.walls[x]['y0'])
		print( self.walls[x]['x1'])
		print( self.walls[x]['y1'])
	end
	]]
	
    assert(inp:close())
end

function Level:initDemoMap()	
	---level example when I was debugging
	self.sectors[0] = 	{ 
						id = 0, 
						startWall = 0,
						textureidfloor = 1,
						textureidceiling = 1,
						sloped = 0,
						ceilingz = 0,
						floorz = 0,
						numWalls = 6
						}
	self.sectors[1] = 	{
						id = 1, 
						startWall = 6,
						textureidfloor = 1,
						textureidceiling = 1,
						sloped = 1,
						slopedangle = -1.55,
						slopedindex = 7,
						ceilingz = 0,
						floorz = 0,
						numWalls = 7
						}
	self.sectors[2] = 	{
						id = 2, 
						startWall = 13,
						textureidfloor = 1,
						textureidceiling = 1,
						sloped = 0,
						ceilingz = 0,
						floorz = 0,
						numWalls = 3
						}	
	self.walls[0] =	{
						x0 = 0,
						y0 = 0,
						x1 = 0,
						y1 = -1,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[1] =	{
						x0 = 0,
						y0 = -1,
						x1 = -1,
						y1 = -2,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[2] =	{
						x0 = -1,
						y0 = -2,
						x1 = -2,
						y1 = -1,
						drawable = 0,
						textureid = 0,
						nextsector = 1
					}
	self.walls[3] =	{
						x0 = -2,
						y0 = -1,
						x1 = -2,
						y1 = 0,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[4] =	{
						x0 = -2,
						y0 = 0,
						x1 = -1,
						y1 = 1,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[5] =	{
						x0 = -1,
						y0 = 1,
						x1 = 0,
						y1 = 0,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[6] =	{
						x0 = -1,
						y0 = -2,
						x1 = -1,
						y1 = -7,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[7] =	{
						x0 = -1,
						y0 = -7,
						x1 = -7,
						y1 = -7,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[8] =	{
						x0 = -7,
						y0 = -7,
						x1 = -2,
						y1 = -1,
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[9] =	{
						x0 = -2,
						y0 = -1,
						x1 = -1,
						y1 = -2,
						drawable = 0,
						textureid = 0,
						innerportal = 1,
						nextsector = 0
					}
	self.walls[10] =	{ --using portals to inner sectors
						x1 = -2,
						y1 = -2,
						x0 = -2,
						y0 = -5,
						drawable = 1,
						textureid = 0,
						floorstepid = 2,
						innerportal = 1,
						nextsector = 2
					}
	self.walls[11] =	{ --using portals to inner sectors
						x1 = -2,
						y1 = -5,
						x0 = -4,
						y0 = -5,
						drawable = 1,
						textureid = 0,
						floorstepid = 2,
						innerportal = 1,
						nextsector = 2
					}
	self.walls[12] =	{ --using portals to inner sectors
						x1 = -4,
						y1 = -5,
						x0 = -2,
						y0 = -2,
						drawable = 1,
						textureid = 0,
						floorstepid = 2,
						innerportal = 1,
						nextsector = 2
					}
	self.walls[13] =	{ --inner sector
						x0 = -2,
						y0 = -2,
						x1 = -2,
						y1 = -5,
						drawable = 1,
						textureid = 0,
						nextsector = 1
					} 
	self.walls[14] =	{ --inner sector
						x0 = -2,
						y0 = -5,
						x1 = -4,
						y1 = -5,
						drawable = 1,
						textureid = 0,
						nextsector = 1
					}
	self.walls[15] =	{ --inner sector
						x0 = -4,
						y0 = -5,
						x1 = -2,
						y1 = -2,
						drawable = 1,
						textureid = 0,
						nextsector = 1
					}
end

function Level:initEnemies(currentlevel)
	local attacktype = love.math.random(0,2)

	--keep in mind that sort works with tables starting with index == 1
	if currentlevel == 3 then
		self.enemies[2] = Enemy(-10.75, -12.75, 0, 2, attacktype)
		self.enemyindex = 3
	elseif currentlevel == 4 then
		self.enemies[2] = Enemy(5.75, 6.75, 1, 2, attacktype)
		self.enemyindex = 3
	elseif currentlevel == 5 then
		self.enemies[2] = Enemy(6.0, -18.75, 0, 2, attacktype)
		self.enemies[3] = Enemy(-15.75, -1.75, 1, 3, attacktype)
		self.enemyindex = 4
	elseif currentlevel == 6 then
		self.enemies[2] = Enemy(4.75, -13.75, 0, 2, attacktype)
		self.enemies[3] = Enemy(14.75, 2.75, 1, 3, attacktype)
		self.enemyindex = 4
	elseif currentlevel == 7 then
		self.enemies[2] = Enemy(0, -4.75, 0, 2, attacktype)
		self.enemies[3] = Enemy(-11.75, -18.75, 1, 3, attacktype)
		self.enemies[4] = Enemy(10.75, -14.75, 1, 4, attacktype)
		self.enemyindex = 5
	elseif currentlevel == 8 then
		self.enemies[2] = Enemy(0, -10.0, 0, 2, attacktype)
		self.enemies[2]:setVelocity(0.5)
		self.enemies[3] = Enemy(10.75, -38.75, 1, 3, attacktype)
		self.enemies[4] = Enemy(5.75, -48.75, 1, 4, attacktype)
		self.enemies[4]:setVelocity(0.75)
		self.enemies[5] = Enemy(4.75, -66.75, 1, 5, attacktype)
		self.enemyindex = 6
	elseif currentlevel == 9 then
		self.enemies[2] = Enemy(0, -7.25, 0, 2, attacktype)
		self.enemies[3] = Enemy(-4.75, -14.75, 1, 3, attacktype)
		self.enemies[4] = Enemy(-6.75, -14.75, 1, 4, attacktype)
		self.enemies[5] = Enemy(-18.75, -13.75, 1, 5, attacktype)
		self.enemies[6] = Enemy(-10.75, 8.75, 1, 6, attacktype)
		self.enemies[7] = Enemy(-10.75, 7.75, 1, 7, attacktype)
		
		self.enemies[2]:setVelocity(0.75)
		self.enemies[3]:setVelocity(0.75)
		self.enemies[4]:setVelocity(0.75)
		self.enemies[5]:setVelocity(1.00)
		self.enemies[6]:setVelocity(0.75)
		self.enemies[7]:setVelocity(0.75)
		
		self.enemyindex = 8
	elseif currentlevel >= 10 then
		self.enemies[2] = Enemy(-5, -4.25, 0, 2, attacktype)
		self.enemies[3] = Enemy(-4, -4.25, 1, 3, attacktype)
		self.enemies[4] = Enemy(-16.75, 7.75, 1, 4, attacktype)
		self.enemies[5] = Enemy(21.75, 1.75, 1, 5, attacktype)
		self.enemies[6] = Enemy(14.75, 0, 1, 6, attacktype)
		self.enemies[7] = Enemy(15.75, 18.75, 1, 7, attacktype)
		self.enemies[8] = Enemy(37.75, -2.75, 1, 8, attacktype)
		self.enemies[9] = Enemy(54.75, -18.75, 1, 9, attacktype)
		
		self.enemies[2]:setVelocity(1.00)
		self.enemies[3]:setVelocity(1.00)
		self.enemies[4]:setVelocity(1.00)
		self.enemies[5]:setVelocity(1.00)
		self.enemies[6]:setVelocity(1.00)
		self.enemies[7]:setVelocity(1.00)
		self.enemies[8]:setVelocity(1.00)
		self.enemies[9]:setVelocity(1.00)
		
		self.enemyindex = 10
	end
	
	--self.enemies[2] = Enemy(0, -1, 0, 2)
	--self.enemies[2] = Enemy(0, -3, 1)
end

function Level:initFlag()
	local finalflagx = self.flagpos[1]*(self.sectorsize + 2*self.sectorsize/6)
	local finalflagy = self.flagpos[2]*(self.sectorsize + 2*self.sectorsize/6)
	
	--keep in mind that sort works with tables starting with index == 1
	self.enemies[1] = Enemy(finalflagx, finalflagy, 2, 1)
end

function Level:addEnemy(x , y, type)
	self.enemies[self.enemyindex] = Enemy(x, y, type, self.enemyindex)
	self.enemyindex = self.enemyindex + 1
	
	return (self.enemyindex - 1)
end

function Level:killEnemy(index)
	table.remove(self.enemies, index)
	self.enemyindex = self.enemyindex - 1
end

function Level:setVelocity(v, index)
	self.enemies[index]:setVelocity(v)
end

function Level:setDirection(x, y, index)
	self.enemies[index]:setDirection(x , y)
end

function Level:setOriginator(index, id)
	self.enemies[index]:setOriginator(id)
end

function Level:getSectors()
	return self.sectors
end


function Level:getWalls()
	return self.walls
end

--[[
	This function procedurally generates a map based in different sectors and advancing into random direction some defined steps
	Sectors are all generated based on this configuration:
	     
		              -w10--
				  w11|      |w9 
			  /-w12--|      |--w8--\
			 /w13                 w7\
			/                        \
			|                         |
			|w14                 w6   |
	  --w15|--                        --w5--
	 |                                      |
	 |w16                                 w4|
	  --w17--                         --w3--
			|                         |
			|w18                 w2   |
			\                        /
			 \w19                w1 /
			  \--w20-|      |--w0--/
                  w21|      |w23			
                      -w22--
			
	Each sector is connected with a portal w3 or w1 or w7 or w15
]]
function Level:initRandomMap(seed)
	self.mazew = 10
	self.mazeh = 10
	self.startingx = 0
	self.startingy = 0
	self.mazepoints = {}
	self.bifurcationpoints = {}
	
	self.mazepoints[0] = {}
	self.mazepoints[0][0] = 1
	
	--print map in the center of the screen
	--only for debugging purposes
	self.finalmaze = {}
	self.finalmaze[0] = {}
	self.finalmaze[0][0] = 1
	
	
	local fowardsteps = math.random(2,3)
	local randir = 3 --go up at the begining
	local comingfrom = 0
	local direction = {0,1,2,3}
	
	local sectorindex = 0
	local sectortoconnect = 0
	local wallindex = 0
	local first = true
	local safesteps = 0
	local hascollide = true
	local bifurcationstep = 0
	local bifurcationindex = 0
	
	local accumulatedsteps = 0
	local maxsteps = 0 --this is the final length of the level

	if (seed == 0) then
		math.randomseed(10)
		maxsteps = 3
	elseif(seed == 1) then
		math.randomseed(15)
		maxsteps = 5
	elseif(seed == 2) then
		math.randomseed(25)
		maxsteps = 10
	elseif(seed == 3) then
		math.randomseed(20)
		maxsteps = 10
	elseif(seed == 4) then
		math.randomseed(142)
		maxsteps = 15
	elseif(seed == 5) then
		math.randomseed(77)
		maxsteps = 20
	elseif(seed == 6) then
		math.randomseed(89)
		maxsteps = 25
	elseif(seed == 7) then
		math.randomseed(76)
		maxsteps = 25
	elseif(seed == 8) then
		math.randomseed(755)
		maxsteps = 30
	elseif(seed == 9) then
		math.randomseed(932)
		maxsteps = 33
	elseif(seed == 10) then
		math.randomseed(20170425)
		maxsteps = 50
	else
		math.randomseed(os.time())
		maxsteps = 50
	end
	
	for n = 1, maxsteps do
		
		while(hascollide == true and table.getn(direction) > 0) do
			hascollide = self:checkCorridor(self.startingx, self.startingy, direction[randir], fowardsteps)
			
			if (hascollide == true) then
				table.remove(direction, randir)
				randir = math.random(1, table.getn(direction))
				fowardsteps = 2
			end
		end
		
		if (hascollide == false and first == false) then
			
			
			if direction[randir] == 0 then
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 1 , 2) --save other direction for future bifurcation
				
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {1, self.startingx + 1, self.startingy, sectorindex - 1, accumulatedsteps})
				end
				
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 3 , 2) --save other direction for future bifurcation
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {3, self.startingx - 1, self.startingy, sectorindex - 1, accumulatedsteps})
				end
				
				self.startingy = self.startingy + 1
				
			elseif direction[randir] == 1 then
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 0 , 2) --save other direction for future bifurcation
				
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {0, self.startingx, self.startingy + 1, sectorindex - 1, accumulatedsteps})
				end
				
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 2 , 2) --save other direction for future bifurcation
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {2, self.startingx, self.startingy - 1, sectorindex - 1, accumulatedsteps})
				end
			
			
				self.startingx = self.startingx + 1
			
			elseif direction[randir] == 2 then
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 1 , 2) --save other direction for future bifurcation
				
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {1, self.startingx + 1, self.startingy, sectorindex - 1, accumulatedsteps})
				end
				
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 3 , 2) --save other direction for future bifurcation
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {3, self.startingx - 1, self.startingy, sectorindex - 1, accumulatedsteps})
				end
			
				self.startingy = self.startingy - 1
				
			else
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 0 , 2) --save other direction for future bifurcation
				
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {0, self.startingx , self.startingy + 1, sectorindex - 1, accumulatedsteps})
				end
				
				bifurcationstep = self:checkCorridor(self.startingx, self.startingy, 2 , 2) --save other direction for future bifurcation
				if (bifurcationstep == false) then
					table.insert(self.bifurcationpoints, {2, self.startingx, self.startingy - 1, sectorindex - 1, accumulatedsteps})
				end
				
				self.startingx = self.startingx - 1
			end
			
			fowardsteps = fowardsteps - 1
			sectortoconnect = sectorindex - 1
		end
		
		if (hascollide == true ) then
			local collidecorridor = true
			while (collidecorridor == true and table.getn(self.bifurcationpoints) > 0) do
	
				bifurcationindex = math.random(#self.bifurcationpoints)
				
				if (self.bifurcationpoints[bifurcationindex] == nil) then
					break --no more room to advance
				end
				
				self.startingx = self.bifurcationpoints[bifurcationindex][2]
				self.startingy = self.bifurcationpoints[bifurcationindex][3]
				sectortoconnect = self.bifurcationpoints[bifurcationindex][4]
				accumulatedsteps = self.bifurcationpoints[bifurcationindex][5]
				direction = { self.bifurcationpoints[bifurcationindex][1] }
				randir = 1
				collidecorridor = self:checkCorridor(self.startingx, self.startingy, direction[randir] , 2) --check how far we can go
				
				if (collidecorridor == true) then
					table.remove(self.bifurcationpoints, bifurcationindex)
				end
				--clean bifurcation points
				--for k in pairs(self.bifurcationpoints) do
				--	self.bifurcationpoints[k] = nil
				--end
			end
			
			if (collidecorridor == true) then
				--no more room so finish
				break
			else
				for k in pairs(self.bifurcationpoints) do
					self.bifurcationpoints[k] = nil
				end
				
				fowardsteps = 2
			end
		end
		
		self:generateCorridor(self.startingx, self.startingy, direction[randir], fowardsteps)
		self:generateRoom(first, self.startingx, self.startingy, sectorindex, sectortoconnect, wallindex, direction[randir], fowardsteps)
		accumulatedsteps = accumulatedsteps + fowardsteps
		
		if (self.flagpos[3] < accumulatedsteps) then
			self.flagpos[1] = self.startingx
			self.flagpos[2] = self.startingy
			self.flagpos[3] = accumulatedsteps
		end
			
		fowardsteps = 2
		
		comingfrom = direction[randir]
		direction = {0,1,2,3}
		
		if (comingfrom == 1) then
			table.remove(direction, 4) --remove up direction from future move
		elseif (comingfrom == 2) then
			table.remove(direction, 1) --remove left direction from future move
		elseif(comingfrom == 3) then
			table.remove(direction, 2) --remove down direction from future move
		else
			table.remove(direction, 3) --remove right direction from future move
		end

		randir = math.random(1,3)
		hascollide = true
		sectorindex = sectorindex + 1
		wallindex = wallindex + self.sectorwalls --is the amount of walls in a sector
		
		if (first == true) then
			first = false
		end
	end
		
	--clear mazepoint table
	for x in pairs(self.mazepoints) do
		for y in pairs(self.mazepoints[x]) do
			self.mazepoints[x][y] = nil 
		end
	end
	
	-- Go back the random seed to the initial state
	math.randomseed(os.time())
end

--[[
	This function checks if we can advance across a direction
]]
function Level:checkCorridor(x,y,dir,steps)
	local safesteps = 0
	local foundcollision = false
	
	for n = 1, steps do --this will start from pos 1 and not checking the actual x;y
		if (dir == 3) then
			if self.mazepoints[x-n] == nil then
				self.mazepoints[x-n] = {}
			end
				
			if self.mazepoints[x-n][y] == 1 then
				foundcollision = true
				break --found another sector so stop
			end
		elseif (dir == 2) then
			if self.mazepoints[x] == nil then
				self.mazepoints[x] = {}
			end
			
			if self.mazepoints[x][y-n] == 1 then
				foundcollision = true
				break --found another sector so stop
			end
		elseif (dir == 1) then
			if self.mazepoints[x+n] == nil then
				self.mazepoints[x+n] = {}
			end
					
			if self.mazepoints[x+n][y] == 1 then
				foundcollision = true
				break --found another sector so stop
			end
		else
			if self.mazepoints[x] == nil then
				self.mazepoints[x] = {}
			end
			
			if self.mazepoints[x][y+n] == 1 then
				foundcollision = true
				break --found another sector so stop
			end
		end
	end
	
	return foundcollision
end



--[[
	This function facilitates generation of random map
	Capable to check if we already populate this x,y with a sector
]]
function Level:generateCorridor(x,y,dir,steps)
	local safesteps = 0
	local foundcollision = false
	
	for n = 0, steps do
		if (dir == 3) then
			if self.mazepoints[x-n] == nil then
				self.mazepoints[x-n] = {}
			end
				
			if self.mazepoints[x-n][y] ~= 1 then
				self.mazepoints[x-n][y] = 1
				safesteps = safesteps + 1
			--else
			--	foundcollision = true
			--	break --found another sector so stop
			end
		elseif (dir == 2) then
			if self.mazepoints[x] == nil then
				self.mazepoints[x] = {}
			end
			
			if self.mazepoints[x][y-n] ~= 1  then
				self.mazepoints[x][y-n] = 1
				safesteps = safesteps + 1
			--else
			--	foundcollision = true
			--	break --found another sector so stop
			end
		elseif (dir == 1) then
			if self.mazepoints[x+n] == nil then
				self.mazepoints[x+n] = {}
			end
			
			if self.mazepoints[x+n][y] ~= 1 then
				self.mazepoints[x+n][y] = 1
				safesteps = safesteps + 1
			--else
				--foundcollision = true
				--break --found another sector so stop
			end
		else
			if self.mazepoints[x] == nil then
				self.mazepoints[x] = {}
			end
			
			if self.mazepoints[x][y+n] ~= 1 then
				self.mazepoints[x][y+n] = 1
				safesteps = safesteps + 1
			--else
				--foundcollision = true
				--break --found another sector so stop
			end
		end
	end
	
	return {safesteps, foundcollision}
end

function Level:generateRoom(first, x, y, sectorindex, sectortoconnect, wallindex, direction, steps)

	--print map in the center of the screen
	--only for debugging purposes
	for j = 0, steps do
		if direction == 0 then
			
			if (self.finalmaze[x] == nil) then
				self.finalmaze[x] = {}
			end
			if self.finalmaze[x][y+j] == nil then
				self.finalmaze[x][y+j] = {}
			end	
			self.finalmaze[x][y+j] = 1
			
			for k in pairs(self.bifurcationpoints) do
				if  x == self.bifurcationpoints[k][2] and (y+j) == self.bifurcationpoints[k][3] then
					table.remove(self.bifurcationpoints, k)
				end
			end
		end
		
		if direction == 1 then
			if (self.finalmaze[x + j] == nil) then
				self.finalmaze[x + j] = {}
			end
			if self.finalmaze[x + j][y] == nil then
				self.finalmaze[x + j][y] = {}
			end	
			
			self.finalmaze[x + j][y] = 1
			
			for k in pairs(self.bifurcationpoints) do
				if  (x + j) == self.bifurcationpoints[k][2] and y == self.bifurcationpoints[k][3] then
					table.remove(self.bifurcationpoints, k)
				end
			end
		end
		
		if direction == 2 then
			if (self.finalmaze[x] == nil) then
				self.finalmaze[x] = {}
			end
			if self.finalmaze[x][y - j]== nil then
				self.finalmaze[x][y - j] = {}
			end	
			self.finalmaze[x][y - j] = 1
			
			for k in pairs(self.bifurcationpoints) do
				if  x == self.bifurcationpoints[k][2] and (y - j) == self.bifurcationpoints[k][3] then
					table.remove(self.bifurcationpoints, k)
				end
			end
		end
		
		if direction  == 3 then
			if (self.finalmaze[x - j] == nil) then
				self.finalmaze[x - j] = {}
			end
			if self.finalmaze[x - j][y]== nil then
				self.finalmaze[x - j][y] = {}
			end	
			self.finalmaze[x - j][y] = 1
			
			for k in pairs(self.bifurcationpoints) do
				if  (x - j )== self.bifurcationpoints[k][2] and y == self.bifurcationpoints[k][3] then
					table.remove(self.bifurcationpoints, k)
				end
			end
		end
	end
	--print map in the center of the screen
	--only for debugging purposes

	self.sectors[sectorindex] = 	{ 
						id = sectorindex, 
						startWall = wallindex,
						textureidfloor = 1,
						textureidceiling = 1,
						ceilingz = 0,
						floorz = 0,
						numWalls = self.sectorwalls
						}
	self.walls[wallindex] =	{
						x0 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = 2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 1] =	{
						x0 = 2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = 2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 2] =	{
						x0 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = 2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 3] =	{
						x0 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 4] =	{
						x0 = self.sectorsize/2 + self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 5] =	{
						x0 = self.sectorsize/2 + self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 6] =	{
						x0 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 7] =	{
						x0 = self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = 2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 8] =	{
						x0 = 2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 9] =	{
						x0 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 - self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 10] =	{
						x0 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 - self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 - self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 11] =	{
						x0 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 - self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 12] =	{
						x0 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 13] =	{
						x0 = -2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 14] =	{
						x0 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 15] =	{
						x0 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/2 - self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 16] =	{
						x0 = -self.sectorsize/2 - self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = -self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/2 - self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 17] =	{
					x0 = -self.sectorsize/2 - self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
					y0 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
					x1 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
					y1 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
					drawable = 1,
					textureid = 0,
					nextsector = -1
				}
	self.walls[wallindex + 18] =	{
						x0 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = 2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 19] =	{
						x0 = -self.sectorsize/2 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = 2*self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 20] =	{
						x0 = -2*self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 21] =	{
					x0 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
					y0 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
					x1 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
					y1 = self.sectorsize/2 + self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
					drawable = 1,
					textureid = 0,
					nextsector = -1
				}
	self.walls[wallindex + 22] =	{
						x0 = -self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/2 + self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/2 + self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}
	self.walls[wallindex + 23] =	{
						x0 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y0 = self.sectorsize/2 + self.sectorsize/6 + y*(self.sectorsize + 2*self.sectorsize/6),
						x1 = self.sectorsize/6 + x*(self.sectorsize + 2*self.sectorsize/6),
						y1 = self.sectorsize/2 + y*(self.sectorsize + 2*self.sectorsize/6),
						drawable = 1,
						textureid = 0,
						nextsector = -1
					}

	if direction == 0 then
		self:translateWallpoints(wallindex + 15, direction,steps)
		self:translateWallpoints(wallindex + 16, direction,steps)
		self:translateWallpoints(wallindex + 17, direction,steps)
		self:translateWallpoints(wallindex + 18, direction,steps)
		self:translateWallpoints(wallindex + 19, direction,steps)
		self:translateWallpoints(wallindex + 20, direction,steps)
		self:translateWallpoints(wallindex + 21, direction,steps)
		self:translateWallpoints(wallindex + 22, direction,steps)
		self:translateWallpoints(wallindex + 23, direction,steps)
		
		self:translateWallpoints(wallindex + 0, direction,steps)
		self:translateWallpoints(wallindex + 1, direction,steps)
		self:translateWallpoints(wallindex + 2, direction,steps)
		self:translateWallpoints(wallindex + 3, direction,steps)
		self:translateWallpoints(wallindex + 4, direction,steps)
		self:translateWallpoints(wallindex + 5, direction,steps)
		
		self.walls[wallindex + 6].y0 = self.walls[wallindex + 5].y1  --connect extended walls
		self.walls[wallindex + 14].y1 = self.walls[wallindex + 15].y0 --connect extended walls
		
		self.startingy = self.startingy + steps
		
		if (first == false) then
			self.walls[wallindex + 10].drawable = 0
			self.walls[wallindex + 10].nextsector = sectortoconnect
			
			self.walls[self.sectorwalls * sectortoconnect + 22].drawable = 0 --also put a portal in the previous sector wall
			self.walls[self.sectorwalls * sectortoconnect + 22].nextsector = sectorindex --also put a portal in the previous sector wall
		end
		
	elseif direction == 1 then
		self:translateWallpoints(wallindex + 21, direction,steps)
		self:translateWallpoints(wallindex + 22, direction,steps)
		self:translateWallpoints(wallindex + 23, direction,steps)
		self:translateWallpoints(wallindex + 0, direction,steps)
		self:translateWallpoints(wallindex + 1, direction,steps)
		self:translateWallpoints(wallindex + 2, direction,steps)
		self:translateWallpoints(wallindex + 3, direction,steps)
		self:translateWallpoints(wallindex + 4, direction,steps)
		self:translateWallpoints(wallindex + 5, direction,steps)
		
		self:translateWallpoints(wallindex + 6, direction,steps)
		self:translateWallpoints(wallindex + 7, direction,steps)
		self:translateWallpoints(wallindex + 8, direction,steps)
		self:translateWallpoints(wallindex + 9, direction,steps)
		self:translateWallpoints(wallindex + 10, direction,steps)
		self:translateWallpoints(wallindex + 11, direction,steps)
		
		self.walls[wallindex + 12].x0 = self.walls[wallindex + 11].x1  --connect extended walls
		self.walls[wallindex + 20].x1 = self.walls[wallindex + 21].x0 --connect extended walls
		
		self.startingx = self.startingx + steps
		
		if (first == false) then
			self.walls[wallindex + 16].drawable = 0
			self.walls[wallindex + 16].nextsector = sectortoconnect
			
			self.walls[self.sectorwalls * sectortoconnect + 4].drawable = 0 --also put a portal in the previous sector wall
			self.walls[self.sectorwalls * sectortoconnect + 4].nextsector = sectorindex --also put a portal in the previous sector wall
		
		end
		
	elseif direction == 2 then
		self:translateWallpoints(wallindex + 3, direction,steps)
		self:translateWallpoints(wallindex + 4, direction,steps)
		self:translateWallpoints(wallindex + 5, direction,steps)
		self:translateWallpoints(wallindex + 6, direction,steps)
		self:translateWallpoints(wallindex + 7, direction,steps)
		self:translateWallpoints(wallindex + 8, direction,steps)
		self:translateWallpoints(wallindex + 9, direction,steps)
		self:translateWallpoints(wallindex + 10, direction,steps)
		self:translateWallpoints(wallindex + 11, direction,steps)
		
		self:translateWallpoints(wallindex + 12, direction,steps)
		self:translateWallpoints(wallindex + 13, direction,steps)
		self:translateWallpoints(wallindex + 14, direction,steps)
		self:translateWallpoints(wallindex + 15, direction,steps)
		self:translateWallpoints(wallindex + 16, direction,steps)
		self:translateWallpoints(wallindex + 17, direction,steps)
		
		self.walls[wallindex + 2].y1 = self.walls[wallindex + 3].y0  --connect extended walls
		self.walls[wallindex + 18].y0 = self.walls[wallindex + 17].y1 --connect extended walls
		
		self.startingy = self.startingy - steps
		
		if (first == false) then
			self.walls[wallindex + 22].drawable = 0
			self.walls[wallindex + 22].nextsector = sectortoconnect
			
			self.walls[self.sectorwalls * sectortoconnect + 10].drawable = 0 --also put a portal in the previous sector wall
			self.walls[self.sectorwalls * sectortoconnect + 10].nextsector = sectorindex --also put a portal in the previous sector wall
		
		end
	else
		self:translateWallpoints(wallindex + 9, direction,steps)
		self:translateWallpoints(wallindex + 10, direction,steps)
		self:translateWallpoints(wallindex + 11, direction,steps)
		self:translateWallpoints(wallindex + 12, direction,steps)
		self:translateWallpoints(wallindex + 13, direction,steps)
		self:translateWallpoints(wallindex + 14, direction,steps)
		self:translateWallpoints(wallindex + 15, direction,steps)
		self:translateWallpoints(wallindex + 16, direction,steps)
		self:translateWallpoints(wallindex + 17, direction,steps)
		
		self:translateWallpoints(wallindex + 18, direction,steps)
		self:translateWallpoints(wallindex + 19, direction,steps)
		self:translateWallpoints(wallindex + 20, direction,steps)
		self:translateWallpoints(wallindex + 21, direction,steps)
		self:translateWallpoints(wallindex + 22, direction,steps)
		self:translateWallpoints(wallindex + 23, direction,steps)
		
		self.walls[wallindex + 8].x1 = self.walls[wallindex + 9].x0  --connect extended walls
		self.walls[wallindex + 0].x0 = self.walls[wallindex + 23].x1 --connect extended walls
		
		self.startingx = self.startingx - steps
		
		if (first == false) then
			self.walls[wallindex + 4].drawable = 0
			self.walls[wallindex + 4].nextsector = sectortoconnect
			
			self.walls[self.sectorwalls * sectortoconnect + 16].drawable = 0 --also put a portal in the previous sector wall
			self.walls[self.sectorwalls * sectortoconnect + 16].nextsector = sectorindex --also put a portal in the previous sector wall
		
		end
	end
end

function Level:clearWallStrips()
	self.wallStripsW:clear()
	self.wallStripsF:clear()
	self.wallStripsC:clear()
end

function Level:addWallStrip(renderdata, x, y, r, s, h, attenuation, type)
	if (type == 0) then
		--self.wallStrips:setColor(1.0, 1.0, 1.0, 1.0 - attenuation*2) --add kind of fog
		self.wallStripsW:add(renderdata[2], x, y, r, s, h, 0, 0, 0, 0)	
	elseif (type == 1) then
		--self.wallStrips:setColor(1.0, 1.0, 1.0, 1.0 - attenuation*2) --add kind of fog
		self.wallStripsF:add(renderdata[2], x, y, r, s, h, 0, 0, 0, 0)	
	else
		--self.wallStrips:setColor(1.0, 1.0, 1.0, 1.0 - attenuation*2) --add kind of fog
		self.wallStripsC:add(renderdata[2], x, y, r, s, h, 0, 0, 0, 0)	
	end
end

function Level:getWallStrips()
	return self.wallStripsW
end

function Level:getWallStripsFloor()
	return self.wallStripsF
end

function Level:getWallStripsCeiling()
	return self.wallStripsC
end

function Level:flushWallStrips()
	return self.wallStripsW:flush()
end

--[[
	This function extrudes a wall in a direction based on how many steps we want to grow
]]
function Level:translateWallpoints(index, direction,steps)
	if direction == 0 then
		self.walls[index].y0 = self.walls[index].y0 + (self.sectorsize + 2*self.sectorsize/6)*steps
		self.walls[index].y1 = self.walls[index].y1 + (self.sectorsize + 2*self.sectorsize/6)*steps
	elseif direction == 1 then
		self.walls[index].x0 = self.walls[index].x0 + (self.sectorsize + 2*self.sectorsize/6)*steps
		self.walls[index].x1 = self.walls[index].x1 + (self.sectorsize + 2*self.sectorsize/6)*steps
	elseif direction == 2 then
		self.walls[index].y0 = self.walls[index].y0 - (self.sectorsize + 2*self.sectorsize/6)*steps
		self.walls[index].y1 = self.walls[index].y1 - (self.sectorsize + 2*self.sectorsize/6)*steps
	else
		self.walls[index].x0 = self.walls[index].x0 - (self.sectorsize + 2*self.sectorsize/6)*steps
		self.walls[index].x1 = self.walls[index].x1 - (self.sectorsize + 2*self.sectorsize/6)*steps
	end
end

function Level:wallColor(index, hitpointw, hitpointy, wallheight)
	local x1 = self.walls[index]['x1'] - self.walls[index]['x0']
	local y1 = self.walls[index]['y1'] - self.walls[index]['y0']

	local walllenght = math.sqrt(x1*x1 + y1*y1)
	
	local wallcoordx = (hitpointw * walllenght) % 1
	
	local width, height = self.textures[self.walls[index]['textureid']]:getDimensions()
	
	local finalxcoord = wallcoordx * width
	
	local finalwheight = hitpointy / wallheight
	local finalycoord = finalwheight * height 
	
	if (finalycoord >= height) then
		finalycoord = height - 1
	end
	
	local r, g, b = self.texturesData[self.walls[index]['textureid']]:getPixel(finalxcoord, finalycoord)
	
	return {r, g, b}
end

function Level:floorHeight(index)
	--local width, height = self.textures[self.sectors[index]['textureidfloor']]:getDimensions()
	
	--return height
	return 48 --HARDCODED AGAIN BAD THING
end

function Level:getSectorZ(index)
	return self.sectors[index]['floorz']
end

function Level:isSloped(index)
	if (self.sectors[index]['sloped'] == 1) then
		return true
	end
	return false
end

function Level:getSlopedBasewall(index)
	return (self.sectors[index]['startWall'] + 1) --select the wall at the back to be the axis
end

function Level:getSectorSlope(index, px, py)
	if (self.sectors[index]['sloped'] == 1) then	
		--calc axis
		local planeindex = self.sectors[index]['slopedindex']
		local slopeangle = self.sectors[index]['slopedangle']
		local x1 = self.walls[planeindex]['x1'] - self.walls[planeindex]['x0']
		local y1 = self.walls[planeindex]['y1'] - self.walls[planeindex]['y0']
		local z1 = 0

		x1 = x1 / math.sqrt(x1 * x1 + y1*y1)
		y1 = y1 / math.sqrt(x1 * x1 + y1*y1)


		local normalx = 0
		local normaly = 0
		local normalz = 1

		--matrix rotation by an axis
		normalx =  - y1 * math.sin(slopeangle)
		normaly =  x1 * math.sin(slopeangle)
		normalz = math.cos(slopeangle)

		local rayx = 0
		local rayy = 0
		local rayz = - 1
		local denom = rayx * normalx + rayy * normaly + rayz * normalz
		
		local currentFloorX = 0.5
		local currentFloorY = 0.5
		
		
		if (math.abs(denom) > 0.0001) then -- too tiny
			local planecenterx = self.walls[planeindex]['x0'] 
			local planecentery = self.walls[planeindex]['y0']
			local planecenterz = 0
			--center of plane minus ray origin (in this case players view)
			planecenterx = planecenterx - px
			planecentery = planecentery - py
			--planecenterz = planecenterz - 1 --player height
			
			--local t = (center - ray.origin).dot(normal) / denom
			local t = (normalx * planecenterx + normaly * planecentery + normalz * planecenterz) / denom
			--if (t < 0.0001) then return--
			--end
		
			currentFloorX = px + t * rayx
			currentFloorY = py + t * rayy
			
			return (-t * rayz)
		end
		
		
	else
		return 0
	end
end


function Level:sectorColor(index, px, py, hx, hy, horizonh, hord, bottomWall)
	local finalxcoord = 10
	local finalycoord = 10
	
	--local width, height = self.texturesData[self.sectors[index]['textureidfloor']]:getDimensions()
	local width, height = 48, 48 --hard coded width and height dimensions BAD THING

	local currentDist = horizonh / (2.0 * hord - horizonh)--this function will get the distance acording to the y position, keeping in mind the middle range between inf and 1, negative values in the top middle size
	local farDist = bottomWall

	local weight = currentDist / farDist

    local currentFloorX = weight * hx + (1.0 - weight) * px
    local currentFloorY = weight * hy + (1.0 - weight) * py	
	finalxcoord = (currentFloorX * 4 % 1) * width
	finalycoord = (currentFloorY * 4 % 1) * height
	
	if (finalxcoord >= width) then
		finalxcoord = width - 1
	end
	
	if (finalxcoord <= 0) then
		finalxcoord = 0
	end
	
	if (finalycoord >= height) then
		finalycoord = height - 1
	end
	
	if (finalycoord <= 0) then
		finalycoord = 0
	end

	finalxcoord = math.floor(finalxcoord)
	finalycoord = math.floor(finalycoord)
	--local r = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4]
	--local g = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4 + 1]
	--local b = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4 + 2]

	local r, g, b = self.texturesData[self.sectors[index]['textureidfloor']]:getPixel(finalxcoord, finalycoord)
	return {r, g, b}
end

function Level:sectorColorWithSlope(index, px, py, horizonh, hord, rayx, rayy, slopedist)
	local finalxcoord = 10
	local finalycoord = 10
	
	--local width, height = self.texturesData[self.sectors[index]['textureidfloor']]:getDimensions()
	local width, height = 48, 48 --hard coded width and height dimensions BAD THING
	
	--calc axis
	local planeindex = self.sectors[index]['slopedindex']
	local slopeangle = self.sectors[index]['slopedangle']
	local x1 = self.walls[planeindex]['x1'] - self.walls[planeindex]['x0']
	local y1 = self.walls[planeindex]['y1'] - self.walls[planeindex]['y0']
	local z1 = 0

	x1 = x1 / math.sqrt(x1 * x1 + y1*y1)
	y1 = y1 / math.sqrt(x1 * x1 + y1*y1)


	local normalx = 0
	local normaly = 0
	local normalz = 1

	--matrix rotation by an axis
	normalx =  - y1 * math.sin(slopeangle)
	normaly =  x1 * math.sin(slopeangle)
	normalz = math.cos(slopeangle)


	local rayz = - (2.0 * hord - horizonh)
	local denom = rayx * normalx + rayy * normaly + rayz * normalz
	
	local currentFloorX = 0.5
	local currentFloorY = 0.5
	
	
	if (math.abs(denom) > 0.0001) then -- too tiny
		local planecenterx = self.walls[planeindex]['x0'] 
		local planecentery = self.walls[planeindex]['y0']
		local planecenterz = -118 + slopedist
		--center of plane minus ray origin (in this case players view)
		planecenterx = planecenterx - px
		planecentery = planecentery - py
		planecenterz = planecenterz - 1 --player height
		
		--local t = (center - ray.origin).dot(normal) / denom
		local t = (normalx * planecenterx + normaly * planecentery + normalz * planecenterz) / denom
		--if (t < 0.0001) then return--
		--end
	
		currentFloorX = px + t * rayx
		currentFloorY = py + t * rayy
	end
	
	finalxcoord = (currentFloorX * 4 % 1) * width
	finalycoord = (currentFloorY * 4 % 1) * height
	
	if (finalxcoord >= width) then
		finalxcoord = width - 1
	end
	
	if (finalxcoord <= 0) then
		finalxcoord = 0
	end
	
	if (finalycoord >= height) then
		finalycoord = height - 1
	end
	
	if (finalycoord <= 0) then
		finalycoord = 0
	end
	
	finalxcoord = math.floor(finalxcoord)
	finalycoord = math.floor(finalycoord)
	--local r = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4]
	--local g = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4 + 1]
	--local b = self.texturesDataPointers[self.sectors[index]['textureidfloor']][finalycoord*width*4 + finalxcoord*4 + 2]
	
	local r, g, b = self.texturesData[self.sectors[index]['textureidfloor']]:getPixel(finalxcoord, finalycoord)
	
	return {r, g, b}
end


function Level:sectorFloor(index, height)
	local vertices = {
		{
			-- top-left corner (red-tinted)
			0, 0, -- position of the vertex
			0, 0, -- texture coordinate at the vertex position
			0, 0.8, 1.2, 1.0 -- color of the vertex
		},
		{
			-- top-right corner (green-tinted)
			1, 0,
			1, 0, -- texture coordinates are in the range of [0, 1]
			0, 0.8, 0.2,  1.0
		},
		{
			-- bottom-right corner (blue-tinted)
			1, height,
			1, 1,
			0, 0.8, 0.2,  1.0
		},
		{
			-- bottom-left corner (yellow-tinted)
			0, height,
			0, 1,
			0, 0.8, 0.2, 1.0
		},
	}
 
	-- the Mesh DrawMode "fan" works well for 4-vertex Meshes.
	mesh = love.graphics.newMesh(vertices, "fan")
	
	return mesh
end

function Level:wallColumn(index, hitpointw, hitpointy, wallheight, attenuation, wallratio, type)
	local x1 = self.walls[index]['x1'] - self.walls[index]['x0']
	local y1 = self.walls[index]['y1'] - self.walls[index]['y0']

	local walllenght = math.sqrt(x1*x1 + y1*y1)
	
	local wallcoordx = (hitpointw * walllenght) % 1
	
	--local width, height = self.textures[self.walls[index]['textureid']]:getDimensions()
	local width, height = 48, 48
	
	local finalxcoord = wallcoordx * width
	
	local finalwheight = hitpointy / wallheight
	local finalycoord = finalwheight * height 
	
	if (finalycoord >= height) then
		finalycoord = height - 1
	end
	
	--local column = love.graphics.newQuad(finalxcoord, 0, 1, height, self.textures[self.walls[index]['textureid']]:getDimensions())
	local column = self.texturesStrip[math.floor(finalxcoord)]
	 
	
	local shadowheight = wallheight / wallratio * height
	local vertices = {
		{
			-- top-left corner (red-tinted)
			0, 0, -- position of the vertex
			0, 0, -- texture coordinate at the vertex position
			0.2, 0.2, 0.2, attenuation -- color of the vertex
		},
		{
			-- top-right corner (green-tinted)
			1, 0,
			1, 0, -- texture coordinates are in the range of [0, 1]
			0.2, 0.2, 0.2,  attenuation
		},
		{
			-- bottom-right corner (blue-tinted)
			1, shadowheight,
			1, 1,
			0.2, 0.2, 0.2,  attenuation
		},
		{
			-- bottom-left corner (yellow-tinted)
			0, shadowheight,
			0, 1,
			0.2, 0.2, 0.2, attenuation
		},
	}
 
	-- the Mesh DrawMode "fan" works well for 4-vertex Meshes.
	mesh = love.graphics.newMesh(vertices, "fan")
    --mesh:setTexture(image)
	
	if type == 0 then
		return {self.textures[self.walls[index]['textureid']], column, height, mesh}
	elseif type == 1 then
		return {self.textures[self.walls[index]['floorstepid']], column, height, mesh}
	else
		return {self.textures[self.walls[index]['ceilingstepid']], column, height, mesh}
	end
	--local r, g, b = self.texturesData[self.walls[index]['textureid']]:getPixel(finalxcoord, finalycoord)
	
	--return {r, g, b}
end

function Level:update(dt)
	for x in pairs(self.enemies) do
		self.enemies[x]:update(dt, self.enemies)
	end
end

function Level:drawSprites(player_x, player_y, dir_x, dir_y, cam_x_plane, cam_y_plane, width, height, zbuffer, horiz, bottomview)
	--generate a copy of the enemies list to sort
	local enemylist = {}
	
	--calculate distance
	for x in pairs(self.enemies) do
		self.enemies[x]:calcDistanceTo(player_x, player_y)
		enemylist[x] = self.enemies[x]
	end
	
	--sorting sprites
	--keep in mind that sort works with tables starting with index == 1
	table.sort(enemylist, function(a,b) return a.currentDistance > b.currentDistance end)
	
	--draw the sprites
	for x in pairs(self.enemies) do
		enemylist[x]:render(player_x, player_y, dir_x, dir_y, cam_x_plane, cam_y_plane, width, height, zbuffer, horiz, bottomview)
	end
	
	--print a tiny map in the center of the screen 
	--only for debugging purposes
	--if self.finalmaze ~= nil then
	--	love.graphics.setColor(0, 1 , 0, 1)
	--	for n in pairs(self.finalmaze) do
	--		for j in pairs(self.finalmaze[n]) do
	--			love.graphics.points( (n * 2) + width / 2, (j * 2) + height / 2)
	--		end
	--	end
	--end
end