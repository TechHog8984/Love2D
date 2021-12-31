local Class = {
	Objects = {},
}

Class.BaseObjectMetatable = {
	__tostring = function(self)
		return self.Name
	end,
}

function Class:CreateObject(Type, Gargs, Info)
	local Object = {
		__gtype = Type,
		__gargs = Gargs,
	}

	for I, V in next, Info do
		Object[I] = V
	end

	setmetatable(Object, Class.BaseObjectMetatable)

	table.insert(self.Objects, Object)

	return Object
end

function Class:CreateRectangle(info)
	local Rectangle = self:CreateObject('rectangle', {
		(info.Fill and 'fill') or (info.Outline and 'line') or 'fill',
		info.X or 0,
		info.Y or 0,
		info.Width or 0,
		info.Height or 0,
	}, {
		Name = info.Name or '[OH object]#' .. tostring(#self.Objects + 1)
		}
	)

	return Rectangle
end

function Class:Draw()
	if Class.Graphics then
		for I, Object in next, self.Objects do
			if Object and type(Object) == 'table' and rawget(Object, '__gtype') and rawget(Object, '__gargs') then
				Class.Graphics[rawget(Object, '__gtype')](unpack(Object, '__gargs'))
			end
		end
	else
		error('Failed to get Graphics, did you run the init function correctly ( "Class:init(love)" )', 2)
	end
end

function Class:init(love)
	if love then
		Class.Graphics = love.graphics
	else
		error('Class:init expects love as the first argument.', 2)
	end
end

return Class