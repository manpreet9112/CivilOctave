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

%function for Modal._mass, MOdal_contribution, Modal_participation_factor
function [Time_period, Frequency, Time_periods]= eigenomega(Stiffness_matrix, Mass)
Number_of_storeys=4;
[Eigen_vector, Omega_square] = eig(Stiffness_matrix, Mass);
Omega = sqrt(Omega_square);
	for storey_i = 1 : Number_of_storeys
	  Time_period(storey_i, storey_i) = 2 * pi() ...
	    / sqrt(Omega_square(storey_i, storey_i)); 
	end
	for storey_i = 1 : Number_of_storeys
	  Frequency(storey_i,1) = Omega(storey_i, storey_i);
	end
	for storey_i = 1 : Number_of_storeys
	  Time_periods(storey_i,1) = Time_period(storey_i, storey_i);
	end
end

function [Modal_participation_factor,Modal_mass,Modal_contribution]=modal(Mass, Eigen_vector,Number_of_storeys)
sum_modal_mass = 0;
	for index_k = 1 : Number_of_storeys
  		sum_W_Phi = 0;
  		sum_W_Phi2 = 0;
  			for index_i = 1 : Number_of_storeys
    				sum_W_Phi = sum_W_Phi + Mass(index_i, index_i) * ...
      				Eigen_vector(index_i, index_k);
    				sum_W_Phi2 = sum_W_Phi2 + Mass(index_i, index_i) * ...
      				Eigen_vector(index_i, index_k)^2;
  			end
Modal_participation_factor(index_k,1) = sum_W_Phi / sum_W_Phi2;
Modal_mass(index_k,1) = (sum_W_Phi^2) / (sum_W_Phi2);
sum_modal_mass = sum_modal_mass + Modal_mass(index_k,1);  
end

Modal_contribution = 100 / sum_modal_mass * Modal_mass;

ModesContributionX = 0;
Number_of_modes_to_be_considered = 0;

	for Number_of_modes_to_be_considered = 1:Number_of_storeys
  		ModesContributionX = ModesContributionX + ...
   		Modal_contribution(Number_of_modes_to_be_considered); 
 		  if (ModesContributionX > 90)
   			 break;
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

%function calling and output
Stiffness_matrix=stif(Stiffness_storey); 
disp(sprintf ( 'Stiffness_matrix:\t'));
disp(Stiffness_matrix);
disp(sprintf ( 'Level_floor: \t'));
level=levelf(Height_storey);
disp(level);
disp(sprintf ('Time_periods :\t'));
[Frequency, Time_periods]= eigenomega(Stiffness_matrix, Mass);
disp(Time_periods);
disp(sprintf ('Frequency :\t'));
disp(Frequency);
[Eigen_vector, Omega_square] = eig(Stiffness_matrix, Mass);
disp(sprintf ('Eigen_vector:\t'));
disp(Eigen_vector);
disp(Omega_square);
[Modal_contribution,Modal_participation_factor,Modal_mass]=modal(Mass, Eigen_vector);
disp(sprintf ('Mass:\t'));
disp(Mass);
disp(sprintf ('Modal_mass:\t'));
disp(Modal_mass);
disp(sprintf ('Modal_participation_factor:\t'));
disp(Modal_participation_factor);
disp(sprintf ('Modal_contribution:\t'));
disp(Modal_contribution);

%output of functions in latex form
matrixTeX(Stiffness_matrix,'%10.4e','r')
matrixTeX(level,'%10.4e','r')
matrixTeX(Time_periods,'%10.4e','r')
matrixTeX(Frequency,'%10.4e','r')
matrixTeX(Eigen_vector,'%10.4e','r')
matrixTeX(Omega_square,'%10.4e','r')
matrixTeX(Omega_square,'%10.4e','r')
matrixTeX(Mass,'%10.4e','r')
matrixTeX(Modal_mass,'%10.4e','r')
matrixTeX(Modal_participation_factor,'%10.4e','r')
matrixTeX(Modal_contribution,'%10.4e','r')


