require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")
require("/scripts/util.lua")

function init()
	setPortraits()
	script.setUpdateDelta(100)
	quest.setObjectiveList({{"^green;Abandon this quest^reset; to set a ^orange; bookmark here^reset;.", false}})
	quest.setText("^green;Abandon this quest^reset; to ^orange;set a bookmark^reset;.")

	self.countdown = 2
	self.timer = 0
end

function questFail()
--	sb.logInfo("bookmarkuestnote: giving manual marker")
	player.startQuest(
		buildDescriptor("bookmarkuest", sb.makeUuid(), mcontroller.position()),
		player.serverUuid(),
		player.worldId()
	)
	player.startQuest("bookmarkuestnote")
end

function update(dt)	--wait 3 secs for the world to load aaa
	if self.timer ~= -1 then
		if self.timer <= self.countdown then self.timer = self.timer + dt
		else
			self.timer = -1
			checkMemento()
		end
	end
end

function checkMemento()
	if not player.hasItem("mementomori") then return end
	local _e = world.getProperty("mementomori.lastDeathPosition")
--  	sb.logInfo("bookmarquestnote: mmori: %s", _e)
    if _e ~= nil then
    	local idwhatevaaa = _e[1] --aaaa player.hasQuest() is currently bugged it seems???
--    	if player.hasQuest("bookmarkuest_mori." .. idwhatevaaa) then sb.logInfo("playerhasquest bookmarkuest_mori.%s", idwhatevaaa) return end
--    	sb.logInfo("bookmarkquestnote: player has quest ID bookmarkuest_mori.%s: %s", idwhatevaaa, player.hasQuest("bookmarkuest_mori." .. idwhatevaaa))

		player.startQuest(
			buildDescriptor("bookmarkuest_mori", idwhatevaaa, _e),
			player.serverUuid(),
			player.worldId()
		)
	end
end


function buildDescriptor(template, idwhatev, coords)
	local descriptor = {
          templateId = template,
          questId = template .. "." .. idwhatev,
          seed = generateSeed(),
          parameters = {}
        }
    descriptor.parameters.posX = {type = "noDetail", name = tostring(coords[1])}
    descriptor.parameters.posY = {type = "noDetail", name = tostring(coords[2])}
    return descriptor
end