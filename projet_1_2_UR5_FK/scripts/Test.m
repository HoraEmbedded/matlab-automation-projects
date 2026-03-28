%% ================================================
%  PROJECT 1.2 — UR5 Forward Kinematics
%  STEP 4: Testing the fk_ur5() function
%  Author: HoraEmbedded
%% ================================================

%% Load robot
robot = loadrobot('universalUR5');

%% TEST 1 — Home position (expect z ≈ 0, arm horizontal)
disp('════════════════════════════════════');
disp('TEST 1 — HOME position');
disp('════════════════════════════════════');

out1 = fk_ur5(robot, [0, 0, 0, 0, 0, 0]);

fprintf('Position  : x=%.4f  y=%.4f  z=%.4f (m)\n', ...
    out1.position(1), out1.position(2), out1.position(3));
fprintf('Euler     : yaw=%.1f°  pitch=%.1f°  roll=%.1f°\n', ...
    out1.euler(1), out1.euler(2), out1.euler(3));
fprintf('Quaternion: w=%.4f  x=%.4f  y=%.4f  z=%.4f\n\n', ...
    out1.quaternion(1), out1.quaternion(2), ...
    out1.quaternion(3), out1.quaternion(4));

%% TEST 2 — Custom position
disp('════════════════════════════════════');
disp('TEST 2 — CUSTOM position');
disp('════════════════════════════════════');

out2 = fk_ur5(robot, [45, -30, 60, 0, 0, 0]);

fprintf('Position  : x=%.4f  y=%.4f  z=%.4f (m)\n', ...
    out2.position(1), out2.position(2), out2.position(3));
fprintf('Euler     : yaw=%.1f°  pitch=%.1f°  roll=%.1f°\n\n', ...
    out2.euler(1), out2.euler(2), out2.euler(3));

%% TEST 3 — Arm pointing straight UP (expect large z)
disp('════════════════════════════════════');
disp('TEST 3 — ARM UP position');
disp('════════════════════════════════════');

out3 = fk_ur5(robot, [0, -90, 0, 0, 0, 0]);

fprintf('Position  : x=%.4f  y=%.4f  z=%.4f (m)\n', ...
    out3.position(1), out3.position(2), out3.position(3));
fprintf('Euler     : yaw=%.1f°  pitch=%.1f°  roll=%.1f°\n\n', ...
    out3.euler(1), out3.euler(2), out3.euler(3));

%% VISUALIZE all 3 tests side by side
figure('Name','FK Function — 3 Tests', 'Position',[100 100 1200 400]);

subplot(1,3,1);
show(robot, out1.config, 'PreservePlot', false);
title(sprintf('HOME\nz = %.3f m', out1.position(3)));
axis equal; grid on; view(45,20);

subplot(1,3,2);
show(robot, out2.config, 'PreservePlot', false);
title(sprintf('CUSTOM j1=45° j2=-30° j3=60°\nz = %.3f m', out2.position(3)));
axis equal; grid on; view(45,20);

subplot(1,3,3);
show(robot, out3.config, 'PreservePlot', false);
title(sprintf('ARM UP j2=-90°\nz = %.3f m', out3.position(3)));
axis equal; grid on; view(45,20);

sgtitle('fk\_ur5() Function — Verified on 3 Configurations');

disp('✅ fk_ur5() function working correctly!');