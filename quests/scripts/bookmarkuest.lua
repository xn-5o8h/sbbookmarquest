require("/quests/scripts/portraits.lua")
require("/quests/scripts/questutil.lua")
require("/scripts/util.lua")

function init()
	self.currpos = mcontroller.position()
	self.distance = 0
	getPos()

	setPortraits()

	self.title = nil
	setTitle()

	self.questTemplate = quest.templateId()

	self.removeQuestWhenNear = config.getParameter("removeQuestWhenNear")
	if self.removeQuestWhenNear then self.howNearIsNear = config.getParameter("howNearIsNear", 0) end
	self.updateDelta = config.getParameter("updateDelta")
	self.objectiveText = config.getParameter("trackerObjective")
	quest.setObjectiveList({{self.objectiveText .. "§", false}})
end

function questStart()
	getPos()
	quest.setText(buildText())
end

function update()
	if onQuestWorld() and self.bookmark ~= nil then
		script.setUpdateDelta(self.updateDelta)
		self.currpos = mcontroller.position()
		self.distance = util.round(world.magnitude(self.bookmark, self.currpos), 1)

		quest.setObjectiveList({{self.objectiveText .. self.distance, false}})
		quest.setProgress(1 - (self.distance / (world.size()[1]/2)))
		questutil.pointCompassAt(self.bookmark)

		setTitle()

		if self.removeQuestWhenNear and self.distance <= self.howNearIsNear then
			if self.questTemplate == "bookmarkuest_mori" then world.setProperty("mementomori.lastDeathPosition", nil) end
			quest.complete()
		end

	else
		script.setUpdateDelta(40)
	end
end

function getPos()
	local tmp = quest.parameters().posX
	if tmp ~= nil then self.bookmark = { tmp.name, quest.parameters().posY.name } else self.bookmark = nil end
end

function onQuestWorld()
	return player.worldId() == quest.worldId() and player.serverUuid() == quest.serverUuid()
end

function setTitle()
	if self.bookmark ~= nil then
		if self.title == nil then
			self.title = config.getParameter("titleText")
			if config.getParameter("addId") then
				self.title = self.title .. " ^gray;#X" .. string.char(64 + (util.round(self.bookmark[1], 0) % 26)) .. "Y" .. string.char(64 + (util.round(self.bookmark[2], 0) % 26)) --Thanks based Medeor
			end
		end
		if onQuestWorld() then
			quest.setTitle(self.title .. "\n^green; Current world:^cyan; " .. self.distance)
		else
			quest.setTitle(self.title .. "\n^gray; Another world")
		end
	end
end

function buildText()
	local worldId = player.worldId()
	local worldTypeStr = {"", "^green; somewhere unknown", ""}

	if string.find(worldId, "CelestialWorld", 0, 20) then worldTypeStr = {"a^gray;(n)^green; ", world.type(), " planet"}
	elseif string.find(worldId, "ClientShipWorld", 0, 20) then
		worldTypeStr = {"a ", "ship", ""}
		if worldId == player.ownShipWorldId() then worldTypeStr[1] = "your " end
	elseif string.find(worldId, "InstanceWorld", 0, 20) then worldTypeStr = {"the ", world.type(), " instance"}
	end

	s = config.getParameter("textIntro") .. " ^green;" ..worldTypeStr[1]..worldTypeStr[2].."^reset;"..worldTypeStr[3].."."
	s = s .. "\n\n^cyan;Coordinates\n============\n^cyan;X: ^orange;"
	s = s .. util.round(self.bookmark[1], 1) .. "\n^cyan;Y: ^orange;" .. util.round(self.bookmark[2], 1)

	if string.find(worldId, "CelestialWorld") ~= nil then
		local getWorldXY = string.sub(worldId, string.find(worldId, ":") + 1)
		local worldX = string.sub(getWorldXY, 0, string.find(getWorldXY, ":") - 1)
		local worldY = string.sub(getWorldXY, string.len(worldX) + 2, string.find(getWorldXY, ":", string.len(worldX) + 2) - 1)

		s = s .."\n\n^cyan;Planet coordinates\n===================\n"
		s = s .. "X: ^orange;" .. worldX
		s = s .. "\n^cyan;Y: ^orange;" .. worldY
	end

	s = s .."\n\n^gray;Abandon to remove the marker."
	return s
end