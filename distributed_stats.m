% Extract time and error data
t  = out.position_error.Time;
ei = squeeze(out.position_error.Data);

threshold = 0.5;

% --- convergence condition ---
if size(ei,2) > 1
    idx_conv = find(all(ei < threshold, 2), 1, 'first');
else
    idx_conv = find(ei < threshold, 1, 'first');
end

if isempty(idx_conv)
    error('System never converged below threshold.');
end

% Convergence time
t_conv = t(idx_conv);

% Steady-state segment
ei_steady = ei(idx_conv:end,:);

% RMSE steady-state
RMSE_steady = sqrt(mean(ei_steady(:).^2));

fprintf('Convergence Time = %.3f s\n', t_conv);
fprintf('Steady-State RMSE = %.4f m\n', RMSE_steady);

% -------------------------------
% Plot
% -------------------------------
figure;

plot(t, ei, 'LineWidth', 1.5);
hold on;

xline(t_conv, '--r', 'Convergence Time', 'LineWidth', 2);
yline(threshold, ':k', 'Threshold = 0.9 m', 'LineWidth', 1.5);

title('Formation Error Norm vs Time');
xlabel('Time (s)');
ylabel('||e_i|| (m)');
grid on;

legend('Error Norm', 'Convergence Time', 'Threshold');