require "/scripts/zekEnergy.API.lua"
function init()
	self.produce=config.getParameter("produce")
	--self.produce.amount
	power.init()
end

function update(dt)
	
end

--Call: `world.callScriptedEntity(entity.id(), "powerOp", <factor>)` when ready
--It will return true if it produce all power or false if it failed to store all power
function powerOp(factor)
	return power.produce(self.produce.amount, factor)
end
