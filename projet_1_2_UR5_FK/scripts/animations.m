%% ================================================
%  PROJECT 1.2 — UR5 Forward Kinematics
%  STEP 5: Animate a Sinusoidal Trajectory
%  Version corrigée : animation plus rapide
%% ================================================

%% PART 1: Define the trajectory parameters

% Load robot
robot = loadrobot('universalUR5');

% Time vector: from 0 to 5 seconds
t_start = 0;
t_end   = 5;         
N       = 100;       
t       = linspace(t_start, t_end, N);

% --- Sinusoidal amplitudes for each joint (in degrees) ---
A1 = 60;   
A2 = 30;   
A3 = 45;   
A4 = 0;    
A5 = 20;   
A6 = 0;    

% Faster motion: 0.8 Hz instead of 0.4 Hz
f = 0.8;   

%% PART 2: Pre-compute the trajectory

disp('Pre-computing trajectory...');

% Storage arrays for end-effector path
path_x = zeros(1, N);  
path_y = zeros(1, N);  
path_z = zeros(1, N);  

% Pre-compute all configurations
all_configs = cell(1, N);  

for k = 1:N
    % Compute joint angles at time t(k)
    angles_deg = [
        A1 * sin(2*pi*f * t(k))              % joint 1
        A2 * sin(2*pi*f * t(k) + pi/4)       % joint 2
        A3 * sin(2*pi*f * t(k) + pi/2)       % joint 3
        A4 * sin(2*pi*f * t(k))              % joint 4
        A5 * sin(2*pi*f * t(k) + pi/3)       % joint 5
        A6 * sin(2*pi*f * t(k))              % joint 6
    ];
    
    % Call custom Forward Kinematics function
    result = fk_ur5(robot, angles_deg);
    
    % Store position for trajectory trail
    path_x(k) = result.position(1);
    path_y(k) = result.position(2);
    path_z(k) = result.position(3);
    
    % Store the config for animation
    all_configs{k} = result.config;
end

disp('Trajectory pre-computed! Starting animation...');

%% PART 3: Animate the robot

figure('Name', 'UR5 — Sinusoidal Trajectory Animation', ...
       'Position', [50 50 900 700]);
ax = gca;

for k = 1:N
    
    % Faster rendering with FastUpdate
    show(robot, all_configs{k}, ...
        'Parent', ax, ...
        'PreservePlot', false, ...
        'Frames', 'off', ...
        'FastUpdate', true);
    hold(ax, 'on');
    
    % Past trajectory
    if k > 1
        plot3(ax, path_x(1:k), path_y(1:k), path_z(1:k), ...
            'b-', 'LineWidth', 2);
    end
    
    % Optional: draw only a short future segment to reduce lag
    future_end = min(k + 15, N);
    if k < N
        plot3(ax, path_x(k:future_end), path_y(k:future_end), path_z(k:future_end), ...
            '--', 'LineWidth', 1, 'Color', [0.7 0.7 1]);
    end
    
    % Current end-effector position
    plot3(ax, path_x(k), path_y(k), path_z(k), ...
        'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'red');
    
    hold(ax, 'off');
    
    % Labels and formatting
    title(ax, sprintf('UR5 Trajectory Animation — t = %.2f s (frame %d/%d)', ...
        t(k), k, N));
    xlabel(ax, 'X (m)');
    ylabel(ax, 'Y (m)');
    zlabel(ax, 'Z (m)');
    
    axis(ax, 'equal');
    grid(ax, 'on');
    view(ax, 45, 25);
    
    xlim(ax, [-1.5  1.5]);
    ylim(ax, [-1.5  1.5]);
    zlim(ax, [-0.5  1.5]);
    
    drawnow limitrate;
    
    % Reduced pause for faster animation
    pause(0.01);
end

disp(' Animation complete!');

%% PART 4: Plot the end-effector trajectory in 3D (static summary)

figure('Name', 'End-Effector Trajectory — 3D Path', ...
       'Position', [100 100 800 600]);

plot3(path_x, path_y, path_z, 'b-', 'LineWidth', 2);
hold on;

plot3(path_x(1), path_y(1), path_z(1), ...
    'go', 'MarkerSize', 12, 'MarkerFaceColor', 'green');

plot3(path_x(end), path_y(end), path_z(end), ...
    'rs', 'MarkerSize', 12, 'MarkerFaceColor', 'red');

legend('End-effector path', 'Start', 'End', 'Location', 'best');
title('UR5 End-Effector 3D Trajectory — Sinusoidal Joint Motion');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
axis equal;
grid on;
view(35, 25);

% Print path statistics
fprintf('\n📊 TRAJECTORY STATISTICS:\n');
fprintf('   X range: %.3f m to %.3f m\n', min(path_x), max(path_x));
fprintf('   Y range: %.3f m to %.3f m\n', min(path_y), max(path_y));
fprintf('   Z range: %.3f m to %.3f m\n', min(path_z), max(path_z));
fprintf('   Total workspace explored: %.3f m × %.3f m × %.3f m\n', ...
    max(path_x)-min(path_x), ...
    max(path_y)-min(path_y), ...
    max(path_z)-min(path_z));