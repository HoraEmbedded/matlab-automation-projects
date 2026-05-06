%% ================================================
%  PROJECT 1.2 — UR5 Forward Kinematics
%  STEP 6: Jacobian Matrix & Singularity Detection
%  Version corrigée
%% ================================================

clear; clc; close all;

%% Load robot
robot = loadrobot('universalUR5', 'DataFormat', 'column');

% Choix robuste de l'effecteur terminal
if any(strcmp(robot.BodyNames, 'tool0'))
    eeName = 'tool0';
else
    eeName = robot.BodyNames{end};
end

%% Paramètres
w_threshold = 0.01;   % seuil de manipulabilité
sv_tol      = 1e-3;   % seuil sur la plus petite valeur singulière

%% ══════════════════════════════════════════════
%  PART 1: Compute Jacobian for specific configs
%% ══════════════════════════════════════════════

disp('════════════════════════════════════════');
disp('  PART 1 — Jacobian at 3 configurations');
disp('════════════════════════════════════════');

configs_to_test = [
     0    0    0    0    0    0
     0  -90    0    0    0    0
     0    0  180    0    0    0
];

config_names = {
    'HOME'
    'ARM UP'
    'ELBOW STRAIGHT'
};

for i = 1:size(configs_to_test, 1)

    angles_deg = configs_to_test(i, :);
    q = deg2rad(angles_deg(:));   % colonne 6x1

    % Compute Jacobian
    J = geometricJacobian(robot, q, eeName);

    % Singular values
    s = svd(J);

    % Manipulability
    w = prod(s);

    % Determinant only if J is square
    if size(J,1) == size(J,2)
        d = abs(det(J));
    else
        d = NaN;
    end

    sigma_min = min(s);
    rankJ = sum(s > sv_tol);

    fprintf('\n📍 Config: %s %s\n', config_names{i}, mat2str(angles_deg));
    fprintf('   Manipulability w = %.6e\n', w);
    fprintf('   sigma_min        = %.6e\n', sigma_min);
    fprintf('   Rank(J)          = %d\n', rankJ);

    if ~isnan(d)
        fprintf('   |det(J)|         = %.6e\n', d);
    else
        fprintf('   |det(J)|         = not defined (non-square Jacobian)\n');
    end

    % Singularity warning
    if (w < w_threshold) || (sigma_min < sv_tol) || (rankJ < 6)
        fprintf('   ⚠️  WARNING: near singularity detected\n');
    else
        fprintf('   ✅ Configuration is healthy\n');
    end
end

%% ══════════════════════════════════════════════
%  PART 2: Scan for singularities
%  Sweep joint 2 from -180° to 0°
%% ══════════════════════════════════════════════

disp(' ');
disp('════════════════════════════════════════');
disp('  PART 2 — Singularity scan (sweep j2)');
disp('════════════════════════════════════════');

j2_range = linspace(-180, 0, 180);
nPoints = numel(j2_range);

w_values = zeros(1, nPoints);
sigma_min_values = zeros(1, nPoints);

for k = 1:nPoints
    q = zeros(6,1);
    q(2) = deg2rad(j2_range(k));

    J = geometricJacobian(robot, q, eeName);
    s = svd(J);

    w_values(k) = prod(s);
    sigma_min_values(k) = min(s);
end

% Minimum manipulability
[w_min, idx_min] = min(w_values);

% Maximum manipulability
[w_max, idx_max] = max(w_values);

fprintf('   Most dangerous angle: j2 = %.1f° (w = %.6e)\n', ...
    j2_range(idx_min), w_min);

%% ══════════════════════════════════════════════
%  PART 3: Plot manipulability vs joint angle
%% ══════════════════════════════════════════════

figure('Name', 'Manipulability vs Joint 2 Angle', ...
       'Position', [100 100 850 480]);

plot(j2_range, w_values, 'b-', 'LineWidth', 2);
hold on;

% Danger zone
danger_zone = w_values < w_threshold;
plot(j2_range(danger_zone), w_values(danger_zone), ...
     'r.', 'MarkerSize', 12);

% Minimum point
plot(j2_range(idx_min), w_min, ...
     'rv', 'MarkerSize', 12, 'MarkerFaceColor', 'red');

% Threshold line
yline(w_threshold, 'r--', 'Danger threshold', ...
      'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');

hold off;
grid on;

xlabel('Joint 2 angle (degrees)');
ylabel('Manipulability w');
title('UR5 Manipulability vs Joint 2 Angle — Singularity Map');
legend('Manipulability w', ...
       'Danger zone (w < threshold)', ...
       'Minimum (most singular)', ...
       'Location', 'best');

fprintf('\n📊 MANIPULABILITY SUMMARY:\n');
fprintf('   Maximum w = %.6e at j2 = %.1f° (best pose)\n', ...
    w_max, j2_range(idx_max));
fprintf('   Minimum w = %.6e at j2 = %.1f° (most singular)\n', ...
    w_min, j2_range(idx_min));

%% ══════════════════════════════════════════════
%  PART 4: Plot smallest singular value
%% ══════════════════════════════════════════════

figure('Name', 'Smallest Singular Value vs Joint 2 Angle', ...
       'Position', [120 120 850 480]);

plot(j2_range, sigma_min_values, 'm-', 'LineWidth', 2);
hold on;
yline(sv_tol, 'r--', 'Singularity tolerance', ...
      'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left');
plot(j2_range(idx_min), sigma_min_values(idx_min), ...
     'kv', 'MarkerSize', 12, 'MarkerFaceColor', 'k');
hold off;
grid on;

xlabel('Joint 2 angle (degrees)');
ylabel('Smallest singular value');
title('UR5 Smallest Singular Value vs Joint 2 Angle');

%% ══════════════════════════════════════════════
%  PART 5: Visualize the most singular config
%% ══════════════════════════════════════════════

figure('Name', 'Most Singular Configuration', ...
       'Position', [150 150 650 520]);

q_singular = zeros(6,1);
q_singular(2) = deg2rad(j2_range(idx_min));

show(robot, q_singular, 'Frames', 'off', 'PreservePlot', false);
title(sprintf('Most Singular Configuration\nj2 = %.1f° | w = %.6e', ...
      j2_range(idx_min), w_min));
axis equal;
grid on;
view(45, 20);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');


 % Importation du robot à partir du fichier URDF
robot = importrobot('ur5.urdf');

% Affichage du robot pour vérifier l'importation
show(robot);