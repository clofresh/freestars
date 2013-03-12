local Asteroid = Class{function(self, pos, spin, radius, numPoints)
    self.pos = pos
    self.spin = spin
    self.radius = radius
    local angles = {}
    while numPoints > 0 do
        table.insert(angles, math.random()*math.pi*2)
        numPoints = numPoints - 1
    end
    table.sort(angles)
    self._angles = angles
end}

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
        table.insert(asteroids, Asteroid(aPos, 0, radius, numPoints))
        numAsteroids = numAsteroids - 1
    end
    self._asteroids = asteroids
end}

function AsteroidField:draw()
    for i, ast in pairs(self._asteroids) do
        ast:draw()
    end
end

return {
    Asteroid      = Asteroid,
    AsteroidField = AsteroidField,
}
