require "/scripts/zekEnergy.API.lua"
generate={}
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 1)
	self.height=config.getParameter("power.height", {{1,500},{1.3,700},{1.6,900},{2,nil}})
	storage.light=world.lightLevel(entity.position())
	storage.lightClock=storage.lightClock or -1
	world.debugLine(vector, {vector[1], vector[2]+100}, "red")
end

function update(dt)
	generate.light(self.powerFactor)
end

function generate.lightByTime(factor)
	storage.lightClock=(storage.lightClock+1)%1000000
	if storage.lightClock%20000==0 then
		storage.lightClear=generate.lightVec2(entity.position(),{-25,25,5})
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

function generate.light(factor)
	storage.lightClock=(storage.lightClock+1)%1000000
	local poz=entity.position()
	if not world.underground(poz) then
		if storage.clock==0 then	storage.light=world.lightLevel(poz)	end
		return power.produce(storage.light*self.height*factor, self.dt)
	end
end

function generate.lightVec2(vec,arr,max)
	max=max or 100
	for value=table.unpack(arr)do
		if world.lineTileCollision(vec,{vec[1]+value,vec[2]+max}) then	return true	end
	end
	return false
end