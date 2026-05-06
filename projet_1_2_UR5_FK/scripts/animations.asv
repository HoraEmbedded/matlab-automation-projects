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

% 1. Create the configuration vector (already set to 'column' format)
config = homeConfiguration(robot); 

% 2. Assign the angle to Joint 3 (the Elbow) using simple indexing
% Since it is a 'double' array, we don't use .JointPosition
config(3) = pi; 

% 3. Compute the transformation matrix from 'base_link' to 'tool0'[cite: 5]
tform = getTransform(robot, config, 'tool0');

% 4. Display results
disp('Corrected Transformation Matrix:');
disp(tform);

% 5. Extract (X, Y, Z) - Row 1 to 3 of the last column
x = tform(1,4);
y = tform(2,4);
z = tform(3,4);

fprintf('End-Effector Position -> X: %.3f m, Y: %.3f m, Z: %.3f m\n', x, y, z);