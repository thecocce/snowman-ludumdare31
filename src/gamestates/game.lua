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
Gamestate navigation
--]]--

function state:init()


end


function state:enter()

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

	
end

function state:mousereleased()
	
end

function state:update(dt)
	
end

function state:draw()
	WORLD_CANVAS:clear()
	
	love.graphics.print("in game", 0, 0)

end


--[[------------------------------------------------------------
EXPORT
--]]------------------------------------------------------------

return state