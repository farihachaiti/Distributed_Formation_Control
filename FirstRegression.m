clear all;
clc;

%% Sensor definition

% Sensor parameters
order = 3;
a = (rand(1,order)-0.5)*10;

% Time delta range
Dt.max = 10;
Dt.min = -10;

% Define the input data
dt = Dt.min:0.1:Dt.max;

% Number of samples
n = length(dt);

% Actual sensor readings
H_model = [];
for i=1:order
    H_model = [H_model, dt.^(i-1)'];
end
z = H_model*a';


%% Regression

% Testing points
m = 20;
dt_test = (rand(1,m)*(Dt.max - Dt.min)) + Dt.min;

% First order hypothesis
order_est = 2;

% Maximum tolerable fitting error
MaxTolError = 1e10;

MaxOrder = m;
for Ord = 2:MaxOrder

    % Reference with accurate sensor
    H_model_test = [];
    for i=1:order
        H_model_test = [H_model_test, dt_test.^(i-1)'];
    end
    z_test = H_model_test*a(1:order)';

    % Go with the regression!!
    H = [];
    for i=1:Ord
        H = [H, dt_test.^(i-1)'];
    end

    % Solve the regression
    a_est = inv(H'*H)*H'*z_test;

    % Squared Error
    Error = (z_test - H*a_est)'*(z_test - H*a_est)/m;
    if Error < MaxTolError
        break;
    end
end



%% Plot

figure(1), clf, hold on;
axis tight

plot(dt, z, 'b', 'LineStyle', ":");

grid on;
set(gca, 'FontSize', 10);
z_est = H_model(:,1:Ord)*a_est;
plot(dt, z_est, 'r', 'LineStyle', "--");
legend('Actual', 'Estimated', 'Location', 'best');


size(dt)
size(z)

a

Ord

order
Error
