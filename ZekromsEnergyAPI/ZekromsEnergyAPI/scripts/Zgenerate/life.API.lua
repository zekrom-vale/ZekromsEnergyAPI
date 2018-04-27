require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor", 2)
	self.radius=config.getParameter("power.radius", 8)
	self.tick=config.getParameter("power.tick", 8)
	self.kill=config.getParameter("power.kill", true)
end

function update(dt)
	generate.life(self.tick,self.powerFactor,self.radius)
end

generate={}
function generate.life(tick,factor,radius)
	generate.lifeGet(world.monsterQuery(entity.position(),radius),tick,factor)
	generate.lifeGet(world.npcQuery(entity.position(),radius),tick,factor)
end

function generate.lifeGet(arr,tick,factor)
	for _,a in pairs(arr) do
		local health=world.callScriptedEntity(a, "status.resource", "health")
		if health>tick then
			health=health-tick
			world.callScriptedEntity(a, "status.setResource", "health", health)
			return power.produce(tick*factor)
		elseif self.kill then
			world.callScriptedEntity(a, "status.setResource", "health", 0)
			return power.produce(tick*health)
		end
	end
end