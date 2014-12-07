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

local t = nil
local entering = nil
local desires_leave = false
local finished_in = false

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	entering = 0
	desires_leave = false
	finished_in = false
end

function state:leave()
	SHADOW_CANVAS:clear()
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key=="escape" then
  	desires_leave = true
  end
end

function state:mousepressed(x, y, button)
  desires_leave = true
end

function state:update(dt)

	if not finished_in then
		entering = math.min(1, entering + 0.5*dt)
		if entering >= 1 then
			finished_in = true
		end
	elseif desires_leave then
		entering = entering - dt
		if entering <= 0 then
			gamestate.switch(title)
		end
	end
end

function state:draw()
	WORLD_CANVAS:clear()

	-- mouse
	love.graphics.setColor(200, 200, 255)
	useful.pushCanvas(UI_CANVAS)
		local mx, my = love.mouse.getPosition()
		love.graphics.polygon("fill", mx - 4, my, mx, my - 4, mx + 4, my, mx, my + 4)
		love.graphics.setBlendMode("subtractive")
			love.graphics.polygon("fill", mx - 2, my, mx, my - 2, mx + 2, my, mx, my + 2)
		love.graphics.setBlendMode("alpha")
	useful.popCanvas()
	useful.bindWhite()

	
	love.graphics.setColor(200, 200, 255)

		love.graphics.setFont(FONT_MEDIUM)
		local y

		-- title
		y = useful.lerp(-0.3*WORLD_H, WORLD_H*0.3, entering)
		love.graphics.printf("And so was the light of Mankind", 
			0, y, WORLD_W, "center") 

		-- credits
		y = useful.lerp(WORLD_H, WORLD_H*0.6, entering)
		love.graphics.setFont(FONT_BIG)
		love.graphics.printf("forever extinguished", 
			0, y, WORLD_W, "center") 

		love.graphics.setFont(FONT_SMALL)
	useful.bindWhite()
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state