COLOUR_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
ALPHA_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
LIGHT_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
SHADOW_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)

function light(x, y, z, intensity, r, g, b)

  local power = math.max(0, (0.00976563 -0.0000457764*z)*z + 0.5)

  local max_size = 0

  for i = intensity, 0, -0.2 do
    local x = x + useful.signedRand(2 + 0.1*i)
    local y = y + useful.signedRand(2 + 0.1*i)
    local z = z + math.max(0.1, useful.signedRand(2 + 0.1*i))

    local size = math.max(0, power*i*32 - z/128)
    if size > max_size then
      max_size = size
    end

    -- erase darkness
    useful.pushCanvas(ALPHA_CANVAS)
      useful.bindWhite(i/intensity*255)
      useful.oval("fill", x, y, size, size*VIEW_OBLIQUE)
    useful.popCanvas()

    -- colour light
    useful.pushCanvas(COLOUR_CANVAS)
      love.graphics.setColor(255, 55, 10, i/intensity*32)
      love.graphics.setBlendMode("additive")
        useful.oval("fill", x, y, size, size*VIEW_OBLIQUE)
      love.graphics.setBlendMode("alpha")
    useful.popCanvas()

  end
  useful.bindWhite()

end