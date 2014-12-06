--[[
(C) Copyright 2014 William Dyce

All rights reserved. This program and the accompanying materials
are made available under the terms of the GNU Lesser General Public License
(LGPL) version 2.1 which accompanies this distribution, and is available at
http://www.gnu.org/licenses/lgpl-2.1.html

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
--]]

local state = gamestate.new()

--[[------------------------------------------------------------
Defines
--]]--

local MAX_PICK_DIST2 = 16*16
local MAX_THROW_DIST2 = 1024*1024--256*256

--[[------------------------------------------------------------
Internal state
--]]--

local picked_human = nil
local t = 0

local day_night = 0

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
	Bonfire(WORLD_W*0.5, WORLD_H*0.5)
end


function state:enter()
	-- reset darkness canvas
	useful.pushCanvas(DARKNESS_CANVAS)
		useful.bindBlack()
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	-- reset state
	Monster(WORLD_W*0.2, WORLD_H*0.6)
	picked_human = nil
	t = 0
	day_night = 0
	for i = 1, 10 do
		local angle = math.random()*math.pi*2
		local distance = 64*(1 + math.random())
		Human(math.cos(angle)*distance + WORLD_W*0.5, math.sin(angle)*distance + WORLD_H*0.5)
	end
end


function state:leave()
	GameObject.purgeAll()
	DARKNESS_CANVAS:clear()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key == "escape" then
    gamestate.switch(title)
  end
end

function state:mousepressed(x, y)

	local pick, pick_dist2 = GameObject.getNearestOfType("Human", x, y)
	if pick_dist2 < MAX_PICK_DIST2 then
		picked_human = pick
	else
		local thrower = GameObject.getNearestOfType("Human", x, y, 
			function(human) return human:canThrow(x, y) 
		end)
		if thrower then
			thrower:throw(x, y)
		end
	end
end

function state:mousereleased()
	picked_human = nil
end	

function state:update(dt)

	local mx, my = love.mouse.getPosition()

	-- drag humans around
	if picked_human then
		picked_human.x, picked_human.y = mx, my
	end

	-- calculate time of day
	day_night = day_night + dt/4
	if day_night > 1 then
		day_night = day_night - 2
	end

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()

	WORLD_CANVAS:clear()
	local r, g, b = useful.ktemp(useful.lerp(16000, 2000, day_night))
	local light = 0.8*math.max(0, 4*(1 - day_night)*day_night)
	useful.pushCanvas(DARKNESS_CANVAS)
		love.graphics.setColor(r*light, g*light, b*light, 32)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	useful.pushCanvas(LIGHT_CANVAS)
		useful.bindBlack()
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()


	love.graphics.setColor(200, 200, 255)
		love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	GameObject.drawAll()

	love.graphics.draw(DARKNESS_CANVAS)
	love.graphics.setBlendMode("screen")
		love.graphics.draw(LIGHT_CANVAS)
	love.graphics.setBlendMode("alpha")

	love.graphics.print(tostring(math.floor(day_night*10)/10), 0, 0)


end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state