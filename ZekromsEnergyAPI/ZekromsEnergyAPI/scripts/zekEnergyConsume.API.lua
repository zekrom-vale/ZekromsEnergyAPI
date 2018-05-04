require "/scripts/zekEnergy.API.lua"
--DO NOT USE THIS!
consume={}
function consume.init()
	self.consume=config.getParameter("consume")
	self.consume={
		config=self.consume.config or "dt" --"operation"
		dt=self.consume.dt or 100
	}
	storage.powered=storage.powered or false
end

function consume.update(dt)
	if self.consume.config=="dt" then
		storage.powered=consume(self.consume.dt, dt)
	end
end