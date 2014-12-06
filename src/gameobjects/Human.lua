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

local Human = Class
{
  FRICTION = 100,

  type = GameObject.newType("Human"),

  init = function(self, x, y, peepType)
    GameObject.init(self, x, y, 5)
    self.t = math.random()
  end,
}
Human:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Human:onPurge()
end

--[[------------------------------------------------------------
States
--]]--

function Human:setState(newStateClass, ...)
  
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

function Human:update(dt)
  self.t = self.t + dt*0.3
  if self.t > 1 then
    self.t = self.t - 1
  end

end

function Human:draw(x, y)
  love.graphics.rectangle("fill", self.x - 8, self.y - 32 - 128*(1 + math.cos(self.t*math.pi*2)), 16, 32)



  light(x, y, 128*(1 + math.cos(self.t*math.pi*2)), 1)


end

--[[------------------------------------------------------------
Collisions
--]]--

function Human:eventCollision(other, dt)
  if other:isType("Human") then
    other:shoveAwayFrom(self, 100*dt)
  elseif other:isType("Building") then
    self:shoveAwayFrom(other, 200*dt)
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Human