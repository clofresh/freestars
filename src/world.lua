local world

local World = Class{function(self)
    self._things = {}
end}

function World:register(thing)
    table.insert(self._things, thing)
end

function World:update(dt)
    for i, thing in pairs(self._things) do
        thing:update(dt, world)
    end
end

function World:draw()
    for i, thing in pairs(self._things) do
        thing:draw()
    end
end

function World.instance()
    if world == nil then
        world = World()
    end
    return world
end



return {
    World = World,
}
