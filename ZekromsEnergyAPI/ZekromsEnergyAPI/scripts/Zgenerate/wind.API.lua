require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 1)
	storage.windClock=storage.windClock or 0
end

function update(dt)
	generate.wind(self.powerFactor)
end

generate={}
function generate.wind(factor)
	storage.windClock=(storage.windClock+1)%100
	if not world.breathable(entity.position()) then	return	end
	factor=factor or self.produce.amount
	if storage.windClock==0 then
		storage.wind=world.windLevel(entity.position())*factor
	end
	return power.produce(storage.wind, self.dt)
end