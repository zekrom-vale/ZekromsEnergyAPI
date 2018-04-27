require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerAmount=config.getParameter("power.amount", 1)
end

function update(dt)
	generate.heat(self.powerAmount)
end

generate={}
function generate.heat(amount)
	storage.heatClock=((storage.heatClock or -1)+1)%10000
	if storage.heatClock==0 then
		for _,value in pairs(world.environmentStatusEffects(entity.position()))
			if value=="melting" or value=="burning" or value=="biomeheat" then
			--\stats\effects
				storage.heat=true
			end
		end
	end
	if storage.heat then
		local t=world.timeOfDay()
		return power.produce(amount*1.3*((-t+1)^(t-1)-.9))
	end
end