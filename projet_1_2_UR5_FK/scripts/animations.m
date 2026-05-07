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


% 5. Extract (X, Y, Z) - Row 1 to 3 of the last column
x = tform(1,4);
y = tform(2,4);
z = tform(3,4);

fprintf('End-Effector Position -> X: %.3f m, Y: %.3f m, Z: %.3f m\n', x, y, z);


% 1. Ensure Joint 3 (the Elbow) is set to 90 degrees (pi/2 radians)
% We use (3) because it is a simple numeric array (double)
config(3) = pi/2; 

% 2. Calculate the transformation matrix again with the NEW config
tform = getTransform(robot, config, 'tool0');

% 3. Update the 3D display[cite: 5]
% The second argument 'config' tells show() exactly where the joints are
show(robot, config);
grid on;
view(3);
title('UR5: Elbow bent at 90 degrees');

% 4. Print the new Z height to see if it changed from the "Home" height
fprintf('The current Tool Z-position is: %.3f meters\n', tform(3,4));

% Extract only the 3x3 Rotation matrix
rotation_part = tform(1:3, 1:3);
disp('Rotation Matrix:');
disp(rotation_part);

% Calculate the 6x6 Jacobian matrix at the current configuration
J = geometricJacobian(robot, config, 'tool0');
disp('Geometric Jacobian (J):');
disp(J);

% Extract only the 3x3 linear part for a simpler check
J_linear = J(1:3, 1:3); 
d = det(J_linear);
fprintf('Jacobian Determinant: %.5f\n', d);

r = rank(J);
fprintf('Robot Rank: %d\n', r);

%% 1. Setup Points and Time
q_start = config; % Use the Rank 5 config we found earlier
q_goal = [0; -pi/4; pi/2; 0; pi/4; 0]; % A safe, non-singular goal configuration[cite: 5]
t = 0:0.01:5; % 5 seconds, 10ms time steps

%% 2. Calculate the Trajectory
% 'q' will be 6 rows (joints) and N columns (time steps)
[q, qd, qdd] = trapveltraj([q_start, q_goal], numel(t));

%% 3. Plot Velocity to verify the "Trapezoid"
figure;
subplot(2,1,1);
plot(t, q'); % Plot joint positions
title('Joint Positions (q)');
ylabel('Radians');

subplot(2,1,2);
plot(t, qd'); % Plot joint velocities[cite: 5]
title('Joint Velocities (qd) - Look for the Trapezoid!');
ylabel('Rad/s');
xlabel('Time (s)');

%% 4. Animation
figure;
show(robot, q_start); % Show initial pose
hold on;
for i = 1:50:size(q,2) % Show robot every 50 steps for speed
    show(robot, q(:,i), 'PreservePlot', false);
    drawnow;
end
title('Animation of UR5 smooth movement');

% 1. Define Start and End Poses (4x4 Matrices)
T_start = getTransform(robot, q_start, 'tool0');
T_end = T_start; 
T_end(1,4) = T_end(1,4) + 0.2; % Move 20cm in X direction

% 2. Create the Cartesian Trajectory
% This generates 100 steps between the two matrices
[T_path, vel, accel] = transformtraj(T_start, T_end, [0 5], t);

% 3. Visualize the path
plot3(squeeze(T_path(1,4,:)), squeeze(T_path(2,4,:)), squeeze(T_path(3,4,:)), 'r--', 'LineWidth', 2);