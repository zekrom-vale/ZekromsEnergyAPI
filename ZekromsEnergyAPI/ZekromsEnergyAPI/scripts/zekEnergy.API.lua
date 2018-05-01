power={}
function power.init()
	self.dt=script.updateDt()
	if self.dt==0 then
		sb.logWarn("Object missing scriptDelta")
		script.setUpdateDelta(60)
		self.dt==60
	end
	self.inputRate=config.getParameter("power.inputRate",100)--Defines the input rate per dt
	self.outputRate=config.getParameter("power.outputRate",100)--Defines the output rate per dt (Not used)
	self.maxBat=config.getParameter("power.maxBat",1000)--Max battery storage
	storage.energy=storage.energy or 0
end

function power.update(dt)
	--power.transfer.evalOut(dt)
	power.transfer.evalIn(dt)
end

function power.consume(amount,dt)--Consumes power if not, it returns false,energy
	amount=amount*(dt or 1)
	if storage.energy>=amount then
		storage.energy=storage.energy-amount
		return true
	end
	return false,storage.energy
end

function power.canConsume(amount,dt)--Checks if the object has enough power to consume if not, it returns false,energy
	amount=amount*(dt or 1)
	if storage.energy>=amount then
		return true,storage.energy-amount
	end
	return false,storage.energy
end

function power.produce(amount,dt)--Produces power of a given amount.  Returns true if successful and false,overflow if not.
	storage.energy=storage.energy+amount*(dt or 1)
	if storage.energy>self.maxBat then
		local overflow=storage.energy-self.maxBat
		storage.energy=self.maxBat
		return false,overflow
	end
	return true
end

function power.canProduce(amount,dt)--Determines if the object has enough space to produce
	local total=amount*(dt or 1)+storage.energy
	if total>self.maxBat then
		return false,total-self.maxBat
	end
	return true,total
end

--Not true eval functions
power.transfer={}
function power.transfer.evalOut(dt)--Transfers power out
	for index=1,object.outputNodeCount()do
		local node=object.getOutputNodeIds(index)
		for key,obj in pairs(node)do
			power.transfer.core(obj.id,self.outputRate*dt)
		end
	end
end

function power.transfer.evalIn(dt)--Transfers power in
	for index=1,object.inputNodeCount()do
		local node=object.getInputNodeIds(index)
		for key,obj in pairs(node)do
			power.transfer.core(obj.id,-self.inputRate*dt)
		end
	end
end

function power.transfer.core(id,amount)--Tries to transfer power between objects
	storage.energy=storage.energy-amount
	local val=world.callScriptedEntity(id,"power.transfer.Receive",amount)
	if val==0 then
		return true
	else
		storage.energy=storage.energy+val
		return false,val
	end
end

function power.transfer.Receive(amount)--Receives the transfer call
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

power.item={}
function power.item.charge(amount,range)--Charges items from range[1] to range[2]
	local id=entity.id()
	range=range or {1,world.containerSize(id)}
	stacks=world.containerItems(id)
	for key=range[1],range[2]do
		local stack=stacks[key]
		local maxBat=root.itemConfig(stack).config.maxBat
		if type(maxBat)~="number" then
			goto chargeEnd
		elseif stack.parameters==nil or stack.parameters.power==nil then
			stack.parameters={power=0,durabilityHit=maxBat}
		end
		local pow=stack.parameters.power+amount/stack.count
		if pow>maxBat then
			stack.parameters.power=maxBat-power.consumeAll(maxBat-stack.parameters.power)/stack.count
		else
			stack.parameters.power=pow-power.consumeAll(amount)/stack.count
		end
		stack.parameters.durabilityHit=maxBat-stack.parameters.power
		world.containerSwapItemsNoCombine(id,stack,key)
		::chargeEnd::
	end
end

function power.item.enervate(amount,range)--Discharges items from range[1] to range[2]
	local id=entity.id()
	range=range or {1,world.containerSize(id)}
	stacks=world.containerItems(id)
	for key=range[1],range[2]do
		local stack=stacks[key]
		if stack.parameters==nil or stack.parameters.power==nil then
			goto enervateEnd
		end
		local pow=stack.parameters.power-amount/stack.count
		if pow<0 then
			local _,overflow=power.produce(amount+pow*stack.count,1)
			stack.parameters.power=overflow/stack.count
		else
			local _,overflow=power.produce(amount,1)
			stack.parameters.power=pow*stack.count+overflow/stack.count
		end
		local maxBat=root.itemConfig(stack).config.maxBat
		if stack.parameters.power<=0 then
			stack.parameters.power=nil
			stack.parameters.durabilityHit=maxBat
		else
			stack.parameters.durabilityHit=maxBat-stack.parameters.power
		end
		world.containerSwapItemsNoCombine(id,stack,key)
		::enervateEnd::
	end
end

--[[function power.item.use(amount)
	--HOW!?
end]]

function power.consumeAll(amount,dt)--Consumes requested power or all of it.  Returns the underflow (positive) or 0,success
	dt=dt or 1
	local storage=storage
	storage.energy=storage.energy-amount*dt
	if storage.energy<0 then
		local pos=-storage.energy
		storage.energy=0
		return pos,false
	end
	return 0,true
end

function power.item.maxBat(item)--Returns the maxBat config of the item
	return root.itemConfig(item).config.maxBat
end

function power.item.valid(item)--Returns if the item is a valid power item
	if root.itemConfig(item).config.maxBat then
		return true
	end
	return false
end

function power.item.charge(item)--Returns the charge of the item, nil if parameters is nil and false if parameters.power is nil
	if item.parameters==nil then
		return
	end
	return item.parameters.power or false
end

--[[power.node={}
function power.node.transfer()
	local arr={}
	for index=1,object.outputNodeCount()do
		table.insert(arr,object.getOutputNodeIds(index))
	end
	return arr
end]]