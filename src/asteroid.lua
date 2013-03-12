local Asteroid = Class{function(self, pos, velocity, spin, radius, numPoints,
                                density)
    self.pos = pos
    self.lastDt = 1
    self.lastPos = pos - velocity * self.lastDt
    self.spin = spin
    self.radius = radius
    if density == nil then
        self.density = 100
    else
        self.density = density
    end
    self.mass = self.density * self:area()
    local angles = {}
    while numPoints > 0 do
        table.insert(angles, math.random()*math.pi*2)
        numPoints = numPoints - 1
    end
    table.sort(angles)
    self._angles = angles
    self._forces = {}
end}

function Asteroid:area()
    -- approximate its area as the area of the circle that circumscribes it
    return math.pi * self.radius * self.radius
end

function Asteroid:move(dt, force)
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

function Asteroid:rotate(dt)
    local rotation = self.spin * dt
    if rotation ~= 0 then
        for i, a in pairs(self._angles) do
            self._angles[i] = (a + rotation) % (2 * math.pi)
        end
    end
end

function Asteroid:update(dt, world)
    local totalForce = vector(0, 0)
    for i, f in pairs(self._forces) do
        totalForce = totalForce + f
    end

    self:move(dt, totalForce)
    self:rotate(dt)
end

function Asteroid:draw()
    local coordinates = {}
    for i, angle in pairs(self._angles) do
        table.insert(coordinates, (math.cos(angle) * self.radius) + self.pos.x)
        table.insert(coordinates, (math.sin(angle) * self.radius) + self.pos.y)
    end
    table.insert(coordinates, coordinates[1])
    table.insert(coordinates, coordinates[2])
    love.graphics.line(unpack(coordinates))
end

local AsteroidField = Class{function(self, pos, w, h, numAsteroids, maxRadius)
    self.pos = pos
    self.w = w
    self.h = h
    asteroids = {}
    while numAsteroids > 0 do
        local aPos = pos + vector(math.round(math.random() * w),
                                  math.round(math.random() * h))
        local radius = (math.random() * maxRadius) + 10
        local numPoints = math.round(radius / 10) + 5
        local velocity = vector((math.random() * 20) - 10,
                                (math.random() * 20) - 10)
        local spin = (math.random() * 2 * math.pi) - (math.pi)
        table.insert(asteroids, Asteroid(aPos, velocity, spin, radius, numPoints))
        numAsteroids = numAsteroids - 1
    end
    self._asteroids = asteroids
end}

function AsteroidField:update(dt, world)
    for i, ast in pairs(self._asteroids) do
        ast:update(dt, world)
    end
end

function AsteroidField:draw()
    for i, ast in pairs(self._asteroids) do
        ast:draw()
    end
end

return {
    Asteroid      = Asteroid,
    AsteroidField = AsteroidField,
}
