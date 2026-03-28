% loadrobot() = MATLAB's built-in robot library
% Think of it like: instead of downloading a recipe from internet,
% you find it already printed in your cookbook!

robot = loadrobot('universalUR5', 'DataFormat', 'column');

disp('✅ UR5 loaded from MATLAB built-in library!');
showdetails(robot)

config = homeConfiguration(robot);

figure('Name', 'UR5 Robot - Home Configuration');
show(robot, config);
title('UR5 Robot — Home Configuration');
axis equal;
grid on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view(45, 30);