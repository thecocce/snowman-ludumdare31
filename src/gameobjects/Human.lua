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

    self.torch = true
    self.torchFuel = 1
    self.torchHeat = 1

    self.particles = math.random()

    self:randomFacing()

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
Torch
--]]--

function Human:torchHeight()
  return 12*self.torchFuel + 16 - 2*math.cos(4*self.t*math.pi)
end

function Human:drawTorch()
  local x, y = self.x, self.y
  local len = 12*self.torchFuel
  useful.bindBlack()
    love.graphics.rectangle("fill", 
      x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, len)
  love.graphics.setColor(255, 100, 55, 255*self.torchHeat)
    love.graphics.rectangle("fill", 
      x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 2)
  useful.bindWhite()
end


--[[------------------------------------------------------------
Facing
--]]--

function Human:setFacing(x, y)
  if (x ~= 0) or (y ~= 0) then
    self.facex, self.facey = x, y
    self.torch_x = self.facex*self.r*2
    self.torch_y = self.facey*self.r*2
  end
end

function Human:randomFacing()
  local facing = math.random()*math.pi*2
  self:setFacing(math.cos(facing), math.sin(facing))
end

function Human:turnTowards(x, y, speed)
  if (x ~= 0) or (y ~= 0) then
    local turn_dir = Vector.det(self.facex, self.facey, x, y)
    local fx, fy = self.facex, self.facey
    local a

    if turn_dir < -0.5 then
      a = -speed
    elseif turn_dir > 0.5 then
      a = speed
    else 
      a = 0
    end

    if a ~= 0 then
      x2 = fx*math.cos(a) - fy*math.sin(a)
      y2 = fx*math.sin(a) + fy*math.cos(a)

      self:setFacing(x2, y2)
    end
  end
end

--[[------------------------------------------------------------
Game loop
--]]--

function Human:update(dt)

  -- exponential decline of torch heat
  if self:isNear(the_bonfire) then
    self.torchHeat = math.min(1, self.torchHeat + dt)
  else
    self.torchHeat = self.torchHeat - 0.01*self.torchHeat*dt
  end

  -- linear decline of torch fuel
  if self.torchHeat > 0.2 then
    self.torchFuel = self.torchFuel - 0.001*self.torchHeat*dt
  else
    self.torchHeat = 0
  end

  -- breath
  self.t = self.t + dt*0.3
  if self.t > 1 then
    self.t = self.t - 1
    if (math.random() > 0.7) and (self ~= picked_human) then
      self:randomFacing()
    end
  end

  self.torch_h = self:torchHeight()

  -- fire particles
  if self.torch and self.torchHeat > 0 then
    self.particles = self.particles + dt*10
    if self.particles > 1 then

      local x, y = self.x + self.torch_x, self.y + self.torch_y

      if math.random()*1.2 > self.torchHeat then
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


function Human:draw(x, y)
  local breath = math.sin(4*self.t*math.pi)

  -- torch behind ?
  if self.torch and self.torch_y < 0 then
    self:drawTorch()
  end


  -- body
  love.graphics.setColor(122, 178, 128)
    local w, h = (5 + breath)*(1 - 0.3*math.abs(self.facex)), 24 - breath 
    love.graphics.rectangle("fill", self.x - w, self.y - h, 2*w, h)
  useful.bindWhite()

  -- torch in front
  if self.torch and self.torch_y >= 0 then
    self:drawTorch()
  end

  -- torch light
  if self.torch and self.torchHeat > 0 then
    light(x + self.torch_x, y + self.torch_y, 64, self.torchHeat*3)
  end

  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 10 - 0.5*breath, (10 - 0.5*breath)*VIEW_OBLIQUE)
  useful.popCanvas()
end

function Human:antiShadow()

  if self.torch then
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
  local thrown = Torch(self.x, self.y, x, y, self.torchFuel, self.torchHeat)
  self.torch = false
end

function Human:canThrow(x, y)
  return self.torch
end

--[[------------------------------------------------------------
Collisions
--]]--

function Human:eventCollision(other, dt)
  if other:isType("Human") then
    other:shoveAwayFrom(self, 100*dt)
  elseif other:isType("Bonfire") then
    self:shoveAwayFrom(other, 500*dt)
  elseif other:isType("TorchFallen") then
    if not self.torch then
      self.torchFuel = other.fuel
      self.torchHeat = other.heat
      self.torch = true
      other.purge = true
    end
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Human