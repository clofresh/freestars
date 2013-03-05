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
    local mX, mY = love.mouse.getPosition()
    if mx ~= nil then
        local mousePos = vector(mX, mY)
        local a = (mousePos - vector(ship.pos.x % SCREEN.x, ship.pos.y % SCREEN.y))
        local b = vector(0, -1)
        if mX > ship.pos.x % SCREEN.x then
            ship.r = math.acos((a * b)/(a:len() * b:len()))
        else
            ship.r = (2*math.pi) - math.acos((a * b)/(a:len() * b:len()))
        end
    end
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

return {
    Thruster = Thruster,
}
