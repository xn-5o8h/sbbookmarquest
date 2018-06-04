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
	self.checkedFUMemento = false
	self.logging = false
end

function questFail()
	if self.logging then sb.logInfo("bookmarkuestnote: giving manual marker") end
	player.startQuest(
		buildDescriptor("bookmarkuest", sb.makeUuid(), mcontroller.position(), player.worldId()),
		player.serverUuid(),
		player.worldId()
	)
	player.startQuest("bookmarkuestnote")
end

function update(dt)	--wait 3 secs for the world to load aaa
	if not self.checkedFUMemento then
		self.checkedFUMemento = true
		checkFUMemento()
	end

	if self.timer ~= -1 then
		if self.timer <= self.countdown then self.timer = self.timer + dt
		else
				self.timer = -1
			checkMemento()
		end
	end

end

function checkMemento()
	if self.logging then sb.logInfo("bookmarquestnote: checking original memento...") end

	if player.hasItem("mementomori") then
		if self.logging then sb.logInfo("bookmarquestnote: player has original memento") end

		local worldPropertyDeathPos = world.getProperty("mementomori.lastDeathPosition")
		if self.logging then sb.logInfo("bookmarquestnote: original mmori data: %s", worldPropertyDeathPos) end

	    if worldPropertyDeathPos ~= nil then
	    	local worldIdIthink = worldPropertyDeathPos[1] --aaaa player.hasQuest() is currently bugged it seems???
	--    	if player.hasQuest("bookmarkuest_mori." .. idwhatevaaa) then sb.logInfo("playerhasquest bookmarkuest_mori.%s", idwhatevaaa) return end
	--    	sb.logInfo("bookmarkquestnote: player has quest ID bookmarkuest_mori.%s: %s", idwhatevaaa, player.hasQuest("bookmarkuest_mori." .. idwhatevaaa))

			player.startQuest(
				buildDescriptor("bookmarkuest_mori", worldIdIthink, worldPropertyDeathPos, player.worldId()),
				player.serverUuid(),
				player.worldId()
			)
		end
	end
end

function checkFUMemento()
	if self.logging then sb.logInfo("bookmarquestnote: checking FU memento...") end

	if player.hasItem("fumementomori") then
		if self.logging then sb.logInfo("bookmarquestnote: player has FUmemento") end

		local statusPropertyDeathPos = status.statusProperty("mementomori.lastDeathInfo")
		if self.logging then sb.logInfo("bookmarquestnote: FU mmori data: %s", statusPropertyDeathPos) end

		if statusPropertyDeathPos ~= nil then
			player.startQuest(
				buildDescriptor("bookmarkuest_mori", statusPropertyDeathPos.worldId, statusPropertyDeathPos.position, statusPropertyDeathPos.worldId),
				player.serverUuid(),
				statusPropertyDeathPos.worldId or player.worldId() 
			)
		end
	end
end

function buildDescriptor(template, idwhatev, coords, worldId)
	local descriptor = {
          templateId = template,
          questId = template .. "." .. idwhatev,
          seed = generateSeed(),
          parameters = {}
        }
    descriptor.parameters.worldId = {type = "noDetail", name = tostring(worldId)}
    descriptor.parameters.posX = {type = "noDetail", name = tostring(coords[1])}
    descriptor.parameters.posY = {type = "noDetail", name = tostring(coords[2])}
    return descriptor
end