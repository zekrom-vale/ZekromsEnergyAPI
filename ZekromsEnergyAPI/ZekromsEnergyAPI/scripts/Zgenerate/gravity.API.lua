--Generates power based on gravity and y-level
require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor",.07)--Power generated per G
	storage.gravClock=storage.gravClock or -1
	self.pozFactor=(entity.position()[2]/5+.39)^-10-150
end

function update(dt)
	if self.pozFactor<=0 then	return	end
	storage.gravClock=(storage.gravClock+1)%1000000
	if storage.gravClock==0 then
		storage.gravity=world.gravity(entity.position())
	end
	return power.produce(storage.gravity*self.pozFactor*self.powerFactor)
end