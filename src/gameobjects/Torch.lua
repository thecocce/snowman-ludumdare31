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

  init = function(self, x, y, tx, ty, starting_fuel, starting_heat)
    GameObject.init(self, x, y, 4)
    self.start_x, self.start_y = x, y
    self.target_x, self.target_y = tx, ty
    self.t = 0
    self.z = 0
    self.startz = 0
    self.dist = Vector.dist(x, y, tx, ty)
    self.dx, self.dy = (tx - x)/self.dist, (ty - y)/self.dist
    self.prev_x, self.prev_y = x, y
    self.spin = math.random()
    self.particles = math.random()
    self.fuel = starting_fuel
    self.heat = starting_heat
    self.alreadyHit = {}
  end,
}
Torch:include(GameObject)


--[[------------------------------------------------------------
Game loop
--]]--

function Torch:update(dt)
  -- progress and position
  local prev_t = self.t
  self.t = self.t + math.min(dt, 100*dt/self.dist)
  self.prev_x, self.prev_y = self.x, self.y
  self.x = useful.lerp(self.start_x, self.target_x, self.t)
  self.y = useful.lerp(self.start_y, self.target_y, self.t)

  -- height
  local life = 1-self.t
  local parabola = -(2*life-1)*(2*life-1) + 1
  self.z = life*self.startz + parabola*256*self.dist/WORLD_W

  -- die
  if life <= 0 then
    self.purge = true
    TorchFallen(self.x, self.y, self.fuel, self.heat)
  end

  -- spin
  self.spin = self.spin + dt*4
  if self.spin > 1 then
    self.spin = self.spin - 1
  end

  -- particles
  if self.heat > 0 then
    self.particles = self.particles + dt*30
    if self.particles > 1 then
      -- smoke!
      local s = Particle.Smoke(self.x, self.y, 
        -64*self.dx + useful.signedRand(8), 
        -64*self.dy + useful.signedRand(8),
        -4*(life-10 - 2) + useful.signedRand(10), 0.4)
      s.z = self.z

      -- and fire!
      local f = Particle.Fire(self.x, self.y, 
        -16*self.dx + useful.signedRand(8), 
        -16*self.dy + useful.signedRand(8),
        -4*(life-10 - 2) + useful.signedRand(10), 0.4)
      f.z = self.z

      self.particles = self.particles - 1
    end
  end
end

function Torch:draw(x, y)

  useful.bindBlack()
    local l = 12*self.fuel
    local s = self.spin
    if s < 0.25 then
      -- left
      love.graphics.rectangle("fill", self.x - l, self.y - 1 - self.z, l, 2)
    elseif s < 0.5 then
      -- up
      love.graphics.rectangle("fill", self.x - 1, self.y - l - self.z, 2, l)
    elseif s < 0.75 then
      -- right
      love.graphics.rectangle("fill", self.x, self.y - 1 - self.z, l, 2)
    elseif s <= 1 then
      -- down
      love.graphics.rectangle("fill", self.x - 1, self.y - self.z, 2, l)
    end
  love.graphics.setColor(255, 100, 55, 255*self.heat)
    love.graphics.rectangle("fill", self.x - 1, self.y - 1 - self.z, 2, 2)
  useful.bindWhite()


  -- shadow or light
  if self.heat > 0 then
    light(x, y, self.z, 2)
    light(x, y - self.z, 0, 1)
  else
    useful.pushCanvas(SHADOW_CANVAS)
      local shad_r = math.min(4, 196/self.z)*self.fuel
      useful.oval("fill", self.x, self.y, shad_r, shad_r*VIEW_OBLIQUE)
    useful.popCanvas()
  end

end

--[[------------------------------------------------------------
Collisions
--]]--

function Torch:eventCollision(other, dt)
  if self.alreadyHit[other] then
    return
  end

  if self.z < 96 then
    if other:isType("Monster") and not other:isOnFire() then
      -- set monster on fire
      if self.heat > 0.5 then
        other:ignite()
      end
      -- bounce off
      self.purge = true
      local dx, dy = self.prev_x - self.x, self.prev_y - self.y
      local t = Torch(self.x, self.y, self.x + 16*dx, self.y + 16*dy, self.fuel, self.heat - 0.5)
      t.alreadyHit[other] = true
      t.startz = self.z

    elseif other:isType("Bonfire") then
      self.purge = true
      other:addWood(self.fuel)
    end
  end

  if other:isType("Tree") and not other:isOnFire() then
    -- start fire
    if self.heat > 0.5 then
      other:ignite(0.5)
    end
    -- bounce off
    self.purge = true
    local dx, dy = self.prev_x - self.x, self.prev_y - self.y
    local t = Torch(self.x, self.y, self.x + 4*dx, self.y + 4*dy, self.fuel, self.heat - 0.5)
    t.alreadyHit[other] = true
    t.startz = self.z
  end
end



--[[------------------------------------------------------------
Export
--]]--

return Torch