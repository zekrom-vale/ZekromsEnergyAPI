require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 1)
end

function update(dt)
	generate.gravity(self.powerFactor)
end

generate={}
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