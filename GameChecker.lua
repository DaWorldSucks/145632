local GetGameId = game.PlaceId
local ArsenalId = 286090429
local BigPaintballId = 3527629287

--Arsenal Hub Loader
if GetGameId == ArsenalId then
    loadstring(game:HttpGet(("https://raw.githubusercontent.com/DaWorldSucks/145632/main/Arsenal.lua"),true))()
end

--Big Paintball Hub Loader
if GetGameId == BigPaintballId then
    loadstring(game:HttpGet(("https://raw.githubusercontent.com/DaWorldSucks/145632/main/Big%20Paintball"),true))()
end
