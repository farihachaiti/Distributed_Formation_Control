% Extract time and error data
t  = out.position_error.Time;
ei = out.position_error.Data;

% reshape safely
ei = squeeze(ei);

% ensure column vector for scalar signal
if isrow(ei)
    ei = ei';
end

% now dimensions should match
t = t(:);

% interpolation
t_fine = linspace(t(1), t(end), 5000);
ei_interp = interp1(t, ei, t_fine, 'pchip');

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

plot(t, ei, 'b'); hold on;

xline(t_conv, '--r', 'Convergence Time', 'LineWidth', 2);
yline(threshold, ':k', 'Threshold = 0.9 m', 'LineWidth', 1.5);

title('Formation Error Norm vs Time');
xlabel('Time (s)');
ylabel('||e_i|| (m)');
grid on;

legend('Error Norm', 'Convergence Time', 'Threshold');



figure;
plot(t, ei, 'b'); hold on;
title('Formation Error Evolution over Time');
xlabel('Time (s)');
ylabel('||e_i||');
grid on;



mu = movmean(ei, 50);
sigma = movstd(ei, 50);

figure;
plot(t, ei, 'b'); hold on;
plot(t, mu, 'r', 'LineWidth', 2);
plot(t, mu + sigma, '--r');
plot(t, mu - sigma, '--r');

legend('Error','Mean','+1σ','-1σ');
title('Error with Uncertainty Band');
xlabel('Time (s)');
ylabel('Error (m)');
grid on;

title('Standard Deviation of Position Error Over Time');
xlabel('Time (s)');
ylabel('Std Dev (m)');
grid on;

ei_std = std(ei);
mean = mean(ei);
fprintf('Overall Mean = %.4f m\n', mean);
fprintf('Overall STD = %.4f m\n', ei_std);