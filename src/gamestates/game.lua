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


--[[------------------------------------------------------------
Internal state
--]]--

local picked_human = nil


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

	-- reset state
	picked_human = nil
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

	if pick_dist2 > 16*16 then
		Human(x, y)
	else
		picked_human = pick
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

	GameObject.updateAll(dt)
end

function state:draw()
	WORLD_CANVAS:clear()

	useful.pushCanvas(DARKNESS_CANVAS)
		useful.bindBlack(32)
			love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
		useful.bindWhite()
	useful.popCanvas()


	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	GameObject.drawAll()
	

	love.graphics.draw(DARKNESS_CANVAS)

	love.graphics.print("in game", 0, 0)



end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state