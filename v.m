% =========================
% LOAD DATA
% =========================
v1 = out.v;
v2 = out.v1;
v3 = out.v2;

t = v1.Time;   % assume same time base

% =========================
% EXTRACT AND FORMAT
% =========================
v1 = squeeze(v1.Data)';   % N x 3
v2 = squeeze(v2.Data)';   % N x 3
v3 = squeeze(v3.Data)';   % N x 3

% =========================
% AVERAGE ACROSS ROBOTS
% =========================
v_avg = (v1 + v2 + v3) / 3;

% =========================
% INTERPOLATION (SMOOTH TIME)
% =========================
t_fine = linspace(min(t), max(t), 5000);

v_interp = interp1(t, v_avg, t_fine, 'pchip');

% =========================
% PLOT ONLY AVERAGED VELOCITY
% =========================
figure;

plot(t_fine, v_interp(:,1), 'LineWidth', 2); hold on;
plot(t_fine, v_interp(:,2), 'LineWidth', 2);
plot(t_fine, v_interp(:,3), 'LineWidth', 2);

title('AVERAGED Velocity (3 Robots)');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
legend('Vx avg','Vy avg','Vz avg');
grid on;