% 1. Load the robot model (this might take a second)
% If 'universalUR5.urdf' is not in your path, MATLAB often 
% has built-in examples like 'universalUR5'
robot = loadrobot("universalUR5", "DataFormat", "column");

% 2. Look at the names of the "pieces" (Links)
showdetails(robot)

% 1. Create a figure to see the robot
figure
show(robot); 
grid on
view(3) % Set a 3D view
title('UR5 Initial State: All Angles at 0');
