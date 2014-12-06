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
	Monster(WORLD_W*0.6, WORLD_H*0.6)
	picked_human = nil
	t = 0
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
	elseif pick_dist2 < MAX_THROW_DIST2 then
		pick:throw(x, y)
	elseif not pick then
		Human(x, y)
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

	-- spawn monsters
	t = t + dt
	if t > 10 then
		local angle = math.random()*math.pi*2

		Monster((math.cos(angle) + 0.5)*WORLD_W, (math.sin(angle) + 0.5)*WORLD_H)
		t = 0
	end

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()
	WORLD_CANVAS:clear()

	useful.pushCanvas(DARKNESS_CANVAS)
		useful.bindBlack(32)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()


	love.graphics.setColor(200, 200, 255)
	love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	GameObject.drawAll()
	

	love.graphics.draw(DARKNESS_CANVAS)

	GameObject.mapToAll(function(o) if o.draw_afterdark then o:draw_afterdark(o.x, o.y) end end)

	love.graphics.print("in game", 0, 0)

end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state