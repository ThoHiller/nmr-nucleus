function C = getMengerCurvature(PP)

% log values are used
PP = log10(PP);

% get individual points
% x = error norm
% y = model norm
P1 = PP(1,:); x1 = P1(1); y1 = P1(2);
P2 = PP(2,:); x2 = P2(1); y2 = P2(2);
P3 = PP(3,:); x3 = P3(1); y3 = P3(2);

P1P2 = (x2-x1)^2 + (y2-y1)^2;
P2P3 = (x3-x2)^2 + (y3-y2)^2;
P3P1 = (x1-x3)^2 + (y1-y3)^2;

C = (2 * (x1*y2 + x2*y3 + x3*y1 - x1*y3 - x2*y1 - x3*y2)) / (sqrt(P1P2 * P2P3 * P3P1));

return