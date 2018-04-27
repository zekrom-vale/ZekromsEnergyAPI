require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 1)
	self.type=config.getParameter("power.type", "fuel")--or fuelBurn
	storage.time=config.getParameter("power.time", 10)
end

function update(dt)
	generate.fuel(self.powerFactor)
end

generate={}
function generate.fuel(factor)
	if storage.fuelListTimer then
		storage.fuelListTimer[1]=storage.fuelListTimer[1]-1
		if storage.fuelListTimer[1]==0 then	storage.fuelListTimer=nil	end
		return power.produce(storage.fuelListTimer[2])
	end
	local stacks=world.containerItems(entity.id())
	for _,stack in pairs(stacks) do
		local fuel=root.itemConfig(stack).config[self.type]
		if type(fuel)=="number" and (power.canProduce(fuel*factor) or self.produce.waste) then
			storage.fuelListTimer={storage.time-1,fuel*factor/storage.time}
			return power.produce(fuel*factor/storage.time)
		end
	end
end