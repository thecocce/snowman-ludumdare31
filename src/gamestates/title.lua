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
local fire = nil
local leaving = nil
local desires_leave = false
local desires_exit = false
local finished_in = false

--[[------------------------------------------------------------
Gamestate navigation
--]]--

function state:init()
end

function state:enter()
	leaving = nil
	t = 0
	desires_leave = false
	finished_in = false
	desires_leave = false
	SHADOW_CANVAS:clear()
	fire = Bonfire(WORLD_W*0.5, WORLD_H*0.5)
end

function state:leave()
	SHADOW_CANVAS:clear()
	fire = nil
end

--[[------------------------------------------------------------
Callbacks
--]]--

function state:keypressed(key, uni)
  if key=="escape" then
  	desires_exit = true
  	desires_leave = true
  end
end

function state:mousepressed(x, y, button)
  desires_leave = true
end

function state:update(dt)
	t = t + dt

	if desires_exit and finished_in then
		fire.heat = useful.lerp(fire.heat, 0, (leaving or 0))
	else
		fire.heat = useful.lerp(fire.heat, 1, dt)
	end

	if (fire.heat >= 0.5) and desires_leave and (not leaving) then
		leaving = 0
		finished_in = true
	elseif leaving then 
		leaving = math.min(1, leaving + dt)

		-- fade out sounds
		if desires_exit then
			sound_wind:setVolume((1 - leaving)*wind_base_base)
		end

		if leaving >= 1 then
			if desires_exit then
				love.event.push("quit")
			else
				gamestate.switch(game)
			end
		end
	end

	-- update all object
	GameObject.updateAll(dt, { oblique = VIEW_OBLIQUE })
end

function state:draw()
	WORLD_CANVAS:clear()

	-- it's always morning in the menu
	update_light(0.0)

	-- snow
	love.graphics.setColor(200, 200, 255)
		love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
	useful.bindWhite()

	-- shadows
	GameObject.mapToAll(function(o) if o.antiShadow then o:antiShadow() end end)
	useful.bindBlack(128)
		love.graphics.draw(SHADOW_CANVAS)
	useful.bindWhite()
	SHADOW_CANVAS:clear()

	-- lightness at center
	GameObject.drawAll()

	-- apply light overlays
	bake_light()

	-- mouse
	if not desires_exit then
		useful.pushCanvas(UI_CANVAS)
			love.graphics.setColor(200, 200, 255)
				local mx, my = love.mouse.getPosition()
				love.graphics.polygon("fill", mx - 4, my, mx, my - 4, mx + 4, my, mx, my + 4)
				love.graphics.setBlendMode("subtractive")
					love.graphics.polygon("fill", mx - 2, my, mx, my - 2, mx + 2, my, mx, my + 2)
				love.graphics.setBlendMode("alpha")
			useful.bindWhite()
		useful.popCanvas()
	end
	
	love.graphics.setColor(200, 200, 255)
		local offset = 0--4*math.sin(2*t)
		love.graphics.setFont(FONT_BIG)
		local y
		local amount = leaving and (1 - leaving) or math.min(1, 2*fire.heat)

		-- title
		y = useful.lerp(-0.3*WORLD_H, WORLD_H*0.03 + offset, amount)
		love.graphics.printf("Twilight of Humanity", 
			WORLD_W*(0.5 - 0.3), y, WORLD_W*0.6, "center") 

		-- credits
		y = useful.lerp(WORLD_H, WORLD_H*0.78 + offset, amount)
		love.graphics.setFont(FONT_MEDIUM)
		love.graphics.printf("@wilbefast\n#LDJam #LudumDare31", 
			WORLD_W*(0.5 - 0.4), y, WORLD_W*0.8, "center") 

		love.graphics.setFont(FONT_SMALL)
	useful.bindWhite()
end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state