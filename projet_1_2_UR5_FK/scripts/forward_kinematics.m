%% ================================================
%  PROJECT 1.2 — UR5 Forward Kinematics
%  STEP 3: Understanding & Computing FK
%  Author: HoraEmbedded
%% ================================================

%% Load the robot (always start with this)
robot = loadrobot('universalUR5');



% CONFIG A: Home position (all joints = 0)
config_home = homeConfiguration(robot);
% This gives: [0, 0, 0, 0, 0, 0] radians

% CONFIG B: Custom position 
config_custom = config_home;  % start from home



config_custom(1).JointPosition = deg2rad(45);   % rotate base 45°
config_custom(2).JointPosition = deg2rad(-30);  % lift shoulder -30°
config_custom(3).JointPosition = deg2rad(60);   % bend elbow 60°

% CONFIG C: Another custom position
config_extended = config_home;
config_extended(2).JointPosition = deg2rad(-90); % arm pointing up

%% PART 2: Compute FK using getTransform()

disp('=== FORWARD KINEMATICS RESULTS ===');
disp(' ');

%--- Home configuration ---
T_home = getTransform(robot, config_home, 'tool0', 'base');

disp('Configuration HOME (all joints = 0°):');
disp('Transformation Matrix T:');
disp(T_home);


position_home = T_home(1:3, 4);
fprintf('  → Hand position: x=%.4f m, y=%.4f m, z=%.4f m\n', ...
    position_home(1), position_home(2), position_home(3));

disp(' ');

%--- Custom configuration ---
T_custom = getTransform(robot, config_custom, 'tool0', 'base');

disp('Configuration CUSTOM (joint1=45°, joint2=-30°, joint3=60°):');
position_custom = T_custom(1:3, 4);
fprintf('  → Hand position: x=%.4f m, y=%.4f m, z=%.4f m\n', ...
    position_custom(1), position_custom(2), position_custom(3));

disp(' ');

%--- Extended configuration ---
T_extended = getTransform(robot, config_extended, 'tool0', 'base');

disp('Configuration EXTENDED (joint2=-90°, arm up):');
position_extended = T_extended(1:3, 4);
fprintf('  → Hand position: x=%.4f m, y=%.4f m, z=%.4f m\n', ...
    position_extended(1), position_extended(2), position_extended(3));

%% PART 3: Visualize the 3 configurations

figure('Name', 'FK — 3 Different Configurations', ...
       'Position', [100 100 1200 400]);

% --- Plot 1: Home ---
subplot(1, 3, 1);
show(robot, config_home, 'PreservePlot', false);
title('HOME — All joints = 0°');
axis equal; grid on;
xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');
view(45, 20);

% --- Plot 2: Custom ---
subplot(1, 3, 2);
show(robot, config_custom, 'PreservePlot', false);
title('CUSTOM — j1=45°, j2=-30°, j3=60°');
axis equal; grid on;
xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');
view(45, 20);

% --- Plot 3: Extended ---
subplot(1, 3, 3);
show(robot, config_extended, 'PreservePlot', false);
title('EXTENDED — j2=-90° (arm up)');
axis equal; grid on;
xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');
view(45, 20);

sgtitle('UR5 Forward Kinematics — 3 Configurations Compared');