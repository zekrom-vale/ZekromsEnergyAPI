power={}

function power.init()
	self.dt=config.getParameter("scriptDelta", nil)
	if self.dt==nil then
		script.setUpdateDelta(50)
		self.dt=50
	end
	--self.adjacent=config.getParameter("adjacent", false)
	self.inputRate=config.getParameter("inputRate")
	self.outputRate=config.getParameter("outputRate")
	if storage.energy==nil then
		storage.energy=0
	end
end

function power.update(dt)
	--power.transferEvalOut(dt)
	power.transferEvalIn(dt)
end

function power.consume(amount, dt)
	if storage.energy>=amount*dt
		storage.energy=storage.energy-amount*dt
		return true
	end
	return false
end

function power.produce(amount, dt)
	storage.energy=storage.energy+amount*dt
	if storage.energy>self.maxBat then
		storage.energy=self.maxBat
		return false
	end
	return true
end

function power.transferEvalOut(dt)
	--[[if self.adjacent then
	world.entityQuery(object.position(), Radius)
		object.boundBox()
		for 
	end]]
	for index=0,object.outputNodeCount() do
		local node=object.getOutputNodeIds(index)
		for key,obj in pairs(node) do
			power.transfer(obj.id, self.outputRate*dt)
		end
	end
end

function power.transferEvalIn(dt)
	for index=0,object.inputNodeCount() do
		local node=object.getInputNodeIds(index)
		for key,obj in pairs(node) do
			power.transfer(obj.id, -self.inputRate*dt)
		end
	end
end

function power.transfer(id, amount)
	storage.energy=storage.energy-amount
	local val=world.callScriptedEntity(id, "power.transferReceive", amount)
	if val==0 then
		return true
	else
		storage.energy=storage.energy+val
		return false
	end
end

function power.transferReceive(amount)
	storage.energy=storage.energy+amount
	if storage.energy<0 then
		--Underflow	Amount is negative/ Consume
		local energy=storage.energy
		storage.energy=0
		return energy --Neg
	end
	if storage.energy>self.maxBat then
		--Overflow	Amount is positive/ Send
		local energy=self.maxBat-storage.energy
		storage.energy=self.maxBat
		return energy --Pos
	end
	return 0
end
