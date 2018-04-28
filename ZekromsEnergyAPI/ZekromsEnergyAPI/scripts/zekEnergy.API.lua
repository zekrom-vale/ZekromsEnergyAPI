power={}
function power.init()
	self.dt=config.getParameter("scriptDelta",nil)
	if not self.dt then
		script.setUpdateDelta(50)
		self.dt=50
	end
	self.inputRate=config.getParameter("power.inputRate",100)
	self.outputRate=config.getParameter("power.outputRate",100)
	self.maxBat=config.getParameter("power.maxBat",1000)
	storage.energy=storage.energy or 0
end

function power.update(dt)
	--power.transferEvalOut(dt)
	power.transferEvalIn(dt)
end

function power.consume(amount,dt)--Consumes power if not, it returns false,energy
	dt=dt or 1
	if storage.energy>=amount*dt then
		storage.energy=storage.energy-amount*dt
		return true
	end
	return false,storage.energy
end

function power.canConsume(amount,dt)--Checks if the object has enough power to consume if not, it returns false,energy
	dt=dt or 1
	if storage.energy>=amount*dt then
		return true,storage.energy-amount*dt
	end
	return false,storage.energy
end

function power.produce(amount,dt)--Produces power of a given amount.  Returns true if successful and false,overflow if not.
	dt=dt or 1
	storage.energy=storage.energy+amount*dt
	if storage.energy>self.maxBat then
		local overflow=storage.energy-self.maxBat
		storage.energy=self.maxBat
		return false,overflow
	end
	return true
end

function power.canProduce(amount,dt)--Determines if the object has enough space to produce
	dt=dt or 1
	local total=amount*dt+storage.energy
	if total>self.maxBat then
		return false,total-self.maxBat
	end
	return true,total
end

function power.transferEvalOut(dt)--Transfers power out
	for index=1,object.outputNodeCount()do
		local node=object.getOutputNodeIds(index)
		for key,obj in pairs(node)do
			power.transfer(obj.id,self.outputRate*dt)
		end
	end
end

function power.transferEvalIn(dt)--Transfers power in
	for index=1,object.inputNodeCount()do
		local node=object.getInputNodeIds(index)
		for key,obj in pairs(node)do
			power.transfer(obj.id,-self.inputRate*dt)
		end
	end
end

function power.transfer(id, amount)--Tries to transfer power between objects
	storage.energy=storage.energy-amount
	local val=world.callScriptedEntity(id,"power.transferReceive",amount)
	if val==0 then
		return true
	else
		storage.energy=storage.energy+val
		return false,val
	end
end

function power.transferReceive(amount)--Receives the transfer call
	local storage=storage
	storage.energy=storage.energy+amount
	if storage.energy<0 then
		--Underflow	Amount is negative/Consume
		local energy=storage.energy
		storage.energy=0
	elseif storage.energy>self.maxBat then
		--Overflow	Amount is positive/Send
		local energy=self.maxBat-storage.energy
		storage.energy=self.maxBat
	else
		return 0
	end
	return energy
end

function power.charge(amount)--Charges all items in the inventory
	local id=entity.id()
	stacks=world.containerItems(id)
	for key,stack in pairs(stacks)do
		local maxBat=root.itemConfig(stack).config.maxBat
		local pow=stack.parameters.power+amount/stack.count
		if pow>maxBat then
			stack.parameters.power=maxBat+power.consumeAll(maxBat-stack.parameters.power)
		else
			stack.parameters.power=pow+power.consumeAll(amount)
		end
		world.containerSwapItemsNoCombine(id,stack,key)
	end
end

function power.consumeAll(amount,dt)--Consumes requested power or all of it.  Returns the underflow (negative) or 0,success
	dt=dt or 1
	local storage=storage
	storage.energy=storage.energy-amount*dt
	if storage.energy<0 then
		local neg=storage.energy
		storage.energy=0
		return neg,false
	end
	return 0,true
end