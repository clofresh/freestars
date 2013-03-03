vector = require 'lib/hump/vector'
Class = require('lib/hump/class')

local images = {}
local ship
local screen = vector(config.screen.width, config.screen.height)

local Shot = Class{function(self, image, pos, mass, r, launchForce)
    self.image = image
    self.pos = pos
    self.lastPos = pos:clone()
    self.lastDt = nil
    self.mass = mass
    self.r = r
    self.launchForce = launchForce
    self.age = 0
end}

function Shot:move(dt)
    local newPos
    if self.lastDt ~= nil then
        newPos = vector(
            self.pos.x
            + (self.pos.x - self.lastPos.x) * (dt / self.lastDt),
            self.pos.y
            + (self.pos.y - self.lastPos.y) * (dt / self.lastDt)
        )
    else
        local a = self.launchForce / self.mass
        newPos = vector(
            self.pos.x
            + (self.pos.x - self.lastPos.x) * dt
            + a.x * dt * dt,
            self.pos.y
            + (self.pos.y - self.lastPos.y) * dt
            + a.y * dt * dt
        )
    end
    self.lastDt = dt
    self.lastPos = self.pos
    self.pos = newPos
end

function Shot:update(dt)
    self:move(dt)
    self.age = self.age + dt
end

local Ship = Class{function(self, image, pos, mass, thrustAttrs, shotAttrs,
                            yaw, r, ox, oy)
    self.image = image
    self.pos = pos
    self.lastPos = pos:clone()
    self.lastDt = nil
    self.mass = mass
    self.thrustAttrs = thrustAttrs
    self.yaw = yaw
    self.r = r
    self.ox = ox
    self.oy = oy
    self.shotAttrs = shotAttrs
    self._shotCooldown = shotAttrs.cooldown
    self._shots = {}
end}

function Ship:turn(direction)
    self.r = self.r + (self.yaw * 2*math.pi/360) * direction
end

function Ship:directionVector()
    local dir = vector(0, -1)
    dir:rotate_inplace(self.r)
    return dir
end

function Ship:canThrust()
    return self.thrustAttrs.capacity > 0
end

function Ship:thrust(dt, direction)
    local force = vector(0, self.thrustAttrs.force * direction)
    force:rotate_inplace(self.r)
    self.thrustAttrs.capacity = math.max(0,
        self.thrustAttrs.capacity - (self.thrustAttrs.burnRate * dt))
    return force
end

function Ship:rechargeThrust(dt)
    self.thrustAttrs.capacity = math.min(self.thrustAttrs.maxCapacity,
        self.thrustAttrs.capacity + (self.thrustAttrs.rechargeRate * dt))
end

function Ship:move(dt, force)
    local newPos, a
    if force == nil then
        a = vector(0, 0)
    else
        a = force / self.mass
    end
    if self.lastDt ~= nil then
        newPos = vector(
            self.pos.x
            + (self.pos.x - self.lastPos.x) * (dt / self.lastDt)
            + a.x * dt * dt,
            self.pos.y
            + (self.pos.y - self.lastPos.y) * (dt / self.lastDt)
            + a.y * dt * dt
        )
    else
        newPos = self.pos
    end
    self.lastDt = dt
    self.lastPos = self.pos
    self.pos = vector(newPos.x, newPos.y)
end

function Ship:canShoot()
    return self._shotCooldown >= self.shotAttrs.cooldown
    and #self._shots < self.shotAttrs.maxShots 
end

function Ship:shoot()
    table.insert(self._shots, Shot(images.torpedo, self.pos:clone(),
        self.shotAttrs.mass, self.r,
        self.shotAttrs.force * self:directionVector()))
    self._shotCooldown = 0
end

function Ship:rechargeShot(dt)
    self._shotCooldown = math.min(self._shotCooldown + dt,
                                  self.shotAttrs.cooldown)
end

function Ship:updateShots(dt)
    for i, shot in pairs(self._shots) do
        shot:update(dt)
        if shot.age > self.shotAttrs.maxAge then
            self._shots[i] = nil
        end
    end
end


function love.load()
    images.ship = love.graphics.newImage("mmrnmhrm.png")
    images.torpedo = love.graphics.newImage("torpedo.png")
    local mass = 10
    local thrustAttrs = {
        force = 1000,
        capacity = 20,
        maxCapacity = 20,
        burnRate = 10,
        rechargeRate = 5
    }
    local shotAttrs = {
        maxAge = 0.5,
        maxShots = 5,
        force = 20000,
        mass = 2,
        cooldown = 0.25
    }
    local yaw = 4
    local r = 0
    local ox = 13
    local oy = 16
    ship = Ship(images.ship, vector(100, 100), mass, thrustAttrs, shotAttrs,
                yaw, r, ox, oy)
end

function love.update(dt)
    if love.keyboard.isDown(" ") and ship:canShoot() then
        ship:shoot()
    else
        ship:rechargeShot(dt)
    end

    if love.keyboard.isDown("d") then
        ship:turn(1)
    elseif love.keyboard.isDown("a") then
        ship:turn(-1)
    end

    if love.keyboard.isDown("w", "s") then
        if ship:canThrust() then
            if love.keyboard.isDown("w") then
                ship:move(dt, ship:thrust(dt, -1))
            else
                ship:move(dt, ship:thrust(dt, 1))
            end
        else
            ship:move(dt)
        end
    else
        ship:rechargeThrust(dt)
        ship:move(dt)
    end

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

  love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Thrust: %d
]], 
math.floor(collectgarbage('count')),
ship_x,
ship_y,
ship.thrustAttrs.capacity
), 1, 1)

end

