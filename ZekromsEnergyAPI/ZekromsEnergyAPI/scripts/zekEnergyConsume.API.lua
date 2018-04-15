require "/scripts/zekEnergy.API.lua"
function init()
	self.consume=config.getParameter("consume")
	--self.consume.config=="operation" or "dt"
	--self.consume.amount or self.consume.dt
	power.init()
end

function update(dt)
	if self.consume.config=="dt" then
		storage.powered=consume(self.consume.dt, dt)
	end
	power.update(dt)
end

--Call: `world.callScriptedEntity(entity.id(), "powerOp")` when ready
--It will return true if it consumed power, false if it failed, or nil if the config is incorrect
function powerOp(amount)
	if self.consume.config~="operation" then
		sb.logError("Incorrect consumer type")
		return nil
	end
	return power.consume(amount or self.consume.amount, 1)
end
