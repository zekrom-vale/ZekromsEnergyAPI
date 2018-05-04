--Kills npc and monsters to create power
require "/scripts/zekEnergy.API.lua"
function init()
	power.init()
	self.powerFactor=config.getParameter("power.factor",2)--Power per HP
	self.npcPowerFactor=config.getParameter("power.npcPowerFactor",false)--Hurt NPCs?
	self.radius=config.getParameter("power.radius",8)--AOE
	self.tick=config.getParameter("power.tick",8)--Amount of HP to consume per dt
	self.kill=config.getParameter("power.kill",true)--Kill entities
end

function update(dt)
	local self,poz=self,entity.position()
	generate.lifeGet(world.monsterQuery(poz,self.radius),self.tick,self.powerFactor)
	if self.npcPowerFactor then
		generate.lifeGet(world.npcQuery(poz,self.radius),self.tick,self.npcPowerFactor)
	end
end

function generate.lifeGet(arr,tick,factor)
	for _,a in pairs(arr) do
		local health=world.callScriptedEntity(a,"status.resource","health")
		if health>tick then
			health=health-tick
			local _,consume=power.produce(tick*factor,1)
			world.callScriptedEntity(a,"status.setResource","health",consume/factor)
			return nil,consume
		elseif self.kill then
			local _,consume=power.produce(health*factor,1)
			world.callScriptedEntity(a,"status.setResource","health",consume/factor)
			return nil,consume
		end
	end
end