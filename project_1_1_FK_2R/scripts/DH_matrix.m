%% =========================================================
%  Project 1.1 - Forward Kinematics of a 2R Planar Robot
%  Method    : Denavit-Hartenberg (Standard Convention)
%  Author    : HoraEmbedded
%  Date      : 2026
%  Tools     : MATLAB Symbolic Math Toolbox
%% =========================================================
clear; clc;

%% Declare symbolic variables
syms theta1 theta2 L1 L2 real

%% Define the DH transformation matrix
DH = @(theta, d, a, alpha) ...
    [cos(theta), -sin(theta)*cos(alpha),  sin(theta)*sin(alpha), a*cos(theta);
     sin(theta),  cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
          0,           sin(alpha),              cos(alpha),            d      ;
          0,                0,                       0,                1      ];

% Compute transformation matrices
T01 = DH(theta1, 0, L1, 0);
disp('T01'); disp(T01)

T12 = DH(theta2, 0, L2, 0);
disp('T12'); disp(T12)

% Total transformation
T02 = T01 * T12;

% Simplify
T02_simpl = simplify(T02);
disp('T02 SIMPLIFIED'); disp(T02_simpl)

% Extract position
x_end = T02_simpl(1, 4);
y_end = T02_simpl(2, 4);
disp('End-Effector Position');
fprintf('x = '); disp(x_end)
fprintf('y = '); disp(y_end)
