COLOUR_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
ALPHA_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
LIGHT_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)
SHADOW_CANVAS = love.graphics.newCanvas(WORLD_W, WORLD_H)

function update_light(day_night)
  -- calculate lightness based on time of day
  local lightness = math.max(0, 4*(1 - day_night)*day_night)
  local r, g, b = useful.ktemp(useful.lerp(16000, 2000, day_night))
  useful.pushCanvas(COLOUR_CANVAS)
    love.graphics.setColor(r*lightness, g*lightness, b*lightness, 32)
      love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    useful.bindWhite()
  useful.popCanvas()

  useful.pushCanvas(ALPHA_CANVAS)
    useful.bindWhite(lightness*255)
      love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    useful.bindBlack((1 - lightness)*255)
      love.graphics.rectangle("fill", 0, 0, WORLD_W, WORLD_H)
    useful.bindWhite()
  useful.popCanvas()
end

function bake_light()
  useful.pushCanvas(LIGHT_CANVAS)
    love.graphics.draw(COLOUR_CANVAS)
    love.graphics.setBlendMode("multiplicative")
      love.graphics.draw(ALPHA_CANVAS)
    love.graphics.setBlendMode("alpha")
  useful.popCanvas(LIGHT_CANVAS)
  love.graphics.setBlendMode("multiplicative")
    love.graphics.draw(LIGHT_CANVAS)
  love.graphics.setBlendMode("alpha")
end

function light(x, y, z, intensity, r, g, b)

  local power = math.max(0, (0.00976563 -0.0000457764*z)*z + 0.5)

  local max_size = 0



  -- pre-randomise
  local step = intensity/10
  local params = {}
  for i = intensity, 0, -step do
    local s = math.max(0, power*i*32 - z/128)
    if s > max_size then
      max_size = s
    end
    table.insert(params, {
      x = x + useful.signedRand(2 + 0.1*i),
      y = y + useful.signedRand(2 + 0.1*i),
      z = z + math.max(0.1, useful.signedRand(2 + 0.1*i)),
      size = s,
      intensity = i/intensity
    })
  end

  -- erase darkness
  useful.pushCanvas(ALPHA_CANVAS)
    for _, p in ipairs(params) do
      useful.bindWhite(p.intensity*255)
      useful.oval("fill", p.x, p.y, p.size, p.size*VIEW_OBLIQUE)
    end
  useful.popCanvas()

  -- colour light
  useful.pushCanvas(COLOUR_CANVAS)
    for _, p in ipairs(params) do
      love.graphics.setColor(255, 55, 10, p.intensity*32)
      love.graphics.setBlendMode("additive")
        useful.oval("fill", p.x, p.y, p.size, p.size*VIEW_OBLIQUE)
      love.graphics.setBlendMode("alpha")
    end
  useful.popCanvas()
  useful.bindWhite()
end