require "/scripts/zekEnergy.API.lua"
function init()
	self.consumeDt=config.getParameter("consumeDt")
	power.init()
end

function update(dt)
	storage.powered=consume(self.consumeDt, dt)
	power.update(dt)
end