--A more detailed version of fuel.API.lua and requires a config file defining the item power and time
require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor",1)--Indicates the factor that applies to all items
	self.recipes=root.assetJson(config.getParameter("fuelGen")) or {}--Points to the JSON recipe file
end

function update(dt)
	if next(self.recipes)==nil then	return	end
	if storage.fuelListTimer then
		storage.fuelListTimer[1]=storage.fuelListTimer[1]-1
		if storage.fuelListTimer[1]<=0 then	storage.fuelListTimer=nil	end
		return power.produce(storage.fuelListTimer[2])
	end
	local stacks=world.containerItems(entity.id())
	local self=self
	for _,stack in pairs(stacks) do
		for _,recipe in pairs(self.recipes)
			if stack.name==value.name then
				if power.canProduce(value.fuel*self.powerFactor) or self.produce.waste then
					storage.fuelListTimer={value.time-1,value.fuel*self.powerFactor}
					power.produce(value.fuel*self.powerFactor/value.time)
					break
				end
			end
		end
	end
end