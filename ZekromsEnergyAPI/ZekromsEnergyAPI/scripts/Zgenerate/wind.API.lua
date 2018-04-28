require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor",1)
	storage.windClock=storage.windClock or -1
end

function update(dt)
	generate.wind(self.powerFactor)
	storage.windClock=(storage.windClock+1)%100
	if not world.breathable(entity.position())then	return	end
	if storage.windClock==0 then
		storage.wind=world.windLevel(entity.position())*self.powerFactor
	end
	return power.produce(storage.wind, self.dt)
end