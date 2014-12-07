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

local SPEED = 64

local Human = Class
{
  FRICTION = 100,

  type = GameObject.newType("Human"),

  init = function(self, x, y, torch)
    GameObject.init(self, x, y, 5)
    self.t = math.random()

    self.torch = torch
    self.fuel = (torch and 1) or 0
    self.heat = 0
    self.light = Light(self.x, self.y)

    self.visibility = 0

    self.stress = 0
    self.hunger = math.random()*0.5 - 1
    self.bodyHeat = 1

    self.particles = math.random()

    self:randomFacing()

    self.torch_h = self:torchHeight()

    self.heart = math.random()
  end,
}
Human:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Human:onPurge()
  self.light.purge = true
end

function Human:kill()
  if self.torch then
    Torch(self.x, self.y, self.x, self.y, self.fuel, self.heat).startz = 32
  end
  self.purge = true
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
  return 12*self.fuel + 16 - 2*math.cos(4*self.t*math.pi)
end

function Human:drawTorch()
  local x, y = self.x, self.y
  local len = 12*self.fuel



  useful.bindBlack()

    if self.bonfire then
      -- draw horizontally
      love.graphics.rectangle("fill", 
        x + self.torch_x - len, y + self.torch_y*VIEW_OBLIQUE - self.torch_h*0.5, len, 2)

    else
      -- draw vertical
      love.graphics.rectangle("fill", 
        x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, len)
      love.graphics.setColor(255, 100, 55, 255*self.heat)
        love.graphics.rectangle("fill", 
          x + self.torch_x - 1, y + self.torch_y*VIEW_OBLIQUE - self.torch_h, 2, 2)
    end
  useful.bindWhite()
end

--[[------------------------------------------------------------
Control
--]]--

function Human:pick()
  self.picked = true
end

function Human:unpick()
  self.picked = false
end

--[[------------------------------------------------------------
Facing
--]]--

function Human:setDesiredFacing(dx, dy)
  if (x ~= 0) or (y ~= 0) then
    self.desired_facex, self.desired_facey = dx, dy
  end
end

function Human:setDesiredFace(x, y)
  local dx, dy = Vector.normalize(x - self.x, y - self.y)
  self:setDesiredFacing(dx, dy)
end

function Human:randomDesiredFacing()
  local facing = math.random()*math.pi*2
  self:setDesiredFacing(math.cos(facing), math.sin(facing))
end

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
    else
      a = speed
    end

    x2 = fx*math.cos(a) - fy*math.sin(a)
    y2 = fx*math.sin(a) + fy*math.cos(a)
    self:setFacing(x2, y2)
    return false
  end
end

--[[------------------------------------------------------------
Game loop
--]]--

function Human:update(dt)

  -- get hungry
  self.hunger = self.hunger + dt/120

  -- update torch
  self.light.x, self.light.y = self.x + self.torch_x, self.y + self.torch_y
  if self.torch and (self.heat > 0) then
    self.light.r = self.heat*96
  else
    self.light.r = 0
    if isLight() then
      self.visibility = math.min(1, self.visibility + dt)
    else
      self.visibility = math.max(0, self.visibility - dt)
    end
  end
  
  -- heartbeat
  self.heart = self.heart + dt
  if self.heart > 1 then
    -- find nearest light
    self.nearestLight = GameObject.getNearestToCollideOfType(
      "Light", self.x, self.y, function(l) return (l.r > 0) end)
    -- find nearest monster
    self.nearestMonster = GameObject.getNearestOfType(
      "Monster", self.x, self.y, function(m) return (m.visibility > 0) end)
    self.heart = self.heart - 1
  end

  -- go to the light
  if not self.picked 
  and not isLight()
  and self.nearestLight 
  and (not self.torch or (self.heat <= 0)) 
  then
    local nl = self.nearestLight
    local dx, dy, dist = Vector.normalize(nl.x - self.x, nl.y - self.y)
    if dist > nl.r*0.5 then
      self.dx, self.dy = dx*SPEED, dy*SPEED
      self:setDesiredFacing(dx, dy)
    else
      -- stop
      self.dx, self.dx = useful.lerp(self.dx, 0, dt), useful.lerp(self.dy, 0, dt)
    end
  end

  -- relit torch at bonfire
  local bonfire, dist2 = GameObject.getNearestOfType("Bonfire", self.x, self.y)
  if bonfire and self:isNear(bonfire) then
    self.heat = math.max(0.3, math.min(1, self.heat + dt))
    self.bonfire = bonfire
    self.desired_facex, self.desired_facey = bonfire.x - self.x, bonfire.y - self.y
  else
    self.bonfire = false
  end

  -- move to mouse if picked
  if self.picked then
    local mx, my = love.mouse.getPosition()
    local dx, dy, dist = Vector.normalize(mx - self.x, my - self.y) 
    if dist < self.r*2 then
      -- stop
      self.dx, self.dx = useful.lerp(self.dx, 0, dt), useful.lerp(self.dy, 0, dt)
    else
      -- move
      local speed = SPEED*dist/32
      self.dx, self.dy = dx*speed, dy*speed

      -- moving is stressful!
      self.stress = math.min(1, self.stress + speed*dt*0.02)
    end
    -- turn
    if not self.bonfire then
      self.desired_facex, self.desired_facey = dx, dy
    end
  end

  -- pain and panic!
  if self.nearestMonster then
    self.stress = math.min(1, self.stress + dt)
  else
    -- calm down man!
    self.stress = math.max(0, self.stress - 0.1*dt)
  end

  -- turn to face desired direction
  if self.desired_facex and self.desired_facey then
    if self:turnTowards(self.desired_facex, self.desired_facey, 3*dt) then
      self.desired_facex, self.desired_facey = nil, nil
    end
  end

  -- exponential decline of torch heat
  self.heat = math.max(0, self.heat - 0.01*self.heat*dt)

  -- linear decline of torch fuel
  if self.heat >= 0.2 then
    self.fuel = self.fuel - 0.001*self.heat*dt
  else
    self.heat = 0
  end

  -- extinguish if no fuel is left
  if self.torch and self.fuel < 0.3 then
    self.torch = false
    Torch(self.x, self.y, self.x, self.y, self.fuel, 0).startz = 32
  end

  -- breath
  self.t = self.t + dt*0.3*(1 + 2*self.stress)
  if self.t > 1 then
    self.t = self.t - 1
    -- face your demons!
    if self.nearestMonster then
      local dx, dy = Vector.normalize(self.nearestMonster.x - self.x,
        self.nearestMonster.y - self.y)
      self:setDesiredFacing(dx, dy)
    -- or face a random direction, that works too
    elseif math.random() > 0.7 then
      self:randomDesiredFacing()
    end
  end

  self.torch_h = self:torchHeight()

  -- fire particles
  if self.torch and self.heat > 0 then
    self.particles = self.particles + dt*10
    if self.particles > 1 then

      local x, y = self.x + self.torch_x, self.y + self.torch_y

      if math.random()*1.2 > self.heat then
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
  local mx, my = love.mouse.getPosition()
  local breath = math.sin(4*self.t*math.pi)

  -- torch behind ?
  if self.torch and self.torch_y < 0 then
    self:drawTorch()
  end

  -- body
  love.graphics.setColor(178, 122, 122)
    local w, h = (5 + breath)*(1 - 0.3*math.abs(self.facex)), 24 - breath 
    love.graphics.rectangle("fill", self.x - w, self.y - h, 2*w, h)
  useful.bindWhite()
  if self.picked then
    -- outline if picked
    useful.pushCanvas(UI_CANVAS)
    love.graphics.setColor(200, 200, 255)
      love.graphics.line(self.x, self.y, mx, my)
      love.graphics.rectangle("fill", self.x - w, self.y - h, 2*w, h)
     useful.bindWhite()
    useful.popCanvas(UI_CANVAS)
  end

  -- torch in front
  if self.torch and self.torch_y >= 0 then
    self:drawTorch()
  end

  -- torch light
  if self.torch and self.heat > 0 then
    light(x + self.torch_x, y + self.torch_y, 64, self.heat*3)
  end

  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 10 - 0.5*breath, (10 - 0.5*breath)*VIEW_OBLIQUE)
  useful.popCanvas()


  -- debug data
  if DEBUG then
    love.graphics.setFont(FONT_DEBUG)
    useful.pushCanvas(UI_CANVAS)
      if self.torch then
        love.graphics.print("heat:" .. tostring(math.floor(self.heat*10)/10), self.x, self.y - 16)
        love.graphics.print("fuel:" .. tostring(math.floor(self.fuel*10)/10), self.x, self.y)
        love.graphics.print("hunger:" .. tostring(math.floor(self.hunger*10)/10), self.x, self.y + 16)
        love.graphics.print("bodyHeat:" .. tostring(math.floor(self.bodyHeat*10)/10), self.x, self.y + 32)
      end
    -- light
    if self.nearestLight then
      love.graphics.line(self.x, self.y, self.nearestLight.x, self.nearestLight.y)
    end
    -- monster
    if self.nearestMonster then
      love.graphics.setColor(255, 0, 0)
        love.graphics.line(self.x, self.y, self.nearestMonster.x, self.nearestMonster.y)
      useful.bindWhite()
    end
    useful.popCanvas()
  end
end

function Human:antiShadow()

  if self.torch and self.heat > 0 then
    local x, y = self.x + self.torch_x, self.y + self.torch_y
    useful.pushCanvas(SHADOW_CANVAS)
      love.graphics.setBlendMode("subtractive")
        useful.oval("fill", x, y, 6, 6*VIEW_OBLIQUE)
      love.graphics.setBlendMode("alpha")
    useful.popCanvas()
  end
end

function Human:drawHighlight()
  local breath = math.sin(4*self.t*math.pi)
  local w, h = (5 + breath)*(1 - 0.3*math.abs(self.facex)), 24 - breath 
  useful.pushCanvas(UI_CANVAS)
    love.graphics.setColor(200, 200, 255)
      love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", self.x - w, self.y - h, 2*w, h)
      love.graphics.setLineWidth(1)
     useful.bindWhite()
  useful.popCanvas(UI_CANVAS)
end

--[[------------------------------------------------------------
Combat
--]]--

function Human:throw(x, y)
  Torch(self.x, self.y, x, y, self.fuel, self.heat).startz = 32
  self.torch = false
  self.nearestLight = nil
end

function Human:canThrow(x, y)
  return self.torch and (self.visibility >= 1)
end

--[[------------------------------------------------------------
Collisions
--]]--

function Human:eventCollision(other, dt)
  if other:isType("Human") then
    other:shoveAwayFrom(self, 100*dt)
  elseif other:isType("Bonfire") then
    self:shoveAwayFrom(other, 500*dt)
  elseif other:isType("Tree") then
    self:shoveAwayFrom(other, 500*dt)
  elseif other:isType("TorchFallen") then
    if not self.torch and other.fuel >= 0.3 then
      self.fuel = other.fuel
      self.heat = other.heat
      self.torch = true
      other.purge = true
    end
  elseif other:isType("Light") then
    if other.r > 0 then
      self.visibility = math.min(1, self.visibility + 2*dt)
    end
  end
end


--[[------------------------------------------------------------
Export
--]]--

return Human