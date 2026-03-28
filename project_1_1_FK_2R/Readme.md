# 🤖 Project 1.1 — Forward Kinematics of a 2R Planar Robot

<div align="center">

![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange?style=for-the-badge&logo=mathworks)
![Toolbox](https://img.shields.io/badge/Robotics_System_Toolbox-required-blue?style=for-the-badge)
![Toolbox](https://img.shields.io/badge/Symbolic_Math_Toolbox-required-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete_✅-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-v1.0-purple?style=for-the-badge)

**Author:** HoraEmbedded  
**Program:** Electronics & Automation Systems Engineering  
**Phase:** 1 — Kinematics & Robot Modelling  
**Estimated Duration:** 1 week  
**Difficulty:** ⭐ Beginner Robotics

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Learning Objectives](#-learning-objectives)
- [Theory — Denavit-Hartenberg Convention](#-theory--denavit-hartenberg-convention)
- [Repository Structure](#-repository-structure)
- [Scripts Description](#-scripts-description)
- [How to Run](#-how-to-run)
- [Results & Outputs](#-results--outputs)
- [Key Concepts Learned](#-key-concepts-learned)
- [Vocabulary Reference](#-vocabulary-reference)
- [Industrial Context](#-industrial-context)
- [Next Steps](#-next-steps)

---

## 🎯 Project Overview

This project implements the **Forward Kinematics (FK)** of a **2R planar robot arm** — a robot with two rotational joints (shoulder + elbow) moving in a 2D plane. This is the foundational building block of all industrial robot programming.

### What is Forward Kinematics?

```
INPUT                          OUTPUT
──────                         ──────
θ1 = angle of Joint 1   →     x = end-effector x position
θ2 = angle of Joint 2   →     y = end-effector y position
```

> **Forward Kinematics answers the question:**  
> *"Given the joint angles, where exactly is the robot's hand in space?"*

### The Robot Structure

```
     Y
     ↑
     │           ✦ ← End-Effector
     │          /
     │    L2   /  (Link 2 — "forearm")
     │        /
     │       ● ← Joint 2 (elbow)
     │      /
     │ L1  /  (Link 1 — "upper arm")
     │    /
     │   ● ← Joint 1 / Base (shoulder)
     └──────────────────→ X

  θ1 = rotation angle of Joint 1
  θ2 = rotation angle of Joint 2
  L1 = length of Link 1
  L2 = length of Link 2
```

### Final FK Formulas (derived from DH convention)

```
x = L1·cos(θ1) + L2·cos(θ1 + θ2)
y = L1·sin(θ1) + L2·sin(θ1 + θ2)
```

These equations are **not memorized** — they are **derived analytically** using the Denavit-Hartenberg method, step by step, in this project.

---

## 📚 Learning Objectives

By completing this project, the following skills are demonstrated:

| # | Objective | Status |
|---|-----------|--------|
| 1 | Establish DH reference frames for a 2R robot | ✅ |
| 2 | Build DH parameter table (θ, d, a, α) | ✅ |
| 3 | Compute T01, T12, T02 matrices symbolically | ✅ |
| 4 | Implement numerical `fk_2R()` reusable function | ✅ |
| 5 | Visualize the robot in 2D for any configuration | ✅ |
| 6 | Animate joint sweeps to understand motion | ✅ |
| 7 | Compute and visualize the full workspace map | ✅ |
| 8 | Build interactive App Designer GUI with real-time control | ✅ |

---

## 📐 Theory — Denavit-Hartenberg Convention

### What is DH?

The **Denavit-Hartenberg (DH) convention** (1955) is the universal standard for describing robot geometry. It represents any robot joint using exactly **4 parameters**:

| Parameter | Symbol | Physical Meaning |
|-----------|--------|-----------------|
| Joint angle | θ (theta) | Rotation around Z axis — **the motor variable** |
| Link offset | d | Translation along Z axis |
| Link length | a | Distance along X axis between frames |
| Link twist | α (alpha) | Rotation around X axis between frames |

### DH Table for our 2R Robot

| Joint | θ | d | a | α |
|-------|---|---|---|---|
| 1 | θ1 *(variable)* | 0 | L1 | 0 |
| 2 | θ2 *(variable)* | 0 | L2 | 0 |

> For a **planar** robot: α = 0 and d = 0 for all joints → greatly simplifies the math.

### The DH Transformation Matrix

For each joint, DH gives a **4×4 Homogeneous Transformation Matrix**:

```
         ┌                                        ┐
         │ cos(θ)  -sin(θ)cos(α)  sin(θ)sin(α)  a·cos(θ) │
T_i  =   │ sin(θ)   cos(θ)cos(α) -cos(θ)sin(α)  a·sin(θ) │
         │   0         sin(α)        cos(α)          d     │
         │   0            0             0             1    │
         └                                        ┘
```

For our robot (α=0, d=0), this simplifies to:

```
         ┌                              ┐
         │ cos(θ)  -sin(θ)  0  a·cos(θ) │
T_i  =   │ sin(θ)   cos(θ)  0  a·sin(θ) │
         │   0        0     1     0      │
         │   0        0     0     1      │
         └                              ┘
```

### Chaining the Matrices

The total transformation from the world frame to the end-effector is:

```
T_total = T01 × T12

Where:
  T01 = transformation: World frame  → Joint 2 frame
  T12 = transformation: Joint 2 frame → End-Effector frame
```

The position of the end-effector is extracted from column 4 of T_total:

```
T_total(1,4) = x    ← x coordinate of end-effector
T_total(2,4) = y    ← y coordinate of end-effector
```

### Workspace Geometry

| Property | Formula | Example (L1=1m, L2=0.6m) |
|----------|---------|--------------------------|
| Outer radius (max reach) | L1 + L2 | 1.6 m |
| Inner radius (min reach) | \|L1 - L2\| | 0.4 m |
| Shape | Ring (annulus) | Full donut if joints unrestricted |

---

## 📁 Repository Structure

```
matlab-robotics-portfolio/
│
├── README.md                          ← This file
├── .gitignore                         ← MATLAB gitignore
│
└── project_1_1_FK_2R/
    │
    ├── scripts/
    │   ├── build_DH_matrix.m          ← Symbolic DH derivation (step-by-step)
    │   ├── fk_2R.m                    ← Reusable FK function (numerical)
    │   ├── visualize_2R.m             ← Static robot visualization
    │   ├── animate_2R.m               ← Joint sweep animation
    │   ├── workspace_2R.m             ← Full workspace map (360×360 grid)
    │   └── Robot2R_App.mlapp          ← Interactive App Designer GUI
    │
    ├── figures/
    │   ├── workspace_L1_1_L2_06.png   ← Workspace map screenshot
    │   └── Robot2R_App_screenshot.png ← App Designer GUI screenshot
    │
    └── docs/
        └── DH_table_handwritten.jpg   ← Hand-drawn DH table (paper sketch)
```

---

## 📜 Scripts Description

### 1. `build_DH_matrix.m` — Symbolic DH Derivation

**Purpose:** Derives the FK equations analytically using MATLAB's Symbolic Math Toolbox.

**What it does:**
- Declares `theta1`, `theta2`, `L1`, `L2` as symbolic variables
- Defines the general DH matrix as an anonymous function
- Computes T01 and T12 for each joint
- Multiplies T01 × T12 to get T02
- Simplifies the result symbolically
- Extracts and displays the x, y formulas
- Verifies numerically with a known test case

**Key output:**
```matlab
x = L1*cos(theta1) + L2*cos(theta1 + theta2)
y = L1*sin(theta1) + L2*sin(theta1 + theta2)

✅ TEST PASSED — x=1.5000, y=0.0000
```

---

### 2. `fk_2R.m` — Reusable FK Function

**Purpose:** Fast numerical function that computes FK for any input angles.

**Signature:**
```matlab
function [x, y, T] = fk_2R(theta1, theta2, L1, L2)
```

**Inputs:**

| Parameter | Type | Unit | Description |
|-----------|------|------|-------------|
| `theta1` | double | radians | Angle of joint 1 |
| `theta2` | double | radians | Angle of joint 2 |
| `L1` | double | meters | Length of link 1 |
| `L2` | double | meters | Length of link 2 |

**Outputs:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | double | X position of end-effector |
| `y` | double | Y position of end-effector |
| `T` | 4×4 matrix | Full homogeneous transformation matrix |

**Example usage:**
```matlab
[x, y, T] = fk_2R(pi/4, pi/3, 1.0, 0.6);
fprintf('End-effector: x=%.4f m, y=%.4f m\n', x, y);
```

---

### 3. `visualize_2R.m` — Static Robot Drawing

**Purpose:** Draws the robot in 2D for any configuration.

**Features:**
- Blue line = Link 1, Red line = Link 2
- Black circle = base joint, Blue circle = joint 2, Red star = end-effector
- Displays current angles in plot title
- Prints exact end-effector coordinates

---

### 4. `animate_2R.m` — Joint Sweep Animation

**Purpose:** Animates Joint 1 sweeping from 0° to 180° with a fixed θ2.

**Key parameters to experiment with:**
```matlab
theta1_range = linspace(0, pi, 60);   % frames
theta2_fixed = pi/4;                   % change this to see elbow up/down
```

---

### 5. `workspace_2R.m` — Workspace Map

**Purpose:** Computes and visualizes ALL positions the end-effector can reach.

**Method:** Nested loop sweeping both joints through 360° × 360° = **129,600 configurations**

**Features:**
- Blue scatter cloud = all reachable points
- Red dashed circle = outer boundary (L1 + L2)
- Green dashed circle = inner boundary (|L1 - L2|)
- Console output of key workspace metrics

---

### 6. `Robot2R_App.mlapp` — Interactive GUI Controller

**Purpose:** Real-time interactive robot controller with a graphical interface.

**Components:**
- Two sliders (−180° to +180°) for θ1 and θ2
- Live 2D robot drawing updated at every slider move
- Numeric display of current end-effector x, y coordinates
- Faint workspace boundary circle as visual reference

**Architecture:**
```
[Theta1 Slider] ──→ ValueChangedFcn ──→ updateRobot()
[Theta2 Slider] ──→ ValueChangedFcn ──→ updateRobot()
                                              │
                                     ┌────────▼────────┐
                                     │  Compute FK      │
                                     │  Draw robot      │
                                     │  Update x, y     │
                                     └─────────────────┘
```

---

## ▶️ How to Run

### Prerequisites

Verify required toolboxes are installed:
```matlab
ver   % look for: Robotics System Toolbox, Symbolic Math Toolbox
```

### Setup

```bash
# Clone the repository
git clone https://github.com/HoraEmbedded/matlab-robotics-portfolio.git
cd matlab-robotics-portfolio/project_1_1_FK_2R/scripts
```

### Running Each Script

```matlab
% 1. Derive FK equations symbolically
run('build_DH_matrix.m')

% 2. Test the FK function directly
[x, y] = fk_2R(pi/4, pi/4, 1.0, 0.6)

% 3. Draw the robot in one configuration
run('visualize_2R.m')

% 4. Watch the animation
run('animate_2R.m')

% 5. Generate workspace map
run('workspace_2R.m')

% 6. Open interactive controller
open('Robot2R_App.mlapp')
% Then click the green ▶ Run button inside App Designer
```

### Recommended Order

```
build_DH_matrix.m  →  fk_2R.m  →  visualize_2R.m
        →  animate_2R.m  →  workspace_2R.m  →  Robot2R_App.mlapp
```

---

## 📊 Results & Outputs

### Transformation Matrices (symbolic)

```
T01 =
[ cos(θ1),  -sin(θ1),  0,  L1·cos(θ1) ]
[ sin(θ1),   cos(θ1),  0,  L1·sin(θ1) ]
[       0,         0,  1,           0  ]
[       0,         0,  0,           1  ]

T02 (simplified) =
[ cos(θ1+θ2),  -sin(θ1+θ2),  0,  L2·cos(θ1+θ2) + L1·cos(θ1) ]
[ sin(θ1+θ2),   cos(θ1+θ2),  0,  L2·sin(θ1+θ2) + L1·sin(θ1) ]
[           0,            0,  1,                             0  ]
[           0,            0,  0,                             1  ]
```

### Verification Test Results

| Test Case | θ1 | θ2 | L1 | L2 | x (computed) | x (expected) | y (computed) | y (expected) | Result |
|-----------|----|----|----|----|--------------|--------------|--------------|--------------|--------|
| Flat right | 0° | 0° | 1.0 | 0.5 | 1.5000 | 1.5000 | 0.0000 | 0.0000 | ✅ PASS |
| Standing up | 90° | 0° | 1.0 | 0.5 | 0.0000 | 0.0000 | 1.5000 | 1.5000 | ✅ PASS |

### Workspace Analysis (L1=1.0m, L2=0.6m)

```
Outer radius (max reach) : 1.600 m
Inner radius (min reach) : 0.400 m
Total points computed    : 129,600
Workspace shape          : Full annular ring (donut)
```

---

## 🧠 Key Concepts Learned

### 1. The DH Convention — Why it matters
Every robot in the world (ABB, KUKA, Fanuc, Universal Robots) can be described with DH parameters. It is the **universal language of robot geometry**. Mastering it means being able to model any serial robot.

### 2. Matrix Multiplication = Chaining Frames
```
T_total = T01 × T12 × ... × T(n-1,n)
```
Each multiplication adds one more link to the chain. Order matters — matrix multiplication is **not commutative**.

### 3. The Elbow Up / Elbow Down Problem
When `θ2 > 0`: elbow bends upward.  
When `θ2 < 0`: elbow bends downward.  
Both can sometimes reach the **same end-effector position** — this is why IK has **multiple solutions**.

### 4. Singularities
When `θ2 = ±180°`, Link 2 folds exactly onto Link 1. The robot loses one degree of freedom. This is a **singular configuration** — dangerous in real robots because:
- The Jacobian matrix becomes rank-deficient
- Infinite joint velocities may be required for finite end-effector velocity
- Real industrial robots have software limits to avoid singularities

### 5. Workspace Depends on Link Ratio
```
If L1 = L2  → inner radius = 0 → robot can touch its own base → full disk workspace
If L1 ≠ L2  → inner radius > 0 → there is a hole → annular ring workspace
```

---

## 📖 Vocabulary Reference

| 🇬🇧 English Term | 🇫🇷 French | Definition |
|---|---|---|
| Forward Kinematics (FK) | Cinématique directe | Angles → Position |
| Inverse Kinematics (IK) | Cinématique inverse | Position → Angles |
| Revolute joint | Articulation rotoïde | Rotational joint |
| End-Effector | Effecteur | The robot's working tip |
| Link | Segment / Bras | Rigid segment between joints |
| DH Convention | Convention de D-H | Standard robot description framework |
| Homogeneous matrix | Matrice homogène | 4×4 matrix encoding position + orientation |
| Workspace | Espace de travail | Set of all reachable end-effector positions |
| Singularity | Singularité | Configuration where a DOF is lost |
| Elbow up / down | Coude haut / bas | Two IK solutions for the same target |
| Pre-allocation | Pré-allocation | Reserve memory before filling a loop |
| Callback function | Fonction de rappel | Code triggered by a user interface event |
| Anonymous function | Fonction anonyme | Inline function defined with `@()` |
| Teach pendant | Pupitre d'apprentissage | Handheld robot controller in industry |

---

## 🏭 Industrial Context

This project directly maps to real industrial applications:

| This Project | Real Industry Equivalent |
|---|---|
| `fk_2R()` function | Robot controller firmware (runs at 1kHz) |
| Workspace map | Pre-installation feasibility study |
| App Designer GUI | Robot teach pendant (Fanuc, KUKA, ABB) |
| Elbow up/down | Configuration selection in robot programming |
| Singularity detection | Safety limits in industrial robot software |
| DH table | Robot datasheet / kinematic specification |

> Before installing any industrial robot, engineers simulate the **exact same analysis** done in this project to verify the robot can reach all required positions, avoid singularities, and fit within the workspace constraints of the production cell.

---

## 🚀 Next Steps

| Project | Topic | Builds On |
|---------|-------|-----------|
| **1.2** | FK of a real UR5 (6-axis) — URDF import, Jacobian, singularity detection | This project |
| **1.3** | Inverse Kinematics — analytical + Newton-Raphson | Project 1.1 + 1.2 |
| **1.4** | Robot Dynamics — Lagrange equations, torque computation | Project 1.1 |
| **1.5** | Delta parallel robot — Simscape Multibody | Project 1.1–1.4 |

---

## 📄 License

This project is part of an academic robotics portfolio.  
Free to use for educational and learning purposes.

---

<div align="center">

*Built with 💜 as part of a structured 20-project robotics learning journey*  
*MATLAB + Robotics System Toolbox + Symbolic Math Toolbox + App Designer*

**HoraEmbedded** — Electronics & Automation Systems Engineering

</div>