local gmatch = string.gmatch;
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
	Color = {
		Colors = {
			ForRandom = {},
		},
	},

	GraphicsArgs = {},
	GraphicTypes = {},
};

do --Class helper functions
	local Color = Class.Color;
	local Colors = Color.Colors;
	local ColorForRandom = Colors.ForRandom;
	
	function Color.new(R, G, B)
		local R,G,B = R or 0, G or 0, B or 0;
		return {R or 1, G or 1, B or 1, 1};
	end;
	function Color.fromRGB(R, G, B)
		local R,G,B = R or 0, G or 0, B or 0;
		return {(R / 255) or 1, (G / 255) or 1, (B / 255) or 1, 1};
	end;
	do --Color.Colors 
		Colors.White = Color.new(1, 1, 1);

		Colors.Red = Color.new(1, 0, 0);
		Colors.Green = Color.new(0, 1, 0);
		Colors.Blue = Color.new(0, 0, 1);

		Colors.Yellow = Color.new(1, 1, 0);
		Colors.Orange = Color.fromRGB(255, 140, 0);
		Colors.Magenta = Color.new(1, 0, 1);
		Colors.Purple = Color.fromRGB(138, 43, 226);

		Colors.Brown = Color.fromRGB(139, 69, 19);
		Colors.Cyan = Color.new(0, 1, 1);
		Colors.Gold = Color.fromRGB(255, 215, 0);
		Colors.Gray = Color.fromRGB(128, 128, 128);
		Colors.Pink = Color.fromRGB(255, 105, 180);

		for I, V in next, Colors do
			if type(I) == 'string' then
				Color[I] = V;
				table.insert(ColorForRandom, V);
			end;
		end;
	end;

	local CFRLength = #ColorForRandom

	function Color.randomBase()
		return ColorForRandom[math.random(1, CFRLength)];
	end;

	function Class:IsColliding(Object1, Object2)
		local Object1X = Object1.X;
		local Object1Y = Object1.Y;

		local Object2X = Object2.X;
		local Object2Y = Object2.Y;

		local CollidingX = (Object1X + Object1.Width) > Object2X and (Object1X) < (Object2X + Object2.Width);
		local CollidingY = (Object1Y + Object1.Height) > Object2Y and (Object1Y) < (Object2Y + Object2.Height);

		return (CollidingX and CollidingY), CollidingX, CollidingY;
	end;
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

				local Middle = Window.Middle;
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

	function Class:ValidType(TypeS, Value)
		local Type = type(Value);

		if Type then
			if Type == TypeS then
				return true;
			end;
			for X in gmatch(TypeS, '([^,]+)') do
				if X and tostring(X) and tostring(X) == Type then
					return true;
				end;
			end;
		end;
		return false;
	end;
end;

do --Object Properties & Graphics Args
	local Properties = Class.Properties;

	Properties.Default = {
		Name = {'string', 'Object'},
		Type = {'string', 'Object'},
		Destroy = {'function', Class.DestroyObject},
		Color = {'table', Class.Color.White},
	};
	Properties.Arc = {
		Name = {'string', 'Arc'},
		Type = {'string', 'Arc'},

		Drawmode = {'string', 'fill'},
		X = {'number', 30},
		Y = {'number', 30},
		Radius = {'number', 30},
		Angle1 = {'number', 20},
		Angle2 = {'number', 45},
		Segments = {'number,nil', nil},
	};
	Properties.Rectangle = {
		Name = {'string', 'Rectangle'},
		Type = {'string', 'Rectangle'},

		Drawmode = {'string', 'fill'},
		X = {'number', 50},
		Y = {'number', 70},
		Width = {'number', 50},
		Height = {'number', 70},
		XCornerRadius = {'number,nil', nil},
		YCornerRadius = {'number,nil', nil},
		Segments = {'number,nil', nil},
	};
	Properties.Circle = {
		Name = {'string', 'Circle'},
		Type = {'string', 'Circle'},

		Drawmode = {'string', 'fill'},
		X = {'number', 45},
		Y = {'number', 45},
		Radius = {'number', 45},
		Segments = {'number,nil', nil},
	};
	Properties.Ellipse = {
		Name = {'string', 'Ellipse'},
		Type = {'string', 'Ellipse'},

		Drawmode = {'string', 'fill'},
		X = {'number', 30},
		Y = {'number', 50},
		RadiusX = {'number', 30},
		RadiusY = {'number', 50},
		Segments = {'number,nil', nil};
	};
	Properties.Line = {
		Name = {'string', 'Line'},
		Type = {'string', 'Line'},

		X1 = {'number', 100},
		Y1 = {'number', 100},
		X2 = {'number', 130},
		Y2 = {'number', 130},

		Width = {'number,nil', nil},
		Style = {'string,nil', nil},
	};
	Properties.Point = {
		Name = {'string', 'Point'},
		Type = {'string', 'Point'},

		X = {'number', 100},
		Y = {'number', 100},
		Size = {'number,nil', nil},
	};
	Properties.Quad = {
		Name = {'string', 'Quad'},
		Type = {'string', 'Quad'},

		Drawmode = {'string', 'fill'},
		X1 = {'number', 90},
		Y1 = {'number', 90},
		X2 = {'number', 130},
		Y2 = {'number', 90},
		X3 = {'number', 130},
		Y3 = {'number', 30},
		X4 = {'number', 90},
		Y4 = {'number', 30},
	};
	Properties.Triangle = {
		Name = {'string', 'Triangle'},
		Type = {'string', 'Triangle'},

		Drawmode = {'string', 'fill'},
		X1 = {'number', 90},
		Y1 = {'number', 90},
		X2 = {'number', 130},
		Y2 = {'number', 90},
		X3 = {'number', 130},
		Y3 = {'number', 30},
	};

	local GArgs = Class.GraphicsArgs;
	GArgs.Arc = {
		Drawmode = 1,
		X = 2,
		Y = 3,
		Radius = 4,
		Angle1 = 5,
		Angle2 = 6,
		Segments = 7,
	};
	GArgs.Rectangle = {
		Drawmode = 1,
		X = 2,
		Y = 3,
		Width = 4,
		Height = 5,
		XCornerRadius = 6,
		YCornerRadius = 7,
		Segments = 8,
	};
	GArgs.Circle = {
		Drawmode = 1,
		X = 2,
		Y = 3,
		Radius = 4,
		Segments = 5,
	};
	GArgs.Ellipse = {
		Drawmode = 1,
		X = 2,
		Y = 3,
		RadiusX = 4,
		RadiusY = 5,
		Segments = 6,
	};
	GArgs.Line = {
		X1 = 1,
		Y1 = 2,
		X2 = 3,
		Y2 = 4,
	};
	GArgs.Point = {
		X = 1,
		Y = 2,
	};
	GArgs.Quad = {
		Drawmode = 1,
		X1 = 2,
		Y1 = 3,
		X2 = 4,
		Y2 = 5,
		X3 = 6,
		Y3 = 7,
		X4 = 8,
		Y4 = 9,
	};
	GArgs.Triangle = {
		Drawmode = 1,
		X1 = 2,
		Y1 = 3,
		X2 = 4,
		Y2 = 5,
		X3 = 6,
		Y3 = 7,
	};

	local GTypes = Class.GraphicTypes;
	GTypes['Point'] = 'points';
	GTypes['Quad'] = 'polygon';
	GTypes['Triangle'] = 'polygon';
end;

local ObjectMetatable = {
	__tostring = function(Object)
		if Class:DoesObjectExist(Object) then
			return Object.Name or '[UNNAMED]';
		end;
	end,
	__index = function(Object, Index)
		local Type = rawget(Object, '__type')
		if Class:DoesObjectExist(Object) and (Type and (Class.Properties.Default[Index] or (Class.Properties[Type] and Class.Properties[Type][Index]))) and rawget(Object, '__holder') then
			-- print(Index, rawget(Object, '__holder')[Index]);
			return rawget(Object, '__holder')[Index];
		end;
	end,
	__newindex = function(Object, Index, Value)
		local Type = rawget(Object, '__type')
		if Class:DoesObjectExist(Object) and (Type and (Class.Properties.Default[Index] or (Class.Properties[Type] and Class.Properties[Type][Index]))) and rawget(Object, '__holder') then
			local Properties = (Class.Properties.Default[Index] or (Class.Properties[Type] and Class.Properties[Type][Index]))
			if Properties and Class:ValidType(Properties[1], Value) then
				rawget(Object, '__holder')[Index] = Value;
				-- print(Index, rawget(Object, '__holder')[Index]);
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
		__type = Type,
		__graphicstype = Class.GraphicTypes[Type] or Type:lower(),
		__exists = true,
		__holder = {},
	};

	setmetatable(Object, ObjectMetatable);

	for I, Property in next, Class.Properties.Default do
		Object[I] = Property[2];
	end;
	for I, Property in next, Class.Properties[Type] do
		Object[I] = Property[2];
	end;
	for I, V in next, Info do
		Object[I] = V;
	end;

	table.insert(Class.Objects, Object);

	return Object;
end;

for Type, Properties in next, Class.Properties do
	if Type and Properties then
		Class[('Create') .. Type] = function(...)
			return Class:CreateObject(Type, select(2, ...));
		end;
	end;
end;

--Did a bit of procastinating and decided to document something
--Draw function: actually draws the objects to the screen
function Class:Draw()
	if Class.Graphics and Class.Objects then
		for I, Object in next, Class.Objects do
			if Class:DoesObjectExist(Object) then
				--Get the holder, since you can't loop through the actual object.
				local Holder = rawget(Object, '__holder');
				--GraphicsArgs contains the order that the properties should go in, since the draw function just takes the arguments passed through the function
				local GArgs = Class.GraphicsArgs[Object.Type];
				--Make a table to hold all of the properties in the correct order
				local Args = {};
				--Loop through the holder to get all of the properties
				for Index, Value in next, Holder do
					if type(Index) ~= nil and type(Value) ~= nil then
						--Check if the property is found in the GraphicsArgs table.
						--Only the properties that should be passed through the draw function will be in the table
						if GArgs[Index] then
							--GArgs[Index] will be the index, or place in the order, that the property should be at 
							--If the draw function was love.graphics.object and it took a string, "cool", a number, "x", and a number, "y", as the first, second, and third parameters, "cool" would be 1, "x" would be 2, and so on
							--This makes sure that the properties go in the right order
							Args[GArgs[Index]] = Value;
						end;
					end;
				end;

				--Set the color using the built-in function
				Class.Graphics.setColor(unpack(Object.Color));
				do --Set extra info, such as line width and point size
					if Object.Type == 'Line' then
						if Object.Width then
							Class.Graphics.setLineWidth(Object.Width);
						end;
						if Object.Style then
							Class.Graphics.setLineStyle(Object.Style);
						end;
					end;
					if Object.Type == 'Point' and Object.Size then
						Class.Graphics.setPointSize(Object.Size);
					end;
				end;
				--Call the built-in function for drawing the object with the args unpacked from the Args table
				Class.Graphics[rawget(Object, '__graphicstype')](unpack(Args));
			end;
		end;
	end;
end;

function Class:init(love)
	if type(love) == 'table' then
		if love.graphics then
			Class.Graphics = love.graphics;

			Class:UpdateWindow();
			math.randomseed(os.time());
		else
			return error('second argument (expected love) doesn\'t have graphics!', 2);
		end;
	else 
		return error('Expected love (a table) as second argument, got ' .. type(love), 2);
	end;
end;

return Class;
