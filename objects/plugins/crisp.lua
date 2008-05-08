--- an object to access crisps
-- a crisp is a variable that persists for the next request, and then gets removed -- unless explicitly prolonged
crisp = {
	init = function(self)
		event:addAfterListener("readSession", function() session.data.crisps = session.data.crisps or {} end)
		event:addStartListener("writeSession", function() self:clean() end)
	end,
	
	exists = function(self, name)
		return webylene.session.data.crisps[name]
	end,
	
	set = function(self, name, value, cleaner)
		webylene.session.data.crisps[name]={val=value, keep=true, cleaners={cleaner}}
	end,
	
	--- attach a function to be called when it's time to remove a crisp. function gets passed the crisp value.
	-- @param string crisp crisp name
	-- @param function func function name. func([crisp val], [crisp name]) will be called when it's time to delete the crisp.
	-- @return boolean 	 	  
	addCleaner = function(self, crisp, func)
		if webylene.session.data.crisps[name] and type(func)=="function" then
			table.insert(webylene.session.data.crisps[name].cleaners, func)
		else
			return nil
		end
		return self
		
	end,
	

	--- reset all cleaners associated with a crisp
	resetCleaners = function(self, crisp)
		if not webylene.session.data.crisps[name] then return false end
		webylene.session.data.crisps[name].cleaners={}
		return self
	end,
	
	--- retrieve crisp value	 	
	get = function (self, crisp)
		if webylene.session.data.crisps[name] then
			return webylene.session.data.crisps[name].val
		end
	end,
	
	 --- renew crisp -- make sure it won't get erased next time	
	renew = function(self, name, val)
		local crisp_table = webylene.session.data.crisps[name]
		if not crisp_table then
			return nil
		end
		if val then
			crisp_table.val = val
		end
			
		crisp_table.keep = true
		return self;
	end,
	
	--- renew all crisps
	renewAll = function(self)
		for name, crisp_table in pairs(webylene.session.data.crisps) do
			self:renew(name)
		end
		return self
	end,
	
	--- run in bootstrap to clean the crisps.
		  	 
	clean = function(self)
		print "CLEANING crisps"
		if not webylene.session.data.crisps then webylene.session.data.crisps = {} end
		local crisps = webylene.session.data.crisps
		
		for name, crisp in pairs(crisps) do
			if not crisp.keep then 
				for i, func  in ipairs(crisp.cleaners) do
					func(crisp.val, name)
				end
				if not crisp.keep then -- re-check, in case a cleaner decided to renew the crisp
					crisps[name] = nil
				end
			else
				crisp.keep=false
			end
		end
	end
}