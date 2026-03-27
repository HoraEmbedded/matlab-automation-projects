%% =========================================================
%  Uses fk_2R() to draw the robot for any configuration
%% =========================================================
clear; clc; close all;

%Robot Parameters
L1 = 1.0;    % Length of link 1 (meters)
L2 = 0.6;    % Length of link 2 (meters)

% Choose Configuration
theta1 = pi/4;    % 45 degrees
theta2 = pi/3;    % 60 degrees

% Compute FK
[x_end, y_end, ~] = fk_2R(theta1, theta2, L1, L2);

% Joint 2 position (end of link 1)
x_j2 = L1 * cos(theta1);
y_j2 = L1 * sin(theta1);

% Draw the Robot 
figure('Name', 'My 2R Robot', 'NumberTitle', 'off');
hold on; grid on; axis equal;

% Draw Link 1: from base (0,0) to Joint 2
plot([0, x_j2], [0, y_j2], 'b-', 'LineWidth', 4);

% Draw Link 2: from Joint 2 to End-Effector
plot([x_j2, x_end], [y_j2, y_end], 'r-', 'LineWidth', 4);

% Draw joints as circles
plot(0,    0,    'ko', 'MarkerSize', 14, 'MarkerFaceColor', 'k');  % Base
plot(x_j2, y_j2, 'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'b');  % Joint 2
plot(x_end,y_end,'r*', 'MarkerSize', 16, 'LineWidth', 2);           % End-Effector

% Labels
text(0, -0.1,      'Base (0,0)',   'FontSize', 11, 'HorizontalAlignment','center');
text(x_j2, y_j2+0.08, 'Joint 2',  'FontSize', 11, 'Color', 'blue');
text(x_end+0.05, y_end, 'End-Effector', 'FontSize', 11, 'Color', 'red');

% Angle annotations
title(sprintf('2R Robot — \\theta_1=%.0f°,  \\theta_2=%.0f°', ...
              rad2deg(theta1), rad2deg(theta2)), 'FontSize', 14);
xlabel('X (meters)'); ylabel('Y (meters)');

% Show exact position
fprintf('End-Effector Position:\n');
fprintf('  x = %.4f m\n', x_end);
fprintf('  y = %.4f m\n', y_end);

%% =========================================================
%  Animate the 2R Robot sweeping through configurations
%% =========================================================
clear; clc; close all;

L1 = 1.0;
L2 = 0.6;

figure('Name','2R Robot Animation','NumberTitle','off');

% Sweep theta1 from 0 to 180 degrees, theta2 fixed at 45 degrees
theta1_range = linspace(0, pi, 60);   % 60 frames
theta2_fixed = pi/4;                   % 45 degrees

for i = 1:length(theta1_range)
    theta1 = theta1_range(i);
    theta2 = theta2_fixed;

    % Compute positions
    [x_end, y_end] = fk_2R(theta1, theta2, L1, L2);
    x_j2 = L1*cos(theta1);
    y_j2 = L1*sin(theta1);

    % Clear and redraw
    cla;
    hold on; grid on; axis equal;
    axis([-2 2 -2 2]);   % Fixed axis so robot doesn't jump

    % Draw links
    plot([0, x_j2],   [0, y_j2],   'b-', 'LineWidth', 5);
    plot([x_j2,x_end],[y_j2,y_end],'r-', 'LineWidth', 5);

    % Draw joints
    plot(0,     0,     'ko','MarkerSize',14,'MarkerFaceColor','k');
    plot(x_j2,  y_j2,  'bo','MarkerSize',12,'MarkerFaceColor','b');
    plot(x_end, y_end, 'r*','MarkerSize',16,'LineWidth',2);

    % Title with current angles
    title(sprintf('\\theta_1 = %.1f°   |   \\theta_2 = 45°', ...
                  rad2deg(theta1)), 'FontSize', 13);
    xlabel('X (m)'); ylabel('Y (m)');

    drawnow;           % Force MATLAB to refresh the figure NOW
    pause(0.03);       % Small pause to create animation effect
end