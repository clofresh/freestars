vector = require 'lib/hump/vector'
Class = require 'lib/hump/class'
require('src/util')

SCREEN = vector(config.screen.width, config.screen.height)

local World = require('src/world').World

local world
images = {}

function love.load()
    images.ship = love.graphics.newImage("mmrnmhrm.png")
    images.torpedo = love.graphics.newImage("torpedo.png")
    world = World()
    world:init()
end

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end
