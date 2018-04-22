require "/scripts/zekEnergy.API.lua"
function init()
	self.produce=config.getParameter("produce")
	--self.produce.amount
	power.init()
end

function update(dt)
	power.update(dt)
end

--Call: `world.callScriptedEntity(entity.id(), "powerProduce", <factor>)` when ready
--It will return true if it produce all power or false if it failed to store all power
function powerProduce(factor)
	return power.produce(self.produce.amount, factor or 1)
end
