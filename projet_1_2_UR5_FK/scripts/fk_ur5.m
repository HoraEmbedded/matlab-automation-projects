function result = fk_ur5(robot, joint_angles_deg)
%% FK_UR5 — Compute Forward Kinematics for UR5 robot
%
%  INPUT:
%    robot           → the rigidBodyTree robot object
%    joint_angles_deg → [6x1] vector of joint angles IN DEGREES
%                       [j1, j2, j3, j4, j5, j6]
%
%  OUTPUT:
%    result.T         → 4x4 transformation matrix
%    result.position  → [x, y, z] position of end-effector (meters)
%    result.euler     → [roll, pitch, yaw] orientation in degrees
%    result.quaternion→ [w, x, y, z] quaternion orientation
%
%  EXAMPLE:
%    robot = loadrobot('universalUR5');
%    out = fk_ur5(robot, [45, -30, 60, 0, 0, 0]);
%    disp(out.position)
%
%  Author: HoraEmbedded
%%

    %% STEP 1: Convert degrees → radians
    % MATLAB trigonometry always works in radians
    joint_angles_rad = deg2rad(joint_angles_deg);

    %% STEP 2: Build the configuration struct
    % homeConfiguration gives us the right struct structure
    % then we fill it with our angles
    config = homeConfiguration(robot);

    % Fill each joint position
    % The UR5 has 6 revolute joints (indices 1 to 6)
    for i = 1:6
        config(i).JointPosition = joint_angles_rad(i);
    end

    %% STEP 3: Compute the transformation matrix
    % getTransform = the FK engine
    % Using 'base_link' instead of 'base' to align with the 3D plot origin
    T = getTransform(robot, config, 'tool0', 'base_link');

    %% STEP 4: Extract useful information from T
    % Remember: T = [R | p]
    %                [0 | 1]

    % --- Position (x, y, z) ---
    position = T(1:3, 4);  % column 4, rows 1-3

    % --- Rotation matrix ---
    R = T(1:3, 1:3);       % top-left 3x3 block

    % --- Convert rotation to Euler angles (Roll, Pitch, Yaw) ---
    % eul = rotm2eul(R) converts rotation matrix → [Z Y X] Euler angles
    % 'ZYX' is the standard aerospace/robotics convention
    eul_rad = rotm2eul(R, 'ZYX');
    euler_deg = rad2deg(eul_rad);  % convert to degrees for readability

    % --- Convert rotation to Quaternion ---
    % Quaternion = [w, x, y, z] compact orientation representation
    quat = rotm2quat(R);  % returns [w, x, y, z]

    %% STEP 5: Package everything into the result struct
    result.T          = T;
    result.position   = position;
    result.euler      = euler_deg;   % [yaw, pitch, roll] in degrees
    result.quaternion = quat;        % [w, x, y, z]
    result.config     = config;      % save config for visualization

end