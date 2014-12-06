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

--[[------------------------------------------------------------
Initialisation
--]]--

local Bonfire = Class
{
  type = GameObject.newType("Bonfire"),

  init = function(self, x, y, starting_fuel)
    GameObject.init(self, x, y)
    self.fuel = starting_fuel
  end,
}
Bonfire:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Bonfire:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function Bonfire:update(dt)
end

function Bonfire:draw(x, y)
  light(x, y, 0, 8)
end

function Bonfire:draw_afterdark(x, y)
  love.graphics.rectangle("fill", self.x - 8, self.y - 8, 16, 16)
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Bonfire