function math.round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function fitInScreen(vec)
    return vector(vec.x % SCREEN.x, vec.y % SCREEN.y)
end
