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
