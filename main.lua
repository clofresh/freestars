vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'

images = {}
local ship
local screen = vector(config.screen.width, config.screen.height)
local Ship = require('src/ship').Ship

function love.load()
    images.ship = love.graphics.newImage("mmrnmhrm.png")
    images.torpedo = love.graphics.newImage("torpedo.png")
    local mass = 2
    local energyAttrs = {
        capacity = 100,
        maxCapacity = 100,
        rechargeRate = 5
    }
    local thrustAttrs = {
        force = 1000,
        cost = 1,
        cooldown = 0.05,
        maxWakeAge = 0.5
    }
    local shotAttrs = {
        maxAge = 0.5,
        force = 20000,
        mass = 2,
        cooldown = 0.1,
        cost = 4
    }
    local yaw = 4
    local r = 0
    local ox = 13
    local oy = 16
    ship = Ship(images.ship, vector(100, 100), mass, energyAttrs, thrustAttrs,
                shotAttrs, yaw, r, ox, oy)
end

function love.update(dt)
    if love.keyboard.isDown(" ") and ship:canShoot() then
        ship:shoot(dt)
    else
        ship:rechargeShot(dt)
    end

    if love.keyboard.isDown("d") then
        ship:turn(1)
    elseif love.keyboard.isDown("a") then
        ship:turn(-1)
    end

    if love.keyboard.isDown("w", "s", "q", "e") and ship:canThrust() then
        if love.keyboard.isDown("w") then
            ship:move(dt, ship:thrust(dt, vector(0, -1)))
        elseif love.keyboard.isDown("s") then
            ship:move(dt, ship:thrust(dt, vector(0, 1)))
        elseif love.keyboard.isDown("q") then
            ship:move(dt, ship:thrust(dt, vector(-1, 0)))
        elseif love.keyboard.isDown("e") then
            ship:move(dt, ship:thrust(dt, vector(1, 0)))
        end
    else
        ship:move(dt)
        ship:rechargeThrust(dt)
    end

    ship:rechargeEnergy(dt)
    ship:updateWake(dt)
    ship:updateShots(dt)
end

function love.draw()
    local ship_x = ship.pos.x % screen.x
    local ship_y = ship.pos.y % screen.y
    for i, shot in pairs(ship._shots) do
        love.graphics.draw(shot.image, shot.pos.x % screen.x,
            shot.pos.y % screen.y, shot.r, shot.sx, shot.sy, shot.ox, shot.oy,
            shot.ky, shot.ky)
    end
    love.graphics.draw(ship.image, ship_x, ship_y, ship.r,
        ship.sx, ship.sy, ship.ox, ship.oy, ship.kx, ship.ky)
    for i, wake in pairs(ship._wake) do
        love.graphics.point(wake.x % screen.x, wake.y % screen.y)
    end

  love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Energy: %f
]], 
math.floor(collectgarbage('count')),
ship_x,
ship_y,
ship.energyAttrs.capacity
), 1, 1)

end

