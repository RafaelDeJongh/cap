if(MMatrix == nil) then
   --#########################################
   --						Linear algebra Matrix Class v.0.1
   --						by aVoN aka System of a pWne!^
   --#########################################

   /*
   	Linear algebra Matrix Class v.0.1
   	Copyright (C) 2007  aVoN

   	This program is free software: you can redistribute it and/or modify
   	it under the terms of the GNU General Public License as published by
   	the Free Software Foundation, either version 3 of the License, or
   	(at your option) any later version.

   	This program is distributed in the hope that it will be useful,
   	but WITHOUT ANY WARRANTY; without even the implied warranty of
   	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   	GNU General Public License for more details.

   	You should have received a copy of the GNU General Public License
   	along with this program.  If not, see <http://www.gnu.org/licenses/>.
   */

   -- ################# USAGE
   --[[
   You simply create a new Matrix by either calling
   A = MMatrix:New(3,2,
   	1,2,
   	3,4,
   	5,6,
   );
   or much simplier:
   A = MMatrix(3,2,
   	1,2,
   	3,4,
   	5,6,
   );
   The first two parameters define the size. First stands for lines, second for columns

   Matrices can be used like on the paper: A and B are both matrices in the examples
   ### http://en.wikipedia.org/wiki/Matrix_addition
   ADD = A+B; -- Alias: A:Add(B);
   SUB = A-B -- Alias A:Sub(B)
   ### http://en.wikipedia.org/wiki/Matrix_multiplication
   MUL = A*B -- Alias: A:Multiply(B), A:Mul(B), A(B)
   MUL_NUMBER = 5*A -- Same like A*5 - Alias: A:Mul(5), A(5)
   MUL_VECTOR = A*Vector(1,2,3) -- Needs A to be a nX3 Matrix - Alias A:Mul(Vector(1,2,3)), A(Vector(1,2,3))
   UNARY_MINUS = -A -- Alias: -1*A or A*-1 A(-1)
   ### http://en.wikipedia.org/wiki/Matrix_exponential
   POW = A^13 -- Alias A:Pow(13);

   --Special functions
   ### http://en.wikipedia.org/wiki/Trace_%28linear_algebra%29
   TRACE = A:Trace();
   ### http://en.wikipedia.org/wiki/Transpose
   TRANSPOSE = A:Transpose() -- Alias: A:Trans() or A^t or A^T or A^"t" or A^"T"
   ### http://en.wikipedia.org/wiki/Determinant
   DETERMINANT = A:Determinant() -- Alias: A:Det();
   ### http://en.wikipedia.org/wiki/Inverse_matrix
   INVERT = A:Invert() -- Alias: A^-1,A:Inv();
   ### http://en.wikipedia.org/wiki/Adjugate
   ADJUGATE = A:Adjugate() -- Alias: A:Adj();
   ### Strokes a line or column of the Matrix and returns the rest. Leaving an argument empty (nil) or set it to 0 won't stroke that line or column. Mostly internally used
   STROKE = A:Stroke(line,column)

   -- Related functions
   -- Creates a generally 3D rotation matrix, which can be used on any given vector
   ROTATION_MATRIX = MMatrix.RotationMatrix(vector [Vector/MMatrix],angle [float]) -- Alias: MyMatrix:RotationMatrix(angle) where MyMatrix is a 3x1 vector
   -- The Euler rotation matrix creates a Matrix which will rotate any vector according to the Euler pitch,yaw,roll angles given (Works like setting an Entities Angle, but for Vectors)
   EULER_ROTATION_MATRIX = MMatrix.EulerRotationMatrix(pitch,yaw,roll)
   --]]
   MMatrix = {};
   setmetatable(MMatrix,{__call = function(t,...) return t:New(unpack(arg)) end});

   -- ################# Matrix constructor @aVoN
   function MMatrix:New(m,n,...)
   	local t = {}
   	self.__index = self;
   	self.__add = self.Add;
   	self.__sub = self.Sub;
   	self.__mul = self.Multiply;
   	self.__div = self.Divide;
   	self.__pow = self.Pow;
   	self.__unm = function() return self:Multiply(-1) end;
   	-- Check if a matrix is the same - DOES NOT CHECK FOR SIMILARITY!
   	self.__eq = function(m1,m2)
   			if(not(self.__IsMatrix(m1) or self.__IsMatrix(m2))) then return false end;
   			if(not (m1.size[1] == m2.size[1] and m1.size[2] == m2.size[2])) then return false end;
   			for line=1,m1.size[1] do
   				for column=1,m1.size[2] do
   					if(m1.matrix[line][column] ~= m2.matrix[line][column]) then return false end;
   				end
   			end
   			return true;
   		end;
   	self.__call = function(t,M) return t:Multiply(M) end;
   	--self.__len = function(t) return t.size[1],t.size[2] end; -- Returns the "length" of a matrix with # operator (Doesn't seems to work, sorry)
   	setmetatable(t,self);
   	t.size = {m or 0,n or 0};
   	t.matrix = {};
   	local index = 1;
   	for line=1,m or 0 do
   		t.matrix[line] = {};
   		for column=1,n or 0 do
   			local arg = {...}
   			t.matrix[line][column] = arg[index] or 0; -- Arg are the arguments, feeded after MMatrix:New(m,n,...) in the ...
   			index = index + 1;
   		end
   	end
   	return t;
   end

   -- ################# Copies a matrix and returns a new one @aVoN
   function MMatrix:Copy()
   	local args = {};
   	for line=1,self.size[1] do
   		for column=1,self.size[2] do
   			table.insert(args,self.matrix[line][column]);
   		end
   	end
   	return MMatrix:New(self.size[1],self.size[2],unpack(args));
   end

   -- ################# Adds a matrix to another @aVoN
   --http://en.wikipedia.org/wiki/Matrix_addition
   function MMatrix:Add(m)
   	if(not (self and self.matrix)) then MMatrix.__error(0,{1,"MMatrix.Add","MMatrix",self}) return end;
   	if(not (m and m.matrix)) then MMatrix.__error(0,{2,"MMatrix.Add","MMatrix",m}) return end;
   	return self:__AddAndSubstract(m,1);
   end

   -- ################# Subtracts a matrix from another @aVoN
   --http://en.wikipedia.org/wiki/Matrix_addition
   function MMatrix:Sub(m)
   	if(not MMatrix.__IsMatrix(self)) then MMatrix.__error(0,{1,"MMatrix.Sub","MMatrix",self}) return end;
   	if(not MMatrix.__IsMatrix(m)) then MMatrix.__error(0,{2,"MMatrix.Sub","MMatrix",m}) return end;
   	return self:__AddAndSubstract(m,-1);
   end

   -- #################  For internal usage only - Handles add and substract in one function @aVoN
   function MMatrix:__AddAndSubstract(m,sign)
   	local args = {};
   	for line=1,self.size[1] do
   		for column=1,self.size[2] do
   			table.insert(args,self.matrix[line][column] + sign*m.matrix[line][column]);
   		end
   	end
   	return MMatrix:New(m.size[1],m.size[2],unpack(args));
   end

   -- #################  For internal usage only - Is it a valid Matrix? @aVoN
   function MMatrix.__IsMatrix(m)
   	if(type(m) == "table" and m.matrix) then return true end;
   	return false;
   end

   -- ################# Multiply a matrix @aVoN
   --http://en.wikipedia.org/wiki/Matrix_multiplication
   function MMatrix:Multiply(m)
   	if(MMatrix.__IsMatrix(self)) then -- First argument is a Matrix
   		if(type(m) == "number") then -- Numerical multiply
   			local args = {};
   			for line=1,self.size[1] do
   				for column=1,self.size[2] do
   					table.insert(args,self.matrix[line][column]*m);
   				end
   			end
   			return MMatrix:New(self.size[1],self.size[2],unpack(args));
   		elseif(type(m) == "Vector") then -- Gmod 10 vector does only know 3D vectors
   			if(self.size[2] == 3) then
   				local new_vector = {};
   				for line=1,self.size[1] do
   					new_vector[line] = self.matrix[line][1]*m.x + self.matrix[line][2]*m.y + self.matrix[line][3]*m.z
   				end
   				if(#new_vector == 3) then -- It's a 3D vector
   					return Vector(unpack(new_vector));
   				else -- It's dimension is either greater or smaller than 3, so create a new matrix object
   					return MMatrix:New(self.size[1],1,unpack(new_vector));
   				end
   			end
   			MMatrix.__error(2,{1,"MMatrix.Multiply",3,self.size[2]}); -- Column count isn't 3 for the matrix (a GM9 vector always is a 3D vector)
   		elseif(MMatrix.__IsMatrix(m)) then -- It's a matrix - Either perform a Matrix or Dyadic product (http://en.wikipedia.org/wiki/Dyadic_product)
   			if(self.size[2] == m.size[1]) then
   				local args = {};
   				for line=1,self.size[1] do
   					for your_column=1,m.size[2] do
   						local value = 0;
   						for my_column=1,self.size[2] do
   							value = value + self.matrix[line][my_column]*m.matrix[my_column][your_column]
   						end
   						table.insert(args,value);
   					end
   				end
   				return MMatrix:New(self.size[1],m.size[2],unpack(args));
   			end
   			MMatrix.__error(1,{2,"MMatrix.Multiply",self.size[2],m.size[1]}); -- Line count does not match
   			return;
   		end
   		MMatrix.__error(0,{2,"MMatrix.Multiply","MMatrix/number/Vector",self}); -- No valid datatype for multiply
   		return;
   	else -- Second argument is a Matrix
   		if(type(self) == "number") then
   			return MMatrix.Multiply(m,self);
   		elseif(type(self) == "Vector") then
   			-- ################# FIXME: It seems like, garrys mod's inbuild __multiply metatable for vectors is interfering here...
   		end
   	end
   	MMatrix.__error(0,{1,"MMatrix.Multiply","MMatrix/number/Vector",self}); -- No valid datatype for multiply
   end

   -- ################# Divide a matrix @aVoN
   function MMatrix:Divide(m)
   	if(type(m) == "number") then
   		if(m == 0) then
   			MMatrix.__error(-1,"MMatrix.Divide: Chuck Norris module not implemented - Can't devide by zero"); -- We need to fix this soon!!!
   			return;
   		end
   		return self:Multiply(1/m);
   	end
   	MMatrix.__error(0,{2,"MMatrix.Divide","number",m});
   end

   -- ################# Pow's a matrix @aVoN
   --http://en.wikipedia.org/wiki/Matrix_exponential
   -- Define some global vars for tranpose
   if(not t) then t = "TRANSPOSE" end;
   if(not T) then T = "TRANSPOSE" end;
   function MMatrix:Pow(n)
   	if(type(n) == "number") then
   		if(self.size[1] == self.size[2]) then -- can only pow quadratic matrices
   			if(n == 1) then -- M^1 = nothing changed - Return self
   				return self;
   			elseif(n == -1) then -- Inver the matrix
   				return self:Invert();
   			elseif(n == 0) then -- Return a unitary matrix
   				local args = {};
   				for line=1,self.size[1] do
   					for column=1,self.size[2] do
   						local num = 0;
   						if(line == column) then
   							num = 1;
   						end
   						table.insert(args,num);
   					end
   				end
   				return MMatrix:New(self.size[1],self.size[2],unpack(args));
   			elseif(n > 0 and math.ceil(n) == n) then -- Only possible to pow a matrix by integers
   				local new_matrix = self:Copy(); -- We first need a copy of the matrix
   				for i=1,n-1 do
   					new_matrix = new_matrix*self;
   				end
   				return new_matrix;
   			elseif(n < -1) then
   				MMatrix.__error(-1,"MMatrix.Pow: you can't pow a matrix with values less than -1");
   			end
   			MMatrix.__error(-1,"MMatrix.Pow: argument #2 for power must be an integer. Got float");
   			return;
   		end
   		MMatrix.__error(-1,"MMatrix.Pow: can only power quadratic matrices");
   		return;
   	elseif(n == "t" or n =="T" or (t ~= nil and n == t) or (T ~= nil and n == T)) then -- Transpose matrix - But it's better to use MMatrix:Transpose() instead
   		return self:Transpose();
   	end
   	MMatrix.__error(0,{2,"MMatrix.Pow","number",n});
   end

   -- ################# Calculates the trace of a Matrix @aVoN
   function MMatrix:Trace()
   	if(self.size[1] ~= self.size[2]) then MMatrix.__error(-1,"MMatrix.Trace: can only calc the trace of a quadratic matrix") return end;
   	local trace = 0;
   	for line=1,self.size[1] do
   		trace = trace + self.matrix[line][line];
   	end
   	return trace;
   end

   -- ################# Inverts a matrix @aVoN
   --http://en.wikipedia.org/wiki/Inverse_matrix
   function MMatrix:Invert()
   	if(self.size[1] ~= self.size[2]) then MMatrix.__error(-1,"MMatrix.Invert: can't invert - matrix not quadratic") end;
   	-- To be honest, the Gauss-Jordan algorythm is faster .But I prefere the algo with the adjungated matrix, which seems to be easier to implement
   	local det = self:Determinant();
   	if(det ~= 0) then -- It can be inverted
   		return self:Adjugate()/det;
   	end
   	MMatrix.__error(-1,"MMatrix.Invert: Can't invert matrix - Has not full rank");
   end

   -- ################# Transposes a quadractic matrix @aVoN
   --http://en.wikipedia.org/wiki/Transpose
   function MMatrix:Transpose()
   	if(self.size[1] ~= self.size[2]) then MMatrix.__error(-1,"MMatrix.Transpose: can only transpose quadratic matrices") return end;
   	local args = {};
   	for line=1,self.size[1] do
   		for column=1,self.size[2] do
   			table.insert(args,self.matrix[column][line]);
   		end
   	end
   	return MMatrix:New(self.size[1],self.size[2],unpack(args));
   end

   -- ################# Adjugates a matrix @aVoN
   -- http://en.wikipedia.org/wiki/Adjugate
   function MMatrix:Adjugate()
   	local args = {};
   	for line=1,self.size[1] do
   		for column=1,self.size[2] do
   			local sgn = 1;
   			if((line+column)%2 == 1) then sgn = -1 end;
   			table.insert(args,sgn*self:Stroke(line,column):Determinant());
   		end
   	end
   	return MMatrix:New(self.size[1],self.size[2],unpack(args)):Transpose();
   end

   -- ################# Determinant of a matrix @aVoN
   --http://en.wikipedia.org/wiki/Determinant
   function MMatrix:Determinant()
   	if(self.size[1] ~= self.size[2]) then MMatrix.__error(-1,"MMatrix.Determinant: can only calc the determinant of a quadratic matrix") return end;
   	if(self.size[1] == 1) then
   		return self.matrix[1][1];
   	elseif(self.size[1] == 2) then
   		return self.matrix[1][1]*self.matrix[2][2]-self.matrix[1][2]*self.matrix[2][1];
   	else
   		-- For any greater matrices, we are using the Laplace-Algorythm with stroken matrices until we reached a 2x2 matrix
   		local determinant = 0;
   		for line=1,self.size[1] do
   			local sgn = 1; -- Signum of the position where we are currently developing the determinant by line
   			if(line%2 == 0) then sgn = -1 end;
   			determinant = determinant + self.matrix[line][1]*sgn*(self:Stroke(line,1):Determinant());
   		end
   		return determinant;
   	end
   end

   -- ################# Creates a stroken Matrix - When ll or cc is nil or 0, either the line and/or collumn isn't stroken @aVoN
   function MMatrix:Stroke(ll,cc)
   	local args = {};
   	for line=1,self.size[1] do
   		for column=1,self.size[2] do
   			if(ll ~= line and cc ~= column) then
   				table.insert(args,self.matrix[line][column]);
   			end
   		end
   	end
   	if(ll and ll ~= 0 and ll <= self.size[1]) then ll = 1 end;
   	if(cc and cc ~= 0 and cc <= self.size[2]) then cc = 1 end;
   	return MMatrix:New(self.size[1]-(ll or 0),self.size[2]-(cc or 0),unpack(args));
   end

   -- #################  Error handler @aVoN
   function MMatrix.__error(msg,data)
   	local str;
   	if(msg == -1) then -- Custom message
   		str = data;
   	elseif(msg == 0) then -- Datatype mismatch
   		str = "bad argument #"..data[1].." to '"..data[2].."' ("..data[3].." expected, got "..(type(data[4]) or "nil")..")";
   	elseif(msg == 1) then -- Line mismatch
   		str = "line count do no match for argument #"..data[1].." in '"..data[2].."' ("..data[3].." expected, got "..data[4]..")";
   	elseif(msg == 2) then -- Column mismatch
   		str = "column count do no match for argument #"..data[1].." in '"..data[2].."' ("..data[3].." expected, got "..data[4]..")";
   	end
   	str = str or "Unknown error in MMatrix object";
   	error(str);
   end

   -- ################# Creates a 3D rotation matrix around a given Axis and angle @aVoN
   function MMatrix.RotationMatrix(vector,angle)
   	local a; -- Axis to rotate around
   	-- Gmod10 Vector input
   	if(type(vector) == "Vector") then
   		a = {vector.x,vector.y,vector.z};
   	end
   	-- A Matrix with a linecount of 3 and column count of 1 == Vector
   	if(MMatrix.__IsMatrix(vector)) then
   		if(not(vector.size[1] == 3 and vector.size[2] == 1)) then MMatrix.__error(-1,"MMatrix.RotationMatrix: Got invalid MMatrix object. (expected 3x1, got "..vector.size[1].."x"..vector.size[2]..")") return end;
   		a = {vector.matrix[1][1],vector.matrix[2][1],vector.matrix[3][1]};
   	end
   	if(not a) then MMatrix.__error(0,{1,"MMatrix.RotationMatrix","MMatrix,Vector",vector}) return end;
   	-- Quick reference, to keep the code clear
   	local rad = math.rad(angle); -- Angle in radiant
   	-- To save perfromances, we aren't calculation the sinus and cosinus all the time again
   	local c = math.cos(rad);
   	local s = math.sin(rad);
   	-- Regulary rotation matrix
   	return MMatrix:New(3,3,
   		-- Line 1
   		(c+(1-c)*a[1]^2),
   		((1-c)*a[1]*a[2]-s*a[3]),
   		((1-c)*a[1]*a[3]+s*a[2]),
   		-- Line 2
   		((1-c)*a[2]*a[1]+s*a[3]),
   		(c+(1-c)*a[2]^2),
   		((1-c)*a[2]*a[3]-s*a[1]),
   		-- Line 3
   		((1-c)*a[1]*a[3]-s*a[2]),
   		((1-c)*a[3]*a[2]+s*a[1]),
   		(c+(1-c)*a[3]^2)
   	);
   end

   -- ################# 3D Euler Rotation matrix @aVoN
   function MMatrix.EulerRotationMatrix(pitch,yaw,roll)
   	--######### Yaw
   	local z = MMatrix:New(3,1,0,0,1);
   	local M = MMatrix.RotationMatrix(z,yaw)
   	--######### Pitch
   	local y = M*MMatrix:New(3,1,0,1,0);
   	M = MMatrix.RotationMatrix(y,pitch)*M;
   	--######### Roll
   	local x = M*MMatrix:New(3,1,1,0,0);
   	M = MMatrix.RotationMatrix(x,roll)*M
   	return M;
   end

   -- ################# ALIASES for Quick-Reference
   MMatrix.Det = MMatrix.Determinant;
   MMatrix.Adj = MMatrix.Adjugate;
   MMatrix.Trans = MMatrix.Transpose;
   MMatrix.Inv = MMatrix.Invert;
   MMatrix.Div = MMatrix.Divide;
   MMatrix.Mul = MMatrix.Multiply;
end
