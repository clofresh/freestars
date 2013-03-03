vector = require 'lib/hump/vector'

local ship = {}
local screen = vector(config.screen.width, config.screen.height)

function love.load()
    ship.image = love.graphics.newImage("mmrnmhrm.png")
    ship.last_pos = vector(100, 100)
    ship.last_dt = nil
    ship.pos = vector(100, 100)
    ship.mass = 10
    ship.thrust = {
        power = 1000,
        capacity = 10,
        max_capacity = 100,
        burn_rate = 5,
        recharge_rate = 5
    }
    ship.yaw = 4
    ship.r = 0
    ship.ox = 13
    ship.oy = 16
end

function love.update(dt)
    if love.keyboard.isDown("d") then
        ship.r = ship.r + (ship.yaw * 2*math.pi/360)
    elseif love.keyboard.isDown("a") then
        ship.r = ship.r - (ship.yaw * 2*math.pi/360)
    end

    local F = vector(0, 0), new_pos
    if love.keyboard.isDown("w", "s") then
        if ship.thrust.capacity > 0 then
            if love.keyboard.isDown("w") then
                F = vector(0, -ship.thrust.power)
            else
                F = vector(0, ship.thrust.power)
            end
            F:rotate_inplace(ship.r)
            ship.thrust.capacity = math.max(0,
                ship.thrust.capacity - (ship.thrust.burn_rate * dt))
        end
    else
        ship.thrust.capacity = math.min(ship.thrust.max_capacity,
            ship.thrust.capacity + (ship.thrust.recharge_rate * dt))
    end

    local a = F / ship.mass
    if ship.last_dt ~= nil then
        new_pos = vector(
            ship.pos.x
            + (ship.pos.x - ship.last_pos.x) * (dt / ship.last_dt)
            + a.x * dt * dt,
            ship.pos.y
            + (ship.pos.y - ship.last_pos.y) * (dt / ship.last_dt)
            + a.y * dt * dt
        )
    else
        new_pos = ship.pos
    end
    ship.last_dt = dt
    ship.last_pos = ship.pos
    ship.pos = vector(new_pos.x, new_pos.y)
end

function love.draw()
    local ship_x = ship.pos.x % screen.x
    local ship_y = ship.pos.y % screen.y
    love.graphics.draw(ship.image, ship_x, ship_y, ship.r,
        ship.sx, ship.sy, ship.ox, ship.oy, ship.kx, ship.ky)

  love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Thrust: %d
]], 
math.floor(collectgarbage('count')),
ship_x,
ship_y,
ship.thrust.capacity
), 1, 1)

end

