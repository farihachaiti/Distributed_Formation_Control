%% ==========================================================
% AVERAGE FORMATION ERROR OF 3 ROBOTS
%% ==========================================================

%% Extract data

e1 = out.position_error.Data;
e2 = out.position_error4.Data;
e3 = out.position_error6.Data;

t  = out.position_error.Time;

%% Convert to column vectors

e1 = squeeze(e1(:));
e2 = squeeze(e2(:));
e3 = squeeze(e3(:));

t  = t(:);

%% Ensure equal lengths

N = min([length(e1),length(e2),length(e3)]);

e1 = e1(1:N);
e2 = e2(1:N);
e3 = e3(1:N);
t  = t(1:N);

%% ==========================================================
% Average error
%% ==========================================================

ei = (e1 + e2 + e3)/3;

%% ==========================================================
% Convergence analysis
%% ==========================================================

threshold = 1e-5;

idx_conv = find(ei < threshold,1,'first');

if isempty(idx_conv)
    error('System never converged below threshold.');
end

t_conv_initial = t(idx_conv);

%% ==========================================================
% Steady-state RMSE
%% ==========================================================

ei_steady = ei(idx_conv:end);

RMSE_steady = sqrt(mean(ei_steady.^2));

fprintf('\n');
fprintf('Average Formation Error Statistics\n');
fprintf('----------------------------------\n');
fprintf('Initial Convergence Time = %.3f s\n',t_conv_initial);
fprintf('Steady-State RMSE        = %.4f m\n',RMSE_steady);

%% ==========================================================
% Moving mean convergence
%% ==========================================================

window = 50;

mu = movmean(ei,window);
sigma = movstd(ei,window);

Treq = 1;                   % seconds
dt = t(2)-t(1);

Nreq = round(Treq/dt);

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

overall_std = std(ei);

fprintf('Overall Mean Error      = %.4f m\n',overall_mean);
fprintf('Overall STD             = %.4f m\n',overall_std);

%% ==========================================================
% Plot 1
%% ==========================================================

figure;

plot(t,ei,'b','LineWidth',1.5);
hold on;

xline(t_conv_initial,...
    '--r',...
    'Convergence Time',...
    'LineWidth',2);

yline(threshold,...
    ':k',...
    'Threshold',...
    'LineWidth',1.5);

title('Average Formation Error');

xlabel('Time (s)');

ylabel('Average Error (m)');

legend('Average Error',...
       'Convergence Time',...
       'Threshold');

grid on;

%% ==========================================================
% Plot 2
%% ==========================================================

figure;

plot(t,e1,'r');
hold on;

plot(t,e2,'g');

plot(t,e3,'b');

plot(t,ei,...
    'k',...
    'LineWidth',2);

title('Robot Formation Errors');

xlabel('Time (s)');

ylabel('Error (m)');

legend('Robot 1',...
       'Robot 2',...
       'Robot 3',...
       'Average');

grid on;

%% ==========================================================
% Plot 3
%% ==========================================================

figure;

plot(t,ei,'b');

hold on;

plot(t,mu,...
    'r',...
    'LineWidth',2);

plot(t,mu+sigma,'--r');

plot(t,mu-sigma,'--r');

title('Average Error with Uncertainty Band');

xlabel('Time (s)');

ylabel('Error (m)');

legend('Error',...
       'Mean',...
       '+1\sigma',...
       '-1\sigma');

grid on;

%% ==========================================================
% Plot 4 - Histogram
%% ==========================================================

figure;

histogram(ei,...
    'Normalization','pdf');

hold on;

x = linspace(min(ei),max(ei),200);

plot(x,...
     normpdf(x,mean(ei),std(ei)),...
     'LineWidth',2);

title('Average Error Distribution');

xlabel('Error (m)');

ylabel('PDF');

legend('Histogram',...
       'Gaussian Fit');

grid on;

%% ==========================================================
% 95% Confidence Interval
%% ==========================================================

sem = std(ei)/sqrt(length(ei));

CI95 = [ ...
    mean(ei)-1.96*sem ...
    mean(ei)+1.96*sem ];

fprintf('95%% Confidence Interval = [%.4f , %.4f]\n',...
        CI95(1),CI95(2));