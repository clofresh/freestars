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

function Furnace:update(dt, world)
    self:recharge(dt)
end

return {
    Furnace = Furnace,
}
