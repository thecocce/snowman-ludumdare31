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

local Tree = Class
{
  type = GameObject.newType("Tree"),

  init = function(self, x, y)
    GameObject.init(self, x, y, 8)

    self.h = 45 + math.random()*5

    for i = 1, 2 do 
      local angle = math.random()*math.pi*2
      local dist = 8 + math.random()*4
      TorchFallen(
        x + math.cos(angle)*dist, 
        y + math.sin(angle)*dist, 0.7 + math.random()*0.3, 0)
    end

    self.branches = {}
    local n_branches = 3 + math.random(3)
    for i = 1, n_branches do
      local progress = i/n_branches
      table.insert(self.branches, {
        z = (0.2 + 0.6*progress) * self.h ,
        side = 2*(i%2) - 1,
        length = 3 + (8 + math.random()*4)*(1 - progress)
      })
    end

    self.wood = 1

    self.branchSpawn = math.random() - 1
  end,
}
Tree:include(GameObject)

--[[------------------------------------------------------------
Destruction
--]]--

function Tree:onPurge()
end

--[[------------------------------------------------------------
Fire
--]]--

function Tree:ignite()
  self.bonfire = Bonfire(self.x, self.y - 1, 0.5)
  self.bonfire.tree = self
end


function Tree:isOnFire()
  return (self.bonfire ~= nil)
end

--[[------------------------------------------------------------
Game loop
--]]--

function Tree:update(dt)

  local branchSpeed = 1/90

  if self.bonfire then
    -- burn
    if self.bonfire.purge then
      self.bonfire = nil
    else
      local offer = math.min((1 - self.bonfire.fuel)/2,
        math.min(self.wood, self.wood*dt))
      self.wood = self.wood - offer
      self.bonfire.fuel = self.bonfire.fuel + offer*2
    end

    branchSpeed = branchSpeed*(1 + 30*self.bonfire.heat)
  end


  -- spawn branches: burning ones if burning
  self.branchSpawn = self.branchSpawn + dt*branchSpeed
  if self.branchSpawn > 1 then
    self.branchSpawn = self.branchSpawn - 1

    local a = math.random()*math.pi*2
    local d = (12 + math.random()*6)
    if self.bonfire then
      d = d*(1 + self.bonfire.heat)
    end
    local x, y = self.x + math.cos(a)*d, self.y + math.sin(a)*d
    local t
    if self.bonfire then
      t = Torch(self.x, self.y, x, y, 
        0.1 + math.random()*0.2, self.bonfire.heat)
    else
      t = Torch(self.x, self.y, x, y, 
        0.7 + math.random()*0.3, 0)
    end
    t.startz = 0.5*(1 + math.random())*self.h
    t.alreadyHit[self] = true
    if self.bonfire then
      t.alreadyHit[self.bonfire] = true
    end
  end
end

function Tree:draw(x, y)
  -- tree body
  local h = self.h*self.wood
  local w = 1 + self.wood
  love.graphics.setColor(24, 32, 48)
    love.graphics.rectangle("fill", self.x - w, self.y - h, 2*w, h)
    for _, b in ipairs(self.branches) do
      love.graphics.rectangle("fill", self.x, self.y - b.z*self.wood, 
        b.length*b.side*self.wood, w)
    end
  useful.bindWhite()

  -- shadow
  useful.pushCanvas(SHADOW_CANVAS)
    useful.oval("fill", self.x, self.y, 15, 15*VIEW_OBLIQUE)
  useful.popCanvas()

  -- debug overlay
  if DEBUG then
    useful.pushCanvas(UI_CANVAS)
      love.graphics.circle("line", self.x, self.y, self.r)

      love.graphics.setFont(FONT_DEBUG)
        love.graphics.print("wood: " .. tostring(self.wood), 
          self.x, 
          self.y - self.h)
    useful.popCanvas()
  end
end



--[[------------------------------------------------------------
Collisions
--]]--

function Tree:eventCollision(other, dt)
  if other:isType("Tree") then
    other:shoveAwayFrom(self, 100*dt)
  end
end

--[[------------------------------------------------------------
Export
--]]--

return Tree