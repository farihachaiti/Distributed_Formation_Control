% =========================
% LOAD DATA
% =========================
w1 = out.w;
w2 = out.w1;
w3 = out.w2;

t = w1.Time;   % assume same time base

% =========================
% EXTRACT AND FORMAT
% =========================
w1 = squeeze(w1.Data)';   % N x 3
w2 = squeeze(w2.Data)';   % N x 3
w3 = squeeze(w3.Data)';   % N x 3

% =========================
% AVERAGE ACROSS ROBOTS
% =========================
w_avg = (w1 + w2 + w3) / 3;

% remove NaNs if any
w_avg = fillmissing(w_avg,'linear');

% =========================
% INTERPOLATION (SMOOTH TIME)
% =========================
t_fine = linspace(min(t), max(t), 5000);

w_interp = interp1(t, w_avg, t_fine, 'pchip');

% =========================
% PLOT ONLY AVERAGED ω
% =========================
figure;

plot(t_fine, w_interp(:,1), 'LineWidth', 2); hold on;
plot(t_fine, w_interp(:,2), 'LineWidth', 2);
plot(t_fine, w_interp(:,3), 'LineWidth', 2);

title('AVERAGED Angular Velocity (3 Robots)');
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s)');
legend('\omega_x avg','\omega_y avg','\omega_z avg');
grid on;