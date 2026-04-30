t = out.v.Time;        % 1001x1
vel = out.v.Data;       % 3x1001

vel = squeeze(vel)';     % NOW: 1001x3  ✔ correct format

t_fine = linspace(min(t), max(t), 5000);

vel_interp = interp1(t, vel, t_fine, 'pchip');

figure;

plot(t_fine, vel_interp(:,1), 'LineWidth', 2);
hold on;
plot(t_fine, vel_interp(:,2), 'LineWidth', 2);
plot(t_fine, vel_interp(:,3), 'LineWidth', 2);

title('Angu Components vs Time');
xlabel('Time (s)');
ylabel('Velocity (m)');
legend('Wx','Wy','Wz');
grid on;