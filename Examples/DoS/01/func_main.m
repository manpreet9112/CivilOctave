% Program to formulate global stiffness matrix
clc
clear

%input file
load input.mat

%function defintion for Stiffness matrix.
function Stiffness_matrix =stif(Stiffness_storey)
	Number_of_storeys=4;
	for  storey_i = 1:Number_of_storeys
  		Stiffness_matrix(storey_i, storey_i) = ...
    		Stiffness_storey(storey_i);
  		if (storey_i < Number_of_storeys )
    		Stiffness_matrix(storey_i, storey_i) = ...
     		Stiffness_matrix(storey_i, storey_i) + ...
      		Stiffness_storey(storey_i + 1);
    		Stiffness_matrix(storey_i, storey_i + 1) = ...
     		- Stiffness_storey(storey_i + 1);
    		Stiffness_matrix(storey_i + 1, storey_i) = ...
      		Stiffness_matrix(storey_i, storey_i + 1);
   		endif
	 end
end

%function defintion for level floor.
function Level_floor =levelf(Height_storey)
	Number_of_storey=4;
	for storey_i = 1 : Number_of_storey
  		Level_floor(storey_i, 1) = ...
    	Height_storey(storey_i,1);
  		if (storey_i>1)
     		Level_floor(storey_i, 1) = ...
       		Level_floor(storey_i, 1) + ...
     		Level_floor(storey_i - 1, 1);
 		 endif
	end
end


%Soil_type
Type_of_soil = '';

for i = 1:Soil_type
  Type_of_soil = strcat(Type_of_soil, 'I');
end

%Type_of_soil

%% Function to write Matrix

t1 = 0; t2 = 0; t3 = 0; t4 = 0; 
eq3num = 0;

function sag = funSaog(soilType, timePrd)
  t2 = 0.10;
  switch soilType
    case 'I' 
      t3 = 0.40; eq3num = 1.0;
    case 'II'
      t3 = 0.55; eq3num = 1.36;
    case 'III'
      t3 = 0.67; eq3num = 1.67;
    otherwise
      warning('Unexpected soil type')
  end
  if (timePrd < t2)
    sag = 1. + 15 * timePrd;  
  elseif (timePrd > t3)
    sag = eq3num / timePrd; 
  else
    sag = 2.5;
  end
end

function matrixTeX(A, fmt, align)
  disp(['\section{',strrep(inputname(1),'_',' '),'}'])
  [m,n] = size(A);
  if isvector(A)
    myMatrix = 'Bmatrix';
  else
    myMatrix = 'bmatrix';
  end
  if(nargin < 2)
    %
    % Is the matrix full of integers?
    % If so, then use integer output
    %
    if( norm(A-floor(A)) < eps )
      intA = 1;
      fmt  = '%d';
    else
      intA = 0;
      fmt  = '%8.4f';
    end
  end
  fmtstring1 = [' ',fmt,' & '];
  fmtstring2 = [' ',fmt,' \\\\ \n'];
  if(nargin < 3)
    printf('\\[\n\\begin{%s}\n',myMatrix);
  else
    printf('\\[\n\\begin{%s*}[%s]\n',myMatrix,align);
  endif  
  for i = 1:m
    for j = 1:n-1
       printf(fmtstring1,A(i,j));
    end
    printf(fmtstring2, A(i,n));
  end
  if(nargin < 3)
    printf('\\end{%s}\n\\]\n',myMatrix);
  else
    printf('\\end{%s*}\n\\]\n',myMatrix);
  endif  
end

%function calling
Stiffness_matrix=stif(Stiffness_storey);
disp(Stiffness_matrix);
level=levelf(Height_storey);
disp(level);

%function output in latex form
matrixTeX(Stiffness_matrix,'%10.4e','r');
matrixTeX(level,'%10.4e','r')


