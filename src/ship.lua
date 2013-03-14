local Armor = Class{function(self, life, mass)
    self.life = life
    self.mass = mass
end}

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
    self.radius = 10
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
        -- verlet integration. Gotta refactor into a generic function
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

function Ship:isDestroyed()
    return self.equipment.armor.life <= 0
end

function Ship:update(dt, world)
    for name, eq in pairs(self.equipment) do
        if eq.update then
            eq:update(dt, world, self)
        end
    end

    local totalForce = vector(0, 0)
    for i, f in pairs(self._forces) do
        totalForce = totalForce + f
    end

    self:move(dt, totalForce)
    self._forces = {}
    local collided = world.field:checkCollision(self)
    if #collided > 0 then
        self.color = {255, 0, 0}
        self.equipment.armor.life = self.equipment.armor.life - 1
    else
        self.color = {255, 255, 255}
    end
end

function Ship:draw()
    for name, eq in pairs(self.equipment) do
        if eq.draw then
            eq:draw()
        end
    end

    local shipX = self.pos.x % SCREEN.x
    local shipY = self.pos.y % SCREEN.y

    love.graphics.print(string.format(
[[Memory: %dKB
Pos: (%d, %d)
Armor: %f
Energy: %f
R: %f
]],
    math.floor(collectgarbage('count')),
    shipX,
    shipY,
    self.equipment.armor.life,
    self.equipment.furnace.capacity,
    self.r
    ), 1, 1)

    love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image, shipX, shipY, self.r,
        self.sx, self.sy, self.ox, self.oy, self.kx, self.ky)

end

return {
    Armor = Armor,
    Ship  = Ship,
}
