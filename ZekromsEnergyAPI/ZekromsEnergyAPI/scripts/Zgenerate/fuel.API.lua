--Generates power based off of the fuel item config
--Use fuelList.API.lua for more control
require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor",1)--Determines the energy multiplier
	self.type=config.getParameter("power.type","fuel")--or fuelBurn	--Indicates the power produced from each fuel
	storage.time=config.getParameter("power.time",10)-1--Defines how long it takes for the items to generate power*dt
	self.produce.waste=config.getParameter("power.waste",false)--Defines whether to waste fuel or not
end

function update(dt)
	if storage.fuelListTimer then
		storage.fuelListTimer[1]=storage.fuelListTimer[1]-1
		if storage.fuelListTimer[1]==0 then	storage.fuelListTimer=nil	end
		return power.produce(storage.fuelListTimer[2],self.powerFactor)
	end
	for _,stack in pairs(world.containerItems(entity.id()))do
		local fuel=root.itemConfig(stack).config[self.type]
		if type(fuel)=="number"and(power.canProduce(fuel*self.powerFactor)or self.produce.waste)then
			storage.fuelListTimer={storage.time,fuel/storage.time}
			return power.produce(fuel/storage.time,self.powerFactor)
		end
	end
end