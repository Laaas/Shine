--[[
	Basic table streams.
]]

local setmetatable = setmetatable
local TableRemove = table.remove
local TableSort = table.sort

local Stream = {}
Stream.__index = Stream

function Stream:Init( Table )
	self.Data = Table
	self.Operations = {}

	return self
end

--[[
	Filters the stream based on the given predicate function.

	Any value for which the predicate returns false will be removed.
]]
function Stream:Reduce( Predicate )
	for i = #self.Data, 1, -1 do
		if not Predicate( self.Data[ i ] ) then
			TableRemove( self.Data, i )
		end
	end

	return self
end

--[[
	Maps the values of the stream using the given Mapper function.

	All values in the stream are replaced with what the mapper function returns for them.
]]
function Stream:Map( Mapper )
	for i = 1, #self.Data do
		self.Data[ i ] = Mapper( self.Data[ i ] )
	end

	return self
end

--[[
	Sorts the values in the stream with the given comparator, or nil for natural order.
]]
function Stream:Sort( Comparator )
	TableSort( self.Data, Comparator )

	return self
end

--[[
	Returns the current table of data for the stream.
]]
function Stream:AsTable()
	return self.Data
end

function Shine.Stream( Table )
	return setmetatable( {}, Stream ):Init( Table )
end
