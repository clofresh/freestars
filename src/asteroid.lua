local Asteroid = Class{function(self, pos, velocity, spin, radius, numPoints,
                                life, density)
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
    if life == nil then
        self.life = self.mass / 100
    else
        self.life = life
    end

    -- To draw the asteroid, we pick `numPoints` random angles on a circle
    -- and sort the angles in ascending order. Later when we draw the
    -- asteroid, we calculate the x, y coordinates of those angles
    -- using the `pos` and `radius` values, then draw lines connecting those
    -- points. Basically an asteroid is just a jaggy circle.
    local angles = {}
    while numPoints > 0 do
        table.insert(angles, math.random()*math.pi*2)
        numPoints = numPoints - 1
    end
    table.sort(angles)
    self._angles = angles
    self._forces = {}
    self.color = {255, 255, 255}
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

function Asteroid:collide(other)
    -- Take a shortcut and assume the hit area of the asteroid is a perfect
    -- circle instead of trying to have pixel perfect collisions.
    -- When you know it's a circle, all you need to know if there's a collision
    -- is if the distance from the center of the asteroid to other is within a
    -- radius of the circle.
    local distance = (fitInScreen(self.pos) - fitInScreen(other.pos)):len()
    if distance <= self.radius then
        self.color = {255, 0, 0}
        self.life = self.life - other.damage
        print(string.format("Collision. %d life left", self.life))
    end
end

function Asteroid:isDestroyed()
    return self.life <= 0
end

function Asteroid:update(dt, world)
    local totalForce = vector(0, 0)
    for i, f in pairs(self._forces) do
        totalForce = totalForce + f
    end

    self:move(dt, totalForce)
    self:rotate(dt)
    self.color = {255, 255, 255}
end

function Asteroid:draw()
    local coordinates = {}
    -- Calculate the x, y coordinates of the points on the circle
    -- form the angle, radius and pos, then connect the dots to draw it
    for i, angle in pairs(self._angles) do
        table.insert(coordinates, (math.cos(angle) * self.radius) + self.pos.x)
        table.insert(coordinates, (math.sin(angle) * self.radius) + self.pos.y)
    end
    table.insert(coordinates, coordinates[1])
    table.insert(coordinates, coordinates[2])
    love.graphics.setColor(unpack(self.color))
    love.graphics.line(unpack(coordinates))
end

local AsteroidField = Class{function(self, pos, w, h, numAsteroids, maxRadius)
    self.pos = pos
    self.w = w
    self.h = h
    asteroids = {}
    while numAsteroids > 0 do
        -- Pick a random point in the area as the asteroid's center
        local aPos = pos + vector(math.round(math.random() * w),
                                  math.round(math.random() * h))
        -- Pick a random radius, at least 10 pixels
        local radius = (math.random() * maxRadius) + 10
        -- Pick a random number of points on the asteroid based on the radius
        local numPoints = math.round(radius / 10) + 5
        --- Pick a random velocity
        local velocity = vector((math.random() * 20) - 10,
                                (math.random() * 20) - 10)
        -- Pick a random spin
        local spin = (math.random() * 2 * math.pi) - (math.pi)
        table.insert(asteroids, Asteroid(aPos, velocity, spin, radius, numPoints))
        numAsteroids = numAsteroids - 1
    end
    self._asteroids = asteroids
end}

function AsteroidField:collide(other)
    for i, ast in pairs(self._asteroids) do
        ast:collide(other)
    end
end

function AsteroidField:update(dt, world)
    for i, ast in pairs(self._asteroids) do
        ast:update(dt, world)
        if ast:isDestroyed() then
            self._asteroids[i] = nil
        end
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
