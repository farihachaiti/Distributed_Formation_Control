%% ── Extract and average per-channel (x, y, theta) across runs ──────────────

% Get length from first run, first robot, first channel
sig0 = stored{1}.z_pred;
if isa(sig0, 'timeseries'), sig0 = sig0.Data; end
sig0 = squeeze(sig0(:));
Nm   = length(sig0);  % total samples (3 channels × time flattened)
Nt   = Nm / 3;        % number of timesteps (assumes [x;y;theta] stacked)

% Storage: rows=timesteps, cols=channels [x, y, theta]
zp_sum = zeros(Nt, 3);
za_sum = zeros(Nt, 3);

for r = 1:N_runs

    % ── Robot 1 ──────────────────────────────────────────────────────────
    zp1 = stored{r}.z_pred;    if isa(zp1,'timeseries'), zp1=zp1.Data; end
    za1 = stored{r}.z_actual;  if isa(za1,'timeseries'), za1=za1.Data; end

    % ── Robot 2 ──────────────────────────────────────────────────────────
    zp2 = stored{r}.z_pred1;   if isa(zp2,'timeseries'), zp2=zp2.Data; end
    za2 = stored{r}.z_actual1; if isa(za2,'timeseries'), za2=za2.Data; end

    % ── Robot 3 ──────────────────────────────────────────────────────────
    zp3 = stored{r}.z_pred2;   if isa(zp3,'timeseries'), zp3=zp3.Data; end
    za3 = stored{r}.z_actual2; if isa(za3,'timeseries'), za3=za3.Data; end

    % ── Reshape each signal to [Nt x 3] ──────────────────────────────────
    % Adjust reshape order to match how your Simulink block stacks [x;y;theta]
    zp1 = reshape(squeeze(zp1(:)), 3, [])';   % [Nt x 3]
    za1 = reshape(squeeze(za1(:)), 3, [])';
    zp2 = reshape(squeeze(zp2(:)), 3, [])';
    za2 = reshape(squeeze(za2(:)), 3, [])';
    zp3 = reshape(squeeze(zp3(:)), 3, [])';
    za3 = reshape(squeeze(za3(:)), 3, [])';

    Nr = min([size(zp1,1), size(za1,1), size(zp2,1), ...
              size(za2,1), size(zp3,1), size(za3,1), Nt]);

    % ── Average across 3 robots, accumulate across runs ───────────────────
    zp_sum(1:Nr, :) = zp_sum(1:Nr, :) + (zp1(1:Nr,:) + zp2(1:Nr,:) + zp3(1:Nr,:)) / 3;
    za_sum(1:Nr, :) = za_sum(1:Nr, :) + (za1(1:Nr,:) + za2(1:Nr,:) + za3(1:Nr,:)) / 3;

    % ── Wrap theta channel to (-pi, pi] to avoid spike artifacts ─────────
    zp_sum(1:Nr, 3) = atan2(sin(zp_sum(1:Nr,3)), cos(zp_sum(1:Nr,3)));
    za_sum(1:Nr, 3) = atan2(sin(za_sum(1:Nr,3)), cos(za_sum(1:Nr,3)));
end

% ── Divide by number of runs to get true average ─────────────────────────────
z_pred_avg   = zp_sum / N_runs;    % [Nt x 3]
z_actual_avg = za_sum / N_runs;    % [Nt x 3]

% ── Per-channel error ─────────────────────────────────────────────────────────
err_avg = z_actual_avg - z_pred_avg;   % [Nt x 3]

% Wrap theta error too
err_avg(:,3) = atan2(sin(err_avg(:,3)), cos(err_avg(:,3)));

channel_names  = {'x',      'y',      '\theta'};
channel_units  = {'m',      'm',      'rad'};
channel_colors = {'b',      'r',      'k'};
samples        = 1:Nt;

%% ── Figure 1: z_pred vs z_actual — one subplot per channel ──────────────────
figure('Name', 'Measurement Model per Channel', 'NumberTitle', 'off');
for c = 1:3
    subplot(3,1,c);
    plot(samples, z_pred_avg(:,c),   'b', 'LineWidth', 1.5, 'DisplayName', 'z_{pred}');
    hold on;
    plot(samples, z_actual_avg(:,c), 'r', 'LineWidth', 1.5, 'DisplayName', 'z_{actual}');
    grid on;
    ylabel(sprintf('%s  (%s)', channel_names{c}, channel_units{c}));
    legend('Location', 'best');
    if c == 1
        title('Average Measurement Model — 3 Robots');
    end
    if c == 3
        xlabel('Samples');
    end
end

%% ── Figure 2: Error per channel ──────────────────────────────────────────────
figure('Name', 'Measurement Error per Channel', 'NumberTitle', 'off');
for c = 1:3
    subplot(3,1,c);
    plot(samples, err_avg(:,c), channel_colors{c}, 'LineWidth', 1.2);
    grid on;
    yline(0, 'k--', 'LineWidth', 0.8);
    ylabel(sprintf('e_%s  (%s)', channel_names{c}, channel_units{c}));
    if c == 1
        title('Average Measurement Error per Channel');
    end
    if c == 3
        xlabel('Samples');
    end
end

%% ── Figure 3: Error histogram + Gaussian fit per channel ─────────────────────
figure('Name', 'Error Distribution per Channel', 'NumberTitle', 'off');
for c = 1:3
    subplot(3,1,c);
    mu_c    = mean(err_avg(:,c));
    sigma_c = std(err_avg(:,c));
    histogram(err_avg(:,c), 40, 'Normalization', 'pdf', ...
              'FaceColor', channel_colors{c}, 'FaceAlpha', 0.4);
    hold on;
    xv = linspace(min(err_avg(:,c)), max(err_avg(:,c)), 300);
    plot(xv, normpdf(xv, mu_c, sigma_c), 'k-', 'LineWidth', 2);
    grid on;
    xlabel(sprintf('Error  (%s)', channel_units{c}));
    ylabel('PDF');
    legend('Histogram', 'Gaussian Fit', 'Location', 'best');
    title(sprintf('Channel: %s  |  \\mu=%.4f %s   \\sigma=%.4f %s', ...
          channel_names{c}, mu_c, channel_units{c}, sigma_c, channel_units{c}));
end

%% ── Statistics table per channel ─────────────────────────────────────────────
fprintf('\nAverage Measurement Statistics — per channel\n');
fprintf('%-10s  %-8s  %-8s  %-10s  %-10s  %-30s\n', ...
        'Channel','RMSE','MAE','Mean Err','STD','95% CI');
fprintf('%s\n', repmat('-',1,76));

for c = 1:3
    e        = err_avg(:,c);
    rmse_c   = sqrt(mean(e.^2));
    mae_c    = mean(abs(e));
    mu_c     = mean(e);
    sigma_c  = std(e);
    n        = length(e);
    ci       = mu_c + [-1, 1] * 1.96 * sigma_c / sqrt(n);

    fprintf('%-10s  %-8.4f  %-8.4f  %-10.4f  %-10.4f  [%-8.4f , %-8.4f]  %s\n', ...
            channel_names{c}, rmse_c, mae_c, mu_c, sigma_c, ci(1), ci(2), channel_units{c});
end