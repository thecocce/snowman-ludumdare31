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
CONSTANTS
--]]--

local SPEED = 128

--[[------------------------------------------------------------
Initialisation
--]]--

local Monster = Class
{
  FRICTION = 100,

  type = GameObject.newType("Monster"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 5)
    self.t = math.random()
  end,
}
Monster:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Monster:onPurge()
end

--[[------------------------------------------------------------
States
--]]--

function Monster:setState(newStateClass, ...)
  
  if self.state.class == newStateClass then
    return
  end
  local newState = newState(self, ...)
  newState.class = newStateClass

  local oldState = self.state
  if oldState.exitTo then
    oldState.exitTo(newState)
  end
  if newState.enterFrom then
    newState.enterFrom(oldState)
  end
  self.state = newState
end


--[[------------------------------------------------------------
Game loop
--]]--

function Monster:update(dt)
  --local dx, dy = Vector.normalize(WORLD_W*0.5 - self.x, WORLD_H*0.5 - self.y)

  --self.dx, self.dy = dx*SPEED, dy*SPEED

  GameObject.update(self, dt)
end

function Monster:draw(x, y)
  love.graphics.setColor(122, 152, 178)
    love.graphics.rectangle("fill", self.x - 8, self.y - 32, 16, 32)
  useful.bindWhite()
end

--[[------------------------------------------------------------
Collisions
--]]--

function Monster:eventCollision(other, dt)
  if other:isType("Monster") then
    other:shoveAwayFrom(self, 100*dt)
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Monster