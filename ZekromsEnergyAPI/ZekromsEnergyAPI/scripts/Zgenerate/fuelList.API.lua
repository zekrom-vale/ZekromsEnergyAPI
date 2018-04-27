require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 1)
	self.recipes=root.assetJson(config.getParameter("fuelGen")) or {}
end

function update(dt)
	generate.fuelList(self.powerFactor)
end

generate={}
function generate.fuelList(factor)
	if next(self.recipes)==nil then	return	end
	if storage.fuelListTimer then
		storage.fuelListTimer[1]=storage.fuelListTimer[1]-1
		if storage.fuelListTimer[1]==0 then	storage.fuelListTimer=nil	end
		return power.produce(storage.fuelListTimer[2])
	end
	local stacks=world.containerItems(entity.id())
	local self=self
	for _,stack in pairs(stacks) do
		for _,recipe in pairs(self.recipes)
			if stack.name==value.name then
				if power.canProduce(value.fuel*factor) or self.produce.waste then
					storage.fuelListTimer={value.time-1,value.fuel*factor}
					return power.produce(value.fuel*factor/value.time)
				else
					return
				end
			end
		end
	end
end