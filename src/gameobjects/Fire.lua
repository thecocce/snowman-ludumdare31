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

local Fire = Class
{
  type = GameObject.newType("Fire"),

  init = function(self, x, y, starting_fuel)
    GameObject.init(self, x, y)
    self.fuel = starting_fuel
  end,
}
Fire:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Fire:onPurge()
end


--[[------------------------------------------------------------
Game loop
--]]--

function Fire:update(dt)
  -- exponential decline
  self.fuel = self.fuel - 0.1*self.fuel*dt

  -- die
  if self.fuel <= 0.1 then
    self.purge = true
  end
end

function Fire:draw(x, y)
  light(x, y, 0, self.fuel)
  love.graphics.rectangle("fill", self.x - 4, self.y - 4, 8, 8)
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Fire