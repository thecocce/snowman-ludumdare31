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

  init = function(self, x, y)
    GameObject.init(self, x, y, 5)
    self.t = math.random()
    self.torchFuel = 1

    local facing = math.random()*math.pi*2
    self.facex, self.facey = math.cos(facing), math.sin(facing)
    self.particles = math.random()

    self.torch_x = self.facex*self.r*2
    self.torch_y = self.facey*self.r*2

    self.torch_h = self:torchHeight()
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

  -- breath
  self.t = self.t + dt*0.3
  if self.t > 1 then
    self.t = self.t - 1
  end

  self.torch_h = self:torchHeight()

  -- fire particles
  if self.torchFuel > 0 then
    self.particles = self.particles + dt*5
    if self.particles > 1 then

      local x, y = self.x + self.torch_x, self.y + self.torch_y

      if math.random() > 0.8 then
        local angle = math.random()*math.pi*2
        local speed = 6 + math.random()*4
        local dx, dy = math.cos(angle), math.sin(angle)
        Particle.Smoke(x, y, 
          dx*speed, 
          dy*speed, 
          20 + math.random()*8,
          0.35).z = self.torch_h
      else
        local angle = math.random()*math.pi*2
        local speed = 6 + math.random()*4
        local dx, dy = math.cos(angle), math.sin(angle)
        Particle.Fire(x, y, 
          dx*speed, 
          dy*speed, 
          20 + math.random()*8,
          0.35).z = self.torch_h
      end

      self.particles = self.particles - 1
    end
  end

  GameObject.update(self, dt)
end

function Human:torchHeight()
  return 28 - 2*math.cos(4*self.t*math.pi)
end

function Human:draw(x, y)


  -- torch behind ?
  if (self.torchFuel > 0) and self.torch_y < 0 then
    useful.bindBlack()
      love.graphics.rectangle("fill", 
        x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 12)
    love.graphics.setColor(255, 100, 55, 255*self.torchFuel)
      love.graphics.rectangle("fill", 
        x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 2)
    useful.bindWhite()
  end


  -- body
  love.graphics.setColor(122, 178, 128)
    love.graphics.rectangle("fill", self.x - 5, self.y - 24, 10, 24)
  useful.bindWhite()

  -- torch in front
  if (self.torchFuel > 0) and self.torch_y > 0 then
    useful.bindBlack()
      love.graphics.rectangle("fill", 
        x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 12)
    love.graphics.setColor(255, 100, 55, 255*self.torchFuel)
      love.graphics.rectangle("fill", 
        x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 2)
    useful.bindWhite()
  end

  -- torch light
  light(x, y, 64, 3)

  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 12, 12*VIEW_OBLIQUE)
  useful.popCanvas()
end

function Human:antiShadow()

  if (self.torchFuel > 0) then
    local x, y = self.x + self.torch_x, self.y + self.torch_y
    useful.pushCanvas(SHADOW_CANVAS)
      love.graphics.setBlendMode("subtractive")
        useful.oval("fill", x, y, 6, 6*VIEW_OBLIQUE)
      love.graphics.setBlendMode("alpha")
    useful.popCanvas()
  end
end

--[[------------------------------------------------------------
Combat
--]]--

function Human:throw(x, y)
  local thrown = Torch(self.x, self.y, x, y)
  self.torchFuel = 0
end

function Human:canThrow(x, y)
  return (self.torchFuel > 0)
end

--[[------------------------------------------------------------
Collisions
--]]--

function Human:eventCollision(other, dt)
  if other:isType("Human") then
    other:shoveAwayFrom(self, 100*dt)
  elseif other:isType("Bonfire") then
    self:shoveAwayFrom(other, 500*dt)
  elseif other:isType("Fire") then
    if self.torchFuel == 0 then
      self.torchFuel = 1
      other.purge = true
    end
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Human