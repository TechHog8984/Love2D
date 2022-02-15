function table.find(Table, Value)
    for I, V in next, Table do
        if type(V) ~= 'nil' and type(Value) ~= 'nil' and V == Value then
            return I, V;
        end;
    end;
end;
function table.remove(Table, Value)
    local index = (table.find(Table, Value));
    if type(index) ~= 'nil' then
        Table[index] = nil;
    end;
end;

local Class = {
	Window = {
		Middle = {},
		Width = 0,
		Height = 0,
	},
	Objects = {},
	Properties = {},
};

do --Object Properties 
	local Properties = Class.Properties;

	Properties.Default = {
		Name = {'string', 'Object'},
		Destroy = {'string', Class.DestroyObject},
	};
	Properties.Arc = {
		Drawmode = {'string', 'fill'},
		X = {'number', 30},
		Y = {'number', 30},
		Radius = {'number', 30},
		Angle1 = {'number', 35},
		Angle2 = {'number', 90},
		Segments = {'number', 3},
	};
end;

do --Class helper functions
	function Class.Color(R, G, B)
		return {R or 1, G or 1, B or 1, 1};
	end
	function Class.ColorRGB(R, G, B)
		return {(R / 255) or 1, (G / 255) or 1, (B / 255) or 1, 1};
	end

	function Class:IsColliding(Object1, Object2)
		local Object1X = Object1.X;
		local Object1Y = Object1.Y;

		local Object2X = Object2.X;
		local Object2Y = Object2.Y;

		local CollidingX = (Object1X + Object1.Width) > Object2X and (Object1X) < (Object2X + Object2.Width);
		local CollidingY = (Object1Y + Object1.Height) > Object2Y and (Object1Y) < (Object2Y + Object2.Height);

		return (CollidingX and CollidingY), CollidingX, CollidingY;
	end
	function Class:DoesObjectExist(Object)
		return type(Object) == 'table' and rawget(Object, '__exists') == true;
	end;

	function Class:UpdateWindow()
		if Class and Class.Graphics then
			if Class.Window and Class.Window.Middle then
				local Window = Class.Window;

				local Width, Height = Class.Graphics.getDimensions();
				Window.Width = Width;
				Window.Height = Height;

				local Middle = Window;
				Middle.X = Width / 2;
				Middle.Y = Height / 2;
			else
				return error('Failed to get Window [Class.Window]', 2);
			end;
		else
			return error('Failed to get Graphics, did you run the init function correctly [init(love)]?', 2);
		end;
	end;

	function Class:DestroyObject(Object)
		if Object and Class:DoesObjectExist(Object) then
			rawset(Object, '__exists', false);
			table.remove(Class.Objects, Object);
		end;
	end;
end;

local ObjectMetatable = {
	__tostring = function(Object)
		if Class:DoesObjectExist(Object) then
			return Object.Name or '[UNNAMED]';
		end;
	end,
	__index = function(Object, Index)
		if Class:DoesObjectExist(Object) and Class.Properties[Object] and rawget(Object, '__holder') then
			if Class.Properties[Object][Index] then
				return rawget(Object, '__holder')[Index];
			end;
		end;
	end,
	__newindex = function(Object, Index, Value)
		if Class:DoesObjectExist(Object) and Class.Properties[Object] and rawget(Object, '__holder') then
			local Properties = Class.Properties[Object][Index]
			if Properties and Properties[1] == type(Value) then
				rawset(Object, '__holder', Value);
				return true;
			else
				return error('Invalid type for ' .. tostring(Index), 2);
			end;
		end;
		return false;
	end,
}

function Class:CreateObject(Type, Info)
	local Object = {
		__graphicstype = Type,
		__exists = true,
		__holder = {},
	};

	setmetatable(Object, ObjectMetatable);

	for I, Property in next, Class.Properties.Default do
		Object[I] = Property[2];
	end;
	for I, V in next, Info do
		Object[I] = V;
	end;

	return Object;
end;

for Type, Properties in next, Class.Properties do
	if Type and Properties then
		Class[('Create') .. Type] = function(...)
			Class:CreateObject(Type, ...);
		end;
	end;
end;

function Class:Draw()
	if Class.Graphics and Class.Objects then
		for I, Object in next, Class.Objects do
			if Class:DoesObjectExist(Object) then
				for I, V in next, Object do
					print(I, V);
				end;
			end;
		end;
	end;
end;

function Class:init(love)
	if type(love) == 'table' then
		if love.graphics then
			Class.Graphics = love.graphics;

			Class:UpdateWindow();
		else
			return error('second argument (expected love) doesn\'t have graphics!', 2);
		end;
	else 
		return error('Expected love (a table) as second argument, got ' .. type(love), 2);
	end;
end;

return Class;
