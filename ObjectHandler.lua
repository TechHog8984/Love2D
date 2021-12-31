local Class = {
	Objects = {},
}

local function TableAdd(...)
	local Result = {}

	for I, Table in next, ({...}) do
		for I, V in next, Table do
			table.insert(Result, V)
		end
	end

	return Result
end
local function TableAddIndex(...)
	local Result = {}

	for I, Table in next, ({...}) do
		for I, V in next, Table do
			Result[I] = V
		end
	end

	return Result
end

Class.BaseObjectMetatable = {
	__tostring = function(self)
		return self.Name
	end,
}

do --helper / info functions
	function Class:IsColliding(o1, o2)
		local CollidingX = (o1.X + o1.Width) > o2.X and (o1.X) < (o2.X + o2.Width)
		local CollidingY = (o1.Y + o1.Height) > o2.Y and (o1.Y) < (o2.Y + o2.Height)

		return (CollidingX and CollidingY), CollidingX, CollidingY
	end
	function Class:Color(R, G, B, O)
		return {R or 1, G or 1, B or 1, O or 1}
	end
	function Class:ColorRGB(R, G, B, O)
		return {(R / 255) or 1, (G / 255) or 1, (B / 255) or 1, O or 1}
	end

	function Class:UpdateWindow()
		if self.Graphics then
			self.Window.Width, self.Window.Height = self.Graphics.getDimensions()

			self.Window.Middle.X = self.Window.Width / 2
			self.Window.Middle.Y = self.Window.Height / 2
		else
			error('Failed to get Graphics, did you run the init function correctly ( "Class:init(love)" )', 2)
		end
	end

	function Class:GetExpectedProperties(Name)
		if Name == 'Rectangle' then
			return [[
				<boolean> Fill 		=    true
				<boolean> Outline 	=   false

				<number> X =   0
				<number> Y =   0

				<number> Width 	=   0
				<number> Height = 	0
			]]
		end
	end
end

do --main object creation functions
	function Class:CreateObject(Type, Gargs, Info, Metatable)
		local Object = {
			__gtype = Type,
			__gargs = Gargs,
		}

		for I, V in next, Info do
			Object[I] = V
		end

		setmetatable(Object, TableAddIndex(Class.BaseObjectMetatable, Metatable or {}))

		table.insert(self.Objects, Object)

		return Object
	end

	function Class:CreateRectangle(info)
		if info then
			local Extras = {
				Name = info.Name or '[OH object]#' .. tostring(#self.Objects + 1),
				Color = info.Color or {1, 1, 1, 1},
				_x = info.X or 0,
				_y = info.Y or 0,
				_width = info.Width or 0,
				_height = info.Height or 0,
			}

			for I, V in next, info do
				if I and type(I) == 'string' and I ~= 'Fill' and I ~= 'Outline' and I ~= 'X' and I ~= 'Y' and I ~= 'Width' and I ~= 'Height' then
					Extras[I] = V
				end
			end

			local Rectangle = self:CreateObject('rectangle', {
				(info.Fill and 'fill') or (info.Outline and 'line') or 'fill',
				info.X or 0,
				info.Y or 0,
				info.Width or 0,
				info.Height or 0,
			}, Extras, {
				__index = function(Self, Index)
					if Index == 'X' then
						return rawget(Self, '_x')
					elseif Index == 'Y' then
						return rawget(Self, '_y')
					elseif Index == 'Width' then
						return rawget(Self, '_width') 
					elseif Index == 'Height' then
						return rawget(Self, '_height')
					end

					return rawget(Self, Index)
				end,
				__newindex = function(Self, Index, Value)
					if Index == 'X' then
						rawset(Self, '_x', Value)
						return rawset(Self.__gargs, 2, Value)
					elseif Index == 'Y' then
						rawset(Self, '_y', Value)
						return rawset(Self.__gargs, 3, Value)
					elseif Index == 'Width' then
						rawset(Self, '_width', Value)
						return rawset(Self.__gargs, 4, Value)
					elseif Index == 'Height' then
						rawset(Self, '_height', Value)
						return rawset(Self.__gargs, 5, Value)
					end

					return rawset(Self, Index, Value)
				end
			})

			return Rectangle
		else
			error('CreateRectangle expects a table as the first, and only, argument. Try providing a table like Class:CreateRectangle{X = 1, Y = 5, ...}. See Class:GetExpectedProperties("Rectangle"). (Failed to get info table)', 2)
		end
	end
end

function Class:Draw()
	if self.Graphics then
		for I, Object in next, self.Objects do
			if Object and type(Object) == 'table' and rawget(Object, '__gtype') and rawget(Object, '__gargs') then
				self.Graphics.setColor(unpack(Object.Color))
				self.Graphics[rawget(Object, '__gtype')](unpack(rawget(Object, '__gargs')))
			else
				error('Failed to draw object, ensure object exists, is a table, has __gtype and has __gargs. (failed checks relating to the object existing itself and its properties)', 2)
			end
		end
	else
		error('Failed to get Graphics, did you run the init function correctly ( "Class:init(love)" )', 2)
	end
end


function Class:init(love)
	if love then
		if love.graphics then
			self.Graphics = love.graphics

			self.Window = {
				Middle = {},
			}

			self:UpdateWindow()
		else
			error('Class:init expects love, something with graphics. (failed to get love.graphics)', 2)
		end
	else
		error('Class:init expects love as the first argument. (failed to get love)', 2)
	end
end

return Class
