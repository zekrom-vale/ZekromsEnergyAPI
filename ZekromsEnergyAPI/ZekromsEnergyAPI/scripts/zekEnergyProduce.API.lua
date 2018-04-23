require "/scripts/zekEnergy.API.lua"
function init()
	self.produce=config.getParameter("produce")
	self.produce={
		amount=self.produce.amount or 100,
		type=self.produce.type or "wind",
		waste=self.produce.waste
	}
end

--world.gravity(`Vec2F` position)
--world.environmentStatusEffects(`Vec2F` position)

generate={}
function generate.wind(factor)
	factor=factor or self.produce.amount
	return power.produce(world.windLevel(entity.position())*factor, self.dt)
end

function generate.light(factor)
	storage.light=storage.light or world.lightLevel(entity.position())
	storage.lightClock=((storage.lightClock or 0)+1)%10000
	world.debugLine(vector, {vector[1], vector[2]+100}, "red")
	world.lineTileCollision(vector, {vector[1], vector[2]+100}
	if storage.lightClock==0 then
		storage.lightClear=lightVec2(entity.position(), {-25,25,5})
		if storage.lightClear then
			local p=storage.light*1.02327*3^(-3.4626*(2*world.timeOfDay()-1)^2)-0.04327
			if p<=0 then	return nil	end
			return power.produce(p,self.dt)
		end
	elseif storage.lightClear then
		if storage.lightClock==5000 then
			storage.light=world.lightLevel(entity.position())--??
			sb.logInfo(tostring(storage.light))
		end
		local t=world.timeOfDay()
		if t<=0.0441 or t>=0.9559 then	return nil	end
		local p=storage.light*1.02327*3^(-3.4626*(2*t-1)^2)-0.04327
		return power.produce(p,self.dt)
	end
	--\frac{1}{\sqrt{\ 2\pi\left(\frac{39}{100}\right)^2}}\cdot3^{-\frac{\left(x-.5\right)^2}{2\left(\frac{19}{100}\right)^2}}-\frac{1}{50}
	--[[storage.clock=((storage.clock or 0)+1)%100
	factor=factor or self.produce.amount
	local poz=entity.position()
	if not world.underground(poz) then
		local worldTime=world.timeOfDay()
		if worldTime>=0.25 and worldTime<=0.75 then
			if storage.clock==0 then
				storage.light=world.lightLevel(poz)
			end
			return power.produce(storage.light*factor, self.dt)
		else
			return power.produce(storage.light*factor/10, self.dt)
		end
	end]]
end

function lightVec2(vec,arr,max)
	max=max or 100
	for value=arr[1],arr[2],arr[3] or 1 do
		if world.lineTileCollision(vec, {vec[1]+value, vec[2]+max}) then	return true	end
	end
	return false
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