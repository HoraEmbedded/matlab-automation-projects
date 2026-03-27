%% =========================================================
%  Project 1.1 - Forward Kinematics of a 2R Planar Robot
%  Method    : Denavit-Hartenberg (Standard Convention)
%  Author    : HoraEmbedded
%  Date      : 2026
%  Tools     : MATLAB Symbolic Math Toolbox
%% =========================================================
clear; clc;

%% --- STEP 1: Declare symbolic variables ---
syms theta1 theta2 L1 L2 real

%% --- STEP 2: Define the DH transformation matrix ---
DH = @(theta, d, a, alpha) ...
    [cos(theta), -sin(theta)*cos(alpha),  sin(theta)*sin(alpha), a*cos(theta);
     sin(theta),  cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
          0,           sin(alpha),              cos(alpha),            d      ;
          0,                0,                       0,                1      ];

%% --- STEP 3: Compute transformation matrices ---
T01 = DH(theta1, 0, L1, 0);
disp('T01'); disp(T01)

T12 = DH(theta2, 0, L2, 0);
disp('T12'); disp(T12)

%% --- STEP 4: Total transformation ---
T02 = T01 * T12;

%% --- STEP 5: Simplify ---
T02_simpl = simplify(T02);
disp('T02 SIMPLIFIED'); disp(T02_simpl)

%% --- STEP 6: Extract position ---
x_end = T02_simpl(1, 4);
y_end = T02_simpl(2, 4);
disp('End-Effector Position');
fprintf('x = '); disp(x_end)
fprintf('y = '); disp(y_end)

%% --- STEP 7: Verify ---
x_test = double(subs(x_end, {theta1,theta2,L1,L2}, {0, 0, 1, 0.5}));
y_test = double(subs(y_end, {theta1,theta2,L1,L2}, {0, 0, 1, 0.5}));

fprintf('\n=== VERIFICATION TEST ===\n')
fprintf('theta1=0, theta2=0, L1=1, L2=0.5\n')
fprintf('x = %.4f  (expected: 1.5000)\n', x_test)
fprintf('y = %.4f  (expected: 0.0000)\n', y_test)

if abs(x_test - 1.5) < 1e-10 && abs(y_test - 0) < 1e-10
    fprintf('✅ TEST PASSED! FK is correct.\n')
else
    fprintf('❌ TEST FAILED! Check your matrices.\n')
end