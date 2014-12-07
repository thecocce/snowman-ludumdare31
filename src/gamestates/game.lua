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

local MAX_PICK_DIST2 = 24*24
local MAX_THROW_DIST2 = 1024*1024--256*256

--[[------------------------------------------------------------
Internal state
--]]--

local picked_human = nil
local t = 0
local wave = 1

day_night = 0

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end


function state:enter()
	-- reset darkness canvas
	useful.pushCanvas(DARKNESS_CANVAS)
		useful.bindBlack()
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	-- reset
	picked_human = nil
	day_night = 0.3
	wave = 1



	Monster(0, 0)


	-- repopulate world
	Bonfire(WORLD_W*0.5, WORLD_H*0.5)
	for i = 1, 10 do
		local angle = math.random()*math.pi*2
		local distance = 64*(1 + math.random())
		Human(math.cos(angle)*distance + WORLD_W*0.5, math.sin(angle)*distance + WORLD_H*0.5)
	end
end


function state:leave()
	GameObject.purgeAll()
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
	day_night = day_night + dt/60
	if day_night > 1 then
		-- night falls
		day_night = day_night - 2
		-- spawn monsters
		for i = 1, wave do
			local angle = math.pi*2*math.random()
			Monster(
				math.cos(angle)*WORLD_W*(1 + math.random()*3), 
				math.sin(angle)*WORLD_H*(1 + math.random()*3))
		end
		wave = wave + 1
	end

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()

	WORLD_CANVAS:clear()



	local lightness = math.max(0, 4*(1 - day_night)*day_night)
	local r, g, b = useful.ktemp(useful.lerp(16000, 2000, day_night))
	useful.pushCanvas(COLOUR_CANVAS)
		love.graphics.setColor(r*lightness, g*lightness, b*lightness, 32)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()

	useful.pushCanvas(ALPHA_CANVAS)
		useful.bindWhite(lightness*255)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindBlack((1 - lightness)*255)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()


	-- the floor (snow)
	love.graphics.setColor(200, 200, 255)
		love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	-- shadows
	GameObject.mapToAll(function(o) if o.antiShadow then o:antiShadow() end end)
	useful.bindBlack(128)
		love.graphics.draw(SHADOW_CANVAS)
	useful.bindWhite()
	SHADOW_CANVAS:clear()

	-- game objects
	GameObject.drawAll()


	useful.pushCanvas(LIGHT_CANVAS)
		love.graphics.draw(COLOUR_CANVAS)
		love.graphics.setBlendMode("multiplicative")
			love.graphics.draw(ALPHA_CANVAS)
		love.graphics.setBlendMode("alpha")
	useful.popCanvas(LIGHT_CANVAS)

	love.graphics.setBlendMode("multiplicative")
		love.graphics.draw(LIGHT_CANVAS)
	love.graphics.setBlendMode("alpha")


end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state