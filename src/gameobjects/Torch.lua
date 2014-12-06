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

local Torch = Class
{
  type = GameObject.newType("Torch"),

  init = function(self, x, y, tx, ty)
    GameObject.init(self, x, y)
    self.start_x, self.start_y = x, y
    self.target_x, self.target_y = tx, ty
    self.t = 0
    self.z = 0
    self.dist = Vector.dist(x, y, tx, ty)
    self.dx, self.dy = (tx - x)/self.dist, (ty - y)/self.dist
    self.prev_x, self.prev_y = x, y
  end,
}
Torch:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Torch:onPurge()
  Fire(self.x, self.y, 2)
end


--[[------------------------------------------------------------
Game loop
--]]--

function Torch:update(dt)
  -- progress and position
  local prev_t = self.t
  self.t = self.t + math.min(3*dt, 300*dt/self.dist)
  self.x = useful.lerp(self.start_x, self.target_x, self.t)
  self.y = useful.lerp(self.start_y, self.target_y, self.t)

  -- height
  local life = 1-self.t
  local parabola = -(2*life-1)*(2*life-1) + 1
  self.z = parabola*256*self.dist/WORLD_W

  -- die
  if life <= 0 then
    self.purge = true
  end
end

function Torch:draw(x, y)
  light(x, y, self.z, 2)
  light(x, y - self.z, 0, 1)
  useful.bindBlack()
    love.graphics.rectangle("fill", self.x - 4, self.y - 4 - self.z, 8, 8)
  useful.bindWhite()
end

--[[------------------------------------------------------------
Collisions
--]]--


--[[------------------------------------------------------------
Export
--]]--

return Torch