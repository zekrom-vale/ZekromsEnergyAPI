require "/scripts/zekEnergy.API.lua"
function init()
	self.produce=config.getParameter("produce")
	self.produce={
		amount=self.produce.amount or 100,
		type=self.produce.type or "wind",
		waste=self.produce.waste
	}
end

generate={}
function generate.wind(factor)
	storage.windClock=((storage.windClock or -1)+1)%100
	if not world.breathable(entity.position()) then	return	end
	factor=factor or self.produce.amount
	if storage.windClock==0 then
		storage.wind=world.windLevel(entity.position())*factor
	end
	return power.produce(storage.wind, self.dt)
end

function generate.lightByTime(factor)
	factor=factor or self.produce.amount
	storage.light=storage.light or world.lightLevel(entity.position())
	storage.lightClock=((storage.lightClock or -1)+1)%1000000
	world.debugLine(vector, {vector[1], vector[2]+100}, "red")
	world.lineTileCollision(vector, {vector[1], vector[2]+100})
	if storage.lightClock%20000==0 then
		storage.lightClear=generate.lightVec2(entity.position(), {-25,25,5})
		if storage.lightClear then
			local p=storage.light*1.02327*3^(-3.4626*(2*world.timeOfDay()-1)^2)-0.04327
			if p<=0 then	return nil	end
			return power.produce(p,self.dt)
		end
	elseif storage.lightClear then
		if storage.lightClock==500000 then
			storage.light=math.max(storage.light,world.lightLevel(entity.position()))
		end
		local t=world.timeOfDay()
		if t<=0.0441 or t>=0.9559 then	return nil	end
		local p=storage.light*1.02327*3^(-3.4626*(2*t-1)^2)-0.04327
		return power.produce(p,self.dt)
	end
	--\frac{1}{\sqrt{\ 2\pi\left(\frac{39}{100}\right)^2}}\cdot3^{-\frac{\left(x-.5\right)^2}{2\left(\frac{19}{100}\right)^2}}-\frac{1}{50}
end

function generate.light(factor, height)
	storage.lightClock2=((storage.lightClock2 or -1)+1)%10000
	factor=factor or self.produce.amount
	local poz=entity.position()
	if not self.height and type(height)=="table" then
		if height==nil or next(height)==nil then	self.height=1
		else
			if height=="auto" then
				height={{1,500},{1.3,700},{1.6,900},{2,nil}}
			end
			for _,value in pairs(height) do
				if value[2]==nil or value>=poz[2] then
				self.height=value[1]
			end
		end
	end
	height=nil
	if not world.underground(poz) then
		if storage.clock==0 then	storage.light=world.lightLevel(poz)	end
		return power.produce(storage.light*self.height*factor, self.dt)
	end
end

function generate.lightVec2(vec,arr,max)
	max=max or 100
	for value=arr[1],arr[2],arr[3] or 1 do
		if world.lineTileCollision(vec, {vec[1]+value, vec[2]+max}) then	return true	end
	end
	return false
end

function generate.gravity(factor)
	if self.pozFactor==nil then
		self.pozFactor=(entity.position()[2]/5+.39)^(-10)-150
	end
	if self.pozFactor<=0 then	return	end
	storage.gravClock=((storage.gravClock or -1)+1)%1000000
	if storage.gravClock==0 then
		storage.gravity=world.gravity(entity.position())
	end
	return power.produce(storage.gravity*self.pozFactor*factor)
end

function generate.fuel(factor)
	local stacks=world.containerItems(entity.id())
	for _,stack in pairs(stacks) do
		local fuel=root.itemConfig(stack).config.fuel
		if type(fuel)=="number" and (power.canProduce(fuel*factor) or self.produce.waste) then
			return power.produce(fuel*factor)
		end
	end
end

function generate.fuelBurn(factor)
	local stacks=world.containerItems(entity.id())
	for _,stack in pairs(stacks) do
		local fuel=root.itemConfig(stack).config.fuelBurn
		if type(fuel)=="number" and (power.canProduce(fuel*factor) or self.produce.waste) then
			return power.produce(fuel*factor)
		end
	end
end

function generate.fuelList(factor)
	local stacks=world.containerItems(entity.id())
	local self=self
	if self.recipes==nil then
		self.recipes=root.assetJson(config.getParameter("fuelGen")) or {}
	end
	for _,stack in pairs(stacks) do
		for _,recipe in pairs(self.recipes)
			if stack.name==value.name then
				if power.canProduce(value.fuel*factor) or self.produce.waste	then
					return power.produce(value.fuel*factor)
				else	return	end
			end
		end
	end
end

function generate.heat(amount)
	storage.heatClock=((storage.heatClock or -1)+1)%10000
	if storage.heatClock==0 then
		for _,value in pairs(world.environmentStatusEffects(entity.position()))
			if value=="melting" or value=="burning" or value=="biomeheat" then
			--C:\Program Files (x86)\Steam\steamapps\common\Starbound\XX+unpackedAssets\stats\effects
				storage.heat=true
			end
		end
	end
	if storage.heat then
		return power.produce(amount)
	end
end