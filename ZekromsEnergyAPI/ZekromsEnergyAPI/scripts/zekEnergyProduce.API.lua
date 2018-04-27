require "/scripts/zekEnergy.API.lua"
generate={}
function generate.init()
	self.produce=config.getParameter("produce")
	self.produce={
		amount=self.produce.amount or 100,
		waste=self.produce.waste
	}
end