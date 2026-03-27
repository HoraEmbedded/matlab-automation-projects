## PART — The DH Transformation Matrix in MATLAB

**"Homogeneous Transformation Matrix"**

For each joint, the DH convention gives us this transformation matrix:
```
         ┌                                              ┐
         │  cos(θ)    -sin(θ)cos(α)    sin(θ)sin(α)    a·cos(θ)  │
T_i =    │  sin(θ)     cos(θ)cos(α)   -cos(θ)sin(α)    a·sin(θ)  │
         │    0           sin(α)           cos(α)          d      │
         │    0              0                0             1      │
         └                                              ┘
```
%FK_2R  Forward Kinematics of a planar 2R robot
%
%  INPUTS:
%    theta1 : angle of joint 1 (radians)
%    theta2 : angle of joint 2 (radians)
%    L1     : length of link 1 (meters)
%    L2     : length of link 2 (meters)
%
%  OUTPUTS:
%    x  : x-coordinate of end-effector (meters)
%    y  : y-coordinate of end-effector (meters)
%    T  : 4x4 homogeneous transformation matrix (full pose)
%
%  FORMULA (derived from DH convention):
%    x = L1*cos(theta1) + L2*cos(theta1+theta2)
%    y = L1*sin(theta1) + L2*sin(theta1+theta2)
%