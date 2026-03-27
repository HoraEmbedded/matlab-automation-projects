function [x, y, T] = fk_2R(theta1, theta2, L1, L2)

    % Compute end-effector position
    x = L1*cos(theta1) + L2*cos(theta1 + theta2);
    y = L1*sin(theta1) + L2*sin(theta1 + theta2);

    % Compute full transformation matrix (numerical)
    T = [cos(theta1+theta2), -sin(theta1+theta2), 0, x;
         sin(theta1+theta2),  cos(theta1+theta2), 0, y;
                          0,                   0, 1, 0;
                          0,                   0, 0, 1];
end