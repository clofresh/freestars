local Furnace = Class{function(self, mass, capacity, maxCapacity, rechargeRate)
    self.mass = mass
    self.capacity = capacity
    self.maxCapacity = maxCapacity
    self.rechargeRate = rechargeRate
end}

function Furnace:recharge(dt)
    self.capacity = math.min(self.maxCapacity,
        self.capacity + (self.rechargeRate * dt))
end

function Furnace:burnEnergy(amount)
    self.capacity = math.max(0, self.capacity - amount)
end

function Furnace:update(dt)
    self:recharge(dt)
end

local Thruster = Class{function(self, mass, force, cost, cooldown, maxWakeAge)
    self.mass = mass
    self.force = force
    self.cost = cost
    self.cooldown = cooldown
    self.maxWakeAge = maxWakeAge
    self._thrustCooldown = cooldown
    self._wake = {}
end}

function Thruster:isReady(equipment)
    return self._thrustCooldown >= self.cooldown
    and equipment.furnace
    and equipment.furnace.capacity > self.cost
end

function Thruster:thrust(dt, pos, direction, equipment)
    local force = self.force * direction
    equipment.furnace:burnEnergy(self.cost)
    self._thrustCooldown = 0
    local wake = pos:clone()
    wake.age = 0
    table.insert(self._wake, wake)
    return force
end

function Thruster:recharge(dt)
    self._thrustCooldown = math.min(self._thrustCooldown + dt, self.cooldown)
end

function Thruster:update(dt, ship)
    if love.keyboard.isDown("d") then
        ship:turn(1)
    elseif love.keyboard.isDown("a") then
        ship:turn(-1)
    end

    if love.keyboard.isDown("w", "s", "q", "e") and self:isReady(ship.equipment) then
        local dir
        if love.keyboard.isDown("w") then
            dir = vector(0, -1)
        elseif love.keyboard.isDown("s") then
            dir = vector(0, 1)
        elseif love.keyboard.isDown("q") then
            dir = vector(-1, 0)
        elseif love.keyboard.isDown("e") then
            dir = vector(1, 0)
        end

        if dir then
            dir:rotate_inplace(ship.r)
            ship:applyForce(self:thrust(dt, ship.pos, dir, ship.equipment))
        end
    else
        self:recharge(dt)
    end

    for i, wake in pairs(self._wake) do
        wake.age = wake.age + dt
        if wake.age > self.maxWakeAge then
            self._wake[i] = nil
        end
    end
end

function Thruster:draw()
    for i, wake in pairs(self._wake) do
        love.graphics.point(wake.x % SCREEN.x, wake.y % SCREEN.y)
    end
end

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

local Cannon = Class{function(self, mass, shotMass, force, cost, cooldown,
                              maxShotAge)
    self.mass = mass
    self.shotMass = shotMass
    self.force = force
    self.cost = cost
    self.cooldown = cooldown
    self.maxShotAge = maxShotAge
    self._shotCooldown = cooldown
    self._shots = {}
end}

function Cannon:isReady(equipment)
    return self._shotCooldown >= self.cooldown
    and equipment.furnace
    and equipment.furnace.capacity > self.cost
end

function Cannon:recharge(dt)
    self._shotCooldown = math.min(self._shotCooldown + dt, self.cooldown)
end

function Cannon:update(dt, ship)
    if love.keyboard.isDown(" ") and self:isReady(ship.equipment) then
        self:shoot(dt, ship.pos, ship.r, ship:directionVector(), ship.equipment)
    else
        self:recharge(dt)
    end

    for i, shot in pairs(self._shots) do
        shot:update(dt)
        if shot.age > self.maxShotAge then
            self._shots[i] = nil
        end
    end
end

function Cannon:draw()
    for i, shot in pairs(self._shots) do
        love.graphics.draw(shot.image, shot.pos.x % SCREEN.x,
            shot.pos.y % SCREEN.y, shot.r, shot.sx, shot.sy, shot.ox, shot.oy,
            shot.ky, shot.ky)
    end
end

function Cannon:shoot(dt, pos, r, dir, equipment)
    table.insert(self._shots, Shot(images.torpedo, pos:clone(),
        self.shotMass, r, self.force * dir))
    self._shotCooldown = 0
    equipment.furnace:burnEnergy(self.cost)
end

local Ship = Class{function(self, image, pos, yaw, r, ox, oy, equipment)
    self.image = image
    self.pos = pos
    self.lastPos = pos:clone()
    self.lastDt = nil
    self.mass = 0
    for i, eq in pairs(equipment) do
        self.mass = self.mass + eq.mass
    end
    self.equipment = equipment
    self.yaw = yaw
    self.r = r
    self.ox = ox
    self.oy = oy
    self._forces = {}
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
    return self.equipment.thruster
    and self.equipment.thruster:canThrust(self.equipment)
end

function Ship:thrust(dt, direction)
    return self.equipment.thruster:thrust(dt, self.pos,
        direction:rotate(self.r), self.equipment.furnace)
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

function Ship:applyForce(force)
    table.insert(self._forces, force)
end

function Ship:update(dt)
    for name, eq in pairs(self.equipment) do
        if eq.update then
            eq:update(dt, self)
        end
    end

    local totalForce = vector(0, 0)
    for i, f in pairs(self._forces) do
        totalForce = totalForce + f
    end

    self:move(dt, totalForce)
    self._forces = {}
end

function Ship:draw()
    for name, eq in pairs(self.equipment) do
        if eq.draw then
            eq:draw()
        end
    end

    love.graphics.draw(self.image, self.pos.x % SCREEN.x,
        self.pos.y % SCREEN.y, self.r,
        self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)
end

return {
    Ship = Ship,
    Shot = Shot,
    Furnace = Furnace,
    Thruster = Thruster,
    Cannon = Cannon,
}