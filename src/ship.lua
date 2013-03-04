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

local Ship = Class{function(self, image, pos, mass, energyAttrs, thrustAttrs,
                            shotAttrs, yaw, r, ox, oy)
    self.image = image
    self.pos = pos
    self.lastPos = pos:clone()
    self.lastDt = nil
    self.mass = mass
    self.energyAttrs = energyAttrs
    self.thrustAttrs = thrustAttrs
    self._thrustCooldown = thrustAttrs.cooldown
    self._wake = {}
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
    return self._thrustCooldown >= self.thrustAttrs.cooldown
    and self.energyAttrs.capacity > self.thrustAttrs.cost
end

function Ship:thrust(dt, direction)
    local force = self.thrustAttrs.force * direction
    force:rotate_inplace(self.r)
    self:burnEnergy(self.thrustAttrs.cost)
    self._thrustCooldown = 0
    local wake = self.pos:clone()
    wake.age = 0
    table.insert(self._wake, wake)
    return force
end

function Ship:rechargeThrust(dt)
    self._thrustCooldown = math.min(self._thrustCooldown + dt,
                                    self.thrustAttrs.cooldown)
end

function Ship:rechargeEnergy(dt)
    self.energyAttrs.capacity = math.min(self.energyAttrs.maxCapacity,
        self.energyAttrs.capacity + (self.energyAttrs.rechargeRate * dt))
end

function Ship:burnEnergy(amount)
    self.energyAttrs.capacity = math.max(0, self.energyAttrs.capacity - amount)
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
    and self.energyAttrs.capacity > self.shotAttrs.cost
end

function Ship:shoot()
    table.insert(self._shots, Shot(images.torpedo, self.pos:clone(),
        self.shotAttrs.mass, self.r,
        self.shotAttrs.force * self:directionVector()))
    self._shotCooldown = 0
    self:burnEnergy(self.shotAttrs.cost)
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

function Ship:updateWake(dt)
    for i, wake in pairs(self._wake) do
        wake.age = wake.age + dt
        if wake.age > self.thrustAttrs.maxWakeAge then
            self._wake[i] = nil
        end
    end
end

return {
    Ship = Ship,
    Shot = Shot
}