%% =========================================================
%  Project 1.1 - Workspace Map of the 2R Robot
%  Method: Sweep all angle combinations, plot each point
%% =========================================================
clear; clc; close all;


L1 = 1.0;   
L2 = 0.2;   

% Angle Ranges

theta1_range = linspace(0, 2*pi, 360);  
theta2_range = linspace(0, 2*pi, 360);  

%-Pre-allocate storage

n_total = length(theta1_range) * length(theta2_range);
x_all = zeros(1, n_total);  
y_all = zeros(1, n_total);  


idx = 1;  % index counter

for i = 1:length(theta1_range)
    for j = 1:length(theta2_range)

        % Get current angles
        t1 = theta1_range(i);
        t2 = theta2_range(j);

        % Compute FK 
        [x, y] = fk_2R(t1, t2, L1, L2);

        % Store the result
        x_all(idx) = x;
        y_all(idx) = y;
        idx = idx + 1;

    end
end

%% --- Plot the Workspace ---
figure('Name', '2R Robot Workspace', 'NumberTitle', 'off');

% Plot all reachable points as tiny dots
scatter(x_all, y_all, 1, 'b', 'filled');   % size=1, blue, filled

hold on; grid on; axis equal;

% Mark the base
plot(0, 0, 'ko', 'MarkerSize', 14, 'MarkerFaceColor', 'k');
text(0.05, 0.1, 'Base', 'FontSize', 12, 'FontWeight', 'bold');

% Draw theoretical boundary circles
theta_circle = linspace(0, 2*pi, 500);
r_outer = L1 + L2;           % max reach
r_inner = abs(L1 - L2);      % min reach (the hole)

plot(r_outer*cos(theta_circle), r_outer*sin(theta_circle), ...
     'r--', 'LineWidth', 2);   % outer boundary
plot(r_inner*cos(theta_circle), r_inner*sin(theta_circle), ...
     'g--', 'LineWidth', 2);   % inner boundary

% Labels
title(sprintf('Workspace - L1=%.1fm, L2=%.1fm', L1, L2), 'FontSize', 14);
xlabel('X (meters)'); ylabel('Y (meters)');
legend('Reachable points', 'Base', ...
       sprintf('Outer boundary (r=%.1f)', r_outer), ...
       sprintf('Inner boundary (r=%.1f)', r_inner), ...
       'Location', 'northeast');

% Print the key numbers
fprintf('=== Workspace Analysis ===\n');
fprintf('Outer radius (max reach) = %.3f m\n', r_outer);
fprintf('Inner radius (min reach) = %.3f m\n', r_inner);
fprintf('Total points computed    = %d\n', n_total);