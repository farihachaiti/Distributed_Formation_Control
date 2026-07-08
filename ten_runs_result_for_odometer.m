%% ==========================================================
% RUN SIMULINK 10 TIMES AND STORE DATA
%% ==========================================================

N_runs = 10;

%% Pre-allocate storage cell arrays
stored = cell(N_runs, 1);

for run = 1:N_runs
    fprintf('\n--- Run %d / %d ---\n', run, N_runs);

    %% ---- Run Simulink model ----
    out = sim('distributed_project_triangle_adjusted_2.slx');

    %% ---- Store all signals from this run ----
    stored{run} = out;
end

%% ==========================================================
% AVERAGE FORMATION ERROR OF 3 ROBOTS — 10 RUNS
%% ==========================================================

t = stored{1}.position_error.Time;
t = t(:);
N_max = length(t);

ei_sum = zeros(N_max, 1);
e1_sum = zeros(N_max, 1);
e2_sum = zeros(N_max, 1);
e3_sum = zeros(N_max, 1);

for r = 1:N_runs
    e1 = squeeze(stored{r}.position_error.Data(:));
    e2 = squeeze(stored{r}.position_error4.Data(:));
    e3 = squeeze(stored{r}.position_error6.Data(:));

    N = min([length(e1), length(e2), length(e3), N_max]);

    e1 = e1(1:N);
    e2 = e2(1:N);
    e3 = e3(1:N);

    ei_sum(1:N) = ei_sum(1:N) + (e1 + e2 + e3) / 3;
    e1_sum(1:N) = e1_sum(1:N) + e1;
    e2_sum(1:N) = e2_sum(1:N) + e2;
    e3_sum(1:N) = e3_sum(1:N) + e3;
end

ei = ei_sum / N_runs;
e1 = e1_sum / N_runs;
e2 = e2_sum / N_runs;
e3 = e3_sum / N_runs;
t  = t(1:N_max);

%% ==========================================================
% Convergence analysis
%% ==========================================================
threshold = 1e-5;
idx_conv  = find(ei < threshold, 1, 'first');

if isempty(idx_conv)
    error('System never converged below threshold.');
end

t_conv_initial = t(idx_conv);

%% ==========================================================
% Steady-state RMSE
%% ==========================================================
ei_steady   = ei(idx_conv:end);
RMSE_steady = sqrt(mean(ei_steady.^2));

fprintf('\n');
mean_steady = mean(ei_steady);
std_steady = std(ei_steady);
fprintf('Average Formation Error Statistics\n');
fprintf('----------------------------------\n');
fprintf('Initial Convergence Time = %.3f s\n', t_conv_initial);
fprintf('Steady-State RMSE        = %.4f m\n', RMSE_steady);
fprintf('Steady-State Mean        = %.4f m\n', mean_steady);
fprintf('Steady-State std        = %.4f m\n', std_steady);


%% ==========================================================
% Moving mean convergence
%% ==========================================================
window = 50;
mu     = movmean(ei, window);
sigma  = movstd(ei, window);

Treq = 1;
dt   = t(2) - t(1);
Nreq = round(Treq / dt);
below = mu < threshold;

conv_idx = NaN;
for k = 1:length(below)-Nreq
    if all(below(k:k+Nreq-1))
        conv_idx = k;
        break;
    end
end

%% ==========================================================
% Global statistics
%% ==========================================================
overall_mean = mean(ei);
overall_std  = std(ei);

fprintf('Overall Mean Error      = %.4f m\n', overall_mean);
fprintf('Overall STD             = %.4f m\n', overall_std);

%% ==========================================================
% Plot 1
%% ==========================================================
figure;
plot(t, ei, 'b', 'LineWidth', 1.5); hold on;
xline(t_conv_initial, '--r', 'Convergence Time', 'LineWidth', 2);
yline(threshold,       ':k', 'Threshold',         'LineWidth', 1.5);
title('Average Formation Error');
xlabel('Time (s)');
ylabel('Average Error (m)');
legend('Average Error', 'Convergence Time', 'Threshold');
grid on;

%% ==========================================================
% Plot 2
%% ==========================================================
figure;
plot(t, e1, 'r'); hold on;
plot(t, e2, 'g');
plot(t, e3, 'b');
plot(t, ei, 'k', 'LineWidth', 2);
title('Robot Formation Errors');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Robot 1', 'Robot 2', 'Robot 3', 'Average');
grid on;

%% ==========================================================
% Plot 3
%% ==========================================================
figure;
plot(t, ei, 'b'); hold on;
plot(t, mu, 'r', 'LineWidth', 2);
plot(t, mu + sigma, '--r');
plot(t, mu - sigma, '--r');
title('Average Error with Uncertainty Band');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Error', 'Mean', '+1\sigma', '-1\sigma');
grid on;

%% ==========================================================
% Plot 4 - Histogram
%% ==========================================================
figure;
histogram(ei, 'Normalization', 'pdf'); hold on;
x = linspace(min(ei), max(ei), 200);
plot(x, normpdf(x, mean(ei), std(ei)), 'LineWidth', 2);
title('Average Error Distribution');
xlabel('Error (m)');
ylabel('PDF');
legend('Histogram', 'Gaussian Fit');
grid on;

%% ==========================================================
% 95% Confidence Interval
%% ==========================================================
sem  = std(ei) / sqrt(length(ei));
CI95 = [mean(ei) - 1.96*sem,  mean(ei) + 1.96*sem];
fprintf('95%% Confidence Interval = [%.4f , %.4f]\n', CI95(1), CI95(2));


%% ==========================================================
% AVERAGED VELOCITY — 10 RUNS
%% ==========================================================
tv = stored{1}.v.Time;
Nv = length(tv);
v_avg_sum = zeros(Nv, 3);

for r = 1:N_runs
    v1 = squeeze(stored{r}.v.Data)';
    v2 = squeeze(stored{r}.v1.Data)';
    v3 = squeeze(stored{r}.v2.Data)';
    Nr = min([size(v1,1), size(v2,1), size(v3,1), Nv]);
    v_avg_sum(1:Nr,:) = v_avg_sum(1:Nr,:) + (v1(1:Nr,:) + v2(1:Nr,:) + v3(1:Nr,:)) / 3;
end
v_avg = v_avg_sum / N_runs;

t_fine   = linspace(min(tv), max(tv), 5000);
v_interp = interp1(tv, v_avg, t_fine, 'pchip');

figure;
plot(t_fine, v_interp(:,1), 'LineWidth', 2); hold on;
plot(t_fine, v_interp(:,2), 'LineWidth', 2);
plot(t_fine, v_interp(:,3), 'LineWidth', 2);
title('AVERAGED Velocity (3 Robots)');
xlabel('Time (s)');
ylabel('Velocity (m/s)');
legend('Vx avg', 'Vy avg', 'Vz avg');
grid on;


%% ==========================================================
% AVERAGE MEASUREMENT MODEL — 10 RUNS
%% ==========================================================
sig0 = stored{1}.z_pred;
if isa(sig0, 'timeseries'), sig0 = sig0.Data; end
Nm = length(squeeze(sig0(:)));

zp_sum = zeros(Nm, 1);
za_sum = zeros(Nm, 1);

for r = 1:N_runs
    zp1 = stored{r}.z_pred;    if isa(zp1,'timeseries'), zp1=zp1.Data; end; zp1=squeeze(zp1(:));
    za1 = stored{r}.z_actual;  if isa(za1,'timeseries'), za1=za1.Data; end; za1=squeeze(za1(:));
    zp2 = stored{r}.z_pred1;   if isa(zp2,'timeseries'), zp2=zp2.Data; end; zp2=squeeze(zp2(:));
    za2 = stored{r}.z_actual1; if isa(za2,'timeseries'), za2=za2.Data; end; za2=squeeze(za2(:));
    zp3 = stored{r}.z_pred2;   if isa(zp3,'timeseries'), zp3=zp3.Data; end; zp3=squeeze(zp3(:));
    za3 = stored{r}.z_actual2; if isa(za3,'timeseries'), za3=za3.Data; end; za3=squeeze(za3(:));

    Nr = min([length(zp1),length(za1),length(zp2),length(za2),length(zp3),length(za3),Nm]);
    zp_sum(1:Nr) = zp_sum(1:Nr) + (zp1(1:Nr) + zp2(1:Nr) + zp3(1:Nr)) / 3;
    za_sum(1:Nr) = za_sum(1:Nr) + (za1(1:Nr) + za2(1:Nr) + za3(1:Nr)) / 3;
end

z_pred_avg   = zp_sum / N_runs;
z_actual_avg = za_sum / N_runs;
err_avg      = z_actual_avg - z_pred_avg;

RMSE_avg = sqrt(mean(err_avg.^2));
MAE_avg  = mean(abs(err_avg));

fprintf('\n');
fprintf('Average Measurement Statistics\n');
fprintf('------------------------------\n');
fprintf('RMSE = %.4f\n', RMSE_avg);
fprintf('MAE  = %.4f\n', MAE_avg);

samples = 1:Nm;

figure;
plot(samples, z_pred_avg,   'b', 'LineWidth', 1.5); hold on;
plot(samples, z_actual_avg, 'r', 'LineWidth', 1.5);
grid on;
title('Average Measurement Model of 3 Robots');
xlabel('Samples');
ylabel('Measurement');
legend('Average z_{pred}', 'Average z_{actual}', 'Location', 'best');

figure;
plot(samples, err_avg, 'k', 'LineWidth', 1.5);
grid on;
title('Average Measurement Error');
xlabel('Samples');
ylabel('Error');

mu_err    = mean(err_avg);
sigma_err = std(err_avg);

figure;
histogram(err_avg, 'Normalization', 'pdf'); hold on;
x = linspace(min(err_avg), max(err_avg), 200);
plot(x, normpdf(x, mu_err, sigma_err), 'LineWidth', 2);
grid on;
title('Average Error Distribution');
xlabel('Error');
ylabel('PDF');
legend('Histogram', 'Gaussian Fit');

sem_err  = sigma_err / sqrt(length(err_avg));
CI95_err = [mu_err - 1.96*sem_err,  mu_err + 1.96*sem_err];
fprintf('Mean Error = %.4f\n', mu_err);
fprintf('STD        = %.4f\n', sigma_err);
fprintf('95%% CI     = [%.4f , %.4f]\n', CI95_err(1), CI95_err(2));


%% ==========================================================
% CDF / PDF / BOXPLOT / CI — X & Y — 10 RUNS
%% ==========================================================
Nc = size(stored{1}.position_error2, 2);
datax_sum = zeros(1, Nc);
datay_sum = zeros(1, Nc);

for r = 1:N_runs
    d1 = stored{r}.position_error2;
    d2 = stored{r}.position_error8;
    d3 = stored{r}.position_error11;
    datax_sum = datax_sum + (d1(1,:) + d2(1,:) + d3(1,:)) / 3;
    datay_sum = datay_sum + (d1(2,:) + d2(2,:) + d3(2,:)) / 3;
end
datax = datax_sum / N_runs;
datay = datay_sum / N_runs;

figure;
subplot(1,2,1); cdfplot(datax); title('AVERAGED X Error CDF'); grid on;
subplot(1,2,2); cdfplot(datay); title('AVERAGED Y Error CDF'); grid on;

figure;
subplot(1,2,1);
histogram(datax, 'Normalization', 'pdf');
title('AVERAGED X Error PDF'); xlabel('Error X'); ylabel('Probability Density'); grid on;
subplot(1,2,2);
histogram(datay, 'Normalization', 'pdf');
title('AVERAGED Y Error PDF'); xlabel('Error Y'); ylabel('Probability Density'); grid on;

figure;
subplot(1,2,1); boxplot(datax); title('AVERAGED X Error Distribution'); grid on;
subplot(1,2,2); boxplot(datay); title('AVERAGED Y Error Distribution'); grid on;

mux  = mean(datax); muy  = mean(datay);
semx = std(datax)/sqrt(length(datax));
semy = std(datay)/sqrt(length(datay));
CIx  = [mux - 1.96*semx,  mux + 1.96*semx];
CIy  = [muy - 1.96*semy,  muy + 1.96*semy];

figure;
subplot(1,2,1); hold on;
plot(mux, 1, 'ro', 'LineWidth', 2);
plot(CIx, [1 1], 'b-', 'LineWidth', 3);
xlim([min(datax) max(datax)]); title('AVERAGED X Mean & 95% CI'); yticks([]); grid on;
subplot(1,2,2); hold on;
plot(muy, 1, 'ro', 'LineWidth', 2);
plot(CIy, [1 1], 'b-', 'LineWidth', 3);
xlim([min(datay) max(datay)]); title('AVERAGED Y Mean & 95% CI'); yticks([]); grid on;


%% ==========================================================
% FORMATION ERROR EVOLUTION X & Y — position_error3 — 10 RUNS
%% ==========================================================
t_pe3 = stored{1}.position_error3.Time;
Np    = length(t_pe3);
xavg3_sum = zeros(Np, 1);
yavg3_sum = zeros(Np, 1);

for r = 1:N_runs
    xv = squeeze(stored{r}.position_error3.Data(1,:))';
    yv = squeeze(stored{r}.position_error3.Data(2,:))';
    Nr = min([length(xv), length(yv), Np]);
    xavg3_sum(1:Nr) = xavg3_sum(1:Nr) + xv(1:Nr);
    yavg3_sum(1:Nr) = yavg3_sum(1:Nr) + yv(1:Nr);
end
xavg3 = xavg3_sum / N_runs;
yavg3 = yavg3_sum / N_runs;

figure;
plot(t_pe3, xavg3, 'b'); hold on;
plot(t_pe3, yavg3, 'r');
title('Formation Error Evolution (X and Y)');
xlabel('Time (s)');
ylabel('Error (m)');
legend('X error', 'Y error');
grid on;


%% ==========================================================
% AVERAGED FORMATION ERROR — position_error3/10/13 — 10 RUNS
%% ==========================================================
t_d = stored{1}.position_error3.Time;
Nd  = length(t_d);
x_avg_sum = zeros(Nd, 1);
y_avg_sum = zeros(Nd, 1);

for r = 1:N_runs
    x3v  = squeeze(stored{r}.position_error3.Data(1,:))';
    y3v  = squeeze(stored{r}.position_error3.Data(2,:))';
    x10v = squeeze(stored{r}.position_error10.Data(1,:))';
    y10v = squeeze(stored{r}.position_error10.Data(2,:))';
    x13v = squeeze(stored{r}.position_error13.Data(1,:))';
    y13v = squeeze(stored{r}.position_error13.Data(2,:))';

    Nr = min([length(x3v),length(y3v),length(x10v),length(y10v),length(x13v),length(y13v),Nd]);
    x_avg_sum(1:Nr) = x_avg_sum(1:Nr) + (x3v(1:Nr) + x10v(1:Nr) + x13v(1:Nr)) / 3;
    y_avg_sum(1:Nr) = y_avg_sum(1:Nr) + (y3v(1:Nr) + y10v(1:Nr) + y13v(1:Nr)) / 3;
end
x_avg_d = x_avg_sum / N_runs;
y_avg_d = y_avg_sum / N_runs;

figure;
plot(t_d, x_avg_d, 'b'); hold on;
plot(t_d, y_avg_d, 'r');
title('AVERAGED Formation Error Evolution over Time');
xlabel('Time (s)');
ylabel('Error (m)');
legend('Avg X error', 'Avg Y error');
grid on;


%% ==========================================================
% AVERAGED ANGULAR VELOCITY — 10 RUNS
%% ==========================================================
tw = stored{1}.w.Time;
Nw = length(tw);
w_avg_sum = zeros(Nw, 3);

for r = 1:N_runs
    w1 = squeeze(stored{r}.w.Data)';
    w2 = squeeze(stored{r}.w1.Data)';
    w3 = squeeze(stored{r}.w2.Data)';
    Nr = min([size(w1,1), size(w2,1), size(w3,1), Nw]);
    w_avg_sum(1:Nr,:) = w_avg_sum(1:Nr,:) + (w1(1:Nr,:) + w2(1:Nr,:) + w3(1:Nr,:)) / 3;
end
w_avg = fillmissing(w_avg_sum / N_runs, 'linear');

t_fine_w = linspace(min(tw), max(tw), 5000);
w_interp  = interp1(tw, w_avg, t_fine_w, 'pchip');

figure;
plot(t_fine_w, w_interp(:,1), 'LineWidth', 2); hold on;
plot(t_fine_w, w_interp(:,2), 'LineWidth', 2);
plot(t_fine_w, w_interp(:,3), 'LineWidth', 2);
title('AVERAGED Angular Velocity (3 Robots)');
xlabel('Time (s)');
ylabel('Angular Velocity (rad/s)');
legend('\omega_x avg', '\omega_y avg', '\omega_z avg');
grid on;