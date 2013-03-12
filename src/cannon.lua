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

function Shot:update(dt, world)
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

function Cannon:update(dt, world, ship)
    if (love.keyboard.isDown(" ") or love.mouse.isDown("l"))
    and self:isReady(ship.equipment) then
        self:shoot(dt, ship.pos, ship.r, ship:directionVector(), ship.equipment)
    else
        self:recharge(dt)
    end

    for i, shot in pairs(self._shots) do
        shot:update(dt, world)
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

return {
    Cannon = Cannon,
}
