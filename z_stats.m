%% ==========================================================
% Average Measurement Model for 3 Robots
% ===========================================================

%% Load signals from Simulink output

z1_p = out.z_pred;
z1_a = out.z_actual;

z2_p = out.z_pred1;
z2_a = out.z_actual1;

z3_p = out.z_pred2;
z3_a = out.z_actual2;

%% ==========================================================
% Convert timeseries to numeric arrays if needed
% ==========================================================

signals = {z1_p,z1_a,z2_p,z2_a,z3_p,z3_a};

for k = 1:length(signals)

    if isa(signals{k},'timeseries')
        signals{k} = signals{k}.Data;
    end

end

[z1_p,z1_a,z2_p,z2_a,z3_p,z3_a] = signals{:};

%% ==========================================================
% Force column vectors
% ==========================================================

z1_p = squeeze(z1_p(:));
z1_a = squeeze(z1_a(:));

z2_p = squeeze(z2_p(:));
z2_a = squeeze(z2_a(:));

z3_p = squeeze(z3_p(:));
z3_a = squeeze(z3_a(:));

%% ==========================================================
% Ensure equal length
% ==========================================================

N = min([ ...
    length(z1_p), length(z1_a), ...
    length(z2_p), length(z2_a), ...
    length(z3_p), length(z3_a)]);

z1_p = z1_p(1:N);
z1_a = z1_a(1:N);

z2_p = z2_p(1:N);
z2_a = z2_a(1:N);

z3_p = z3_p(1:N);
z3_a = z3_a(1:N);

%% ==========================================================
% Average measurements
% ==========================================================

z_pred_avg = (z1_p + z2_p + z3_p)/3;

z_actual_avg = (z1_a + z2_a + z3_a)/3;

%% ==========================================================
% Compute average error
% ==========================================================

err_avg = z_actual_avg - z_pred_avg;

RMSE_avg = sqrt(mean(err_avg.^2));

MAE_avg = mean(abs(err_avg));

fprintf('\n');
fprintf('Average Measurement Statistics\n');
fprintf('------------------------------\n');
fprintf('RMSE = %.4f\n',RMSE_avg);
fprintf('MAE  = %.4f\n',MAE_avg);

%% ==========================================================
% Sample index
% ==========================================================

samples = 1:N;

%% ==========================================================
% Plot Average Measurements
% ==========================================================

figure;

plot(samples,z_pred_avg,...
    'b','LineWidth',1.5);

hold on;

plot(samples,z_actual_avg,...
    'r','LineWidth',1.5);

grid on;

title('Average Measurement Model of 3 Robots');

xlabel('Samples');

ylabel('Measurement');

legend('Average z_{pred}','Average z_{actual}',...
    'Location','best');

%% ==========================================================
% Plot Average Error
% ==========================================================

figure;

plot(samples,err_avg,...
    'k','LineWidth',1.5);

grid on;

title('Average Measurement Error');

xlabel('Samples');

ylabel('Error');

%% ==========================================================
% Error Distribution
% ==========================================================

figure;

histogram(err_avg,...
    'Normalization','pdf');

hold on;

mu = mean(err_avg);
sigma = std(err_avg);

x = linspace(min(err_avg),...
             max(err_avg),200);

plot(x,normpdf(x,mu,sigma),...
    'LineWidth',2);

grid on;

title('Average Error Distribution');

xlabel('Error');

ylabel('PDF');

legend('Histogram','Gaussian Fit');

%% ==========================================================
% Confidence Interval
% ==========================================================

sem = sigma/sqrt(length(err_avg));

CI95 = [ ...
    mu - 1.96*sem,...
    mu + 1.96*sem];

fprintf('Mean Error = %.4f\n',mu);
fprintf('STD        = %.4f\n',sigma);
fprintf('95%% CI     = [%.4f , %.4f]\n',...
        CI95(1),CI95(2));