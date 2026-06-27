t = out.position_error3.Time;

data = out.position_error3.Data;

datax = data(1,:);
datay = data(2,:);

datax = squeeze(datax);

% now transpose safely
datax = datax';

datay = squeeze(datay);

% now transpose safely
datay = datay';
figure;

plot(t, datax, 'b'); hold on;
plot(t, datay, 'r');

title('Formation Error Evolution (X and Y)');
xlabel('Time (s)');
ylabel('Error (m)');
grid on;

legend('X error','Y error');

% =========================
% LOAD DATA
% =========================
d3  = out.position_error3;
d10 = out.position_error10;
d13 = out.position_error13;

t = d3.Time;   % assume same time vector

% =========================
% EXTRACT DATA (X & Y)
% =========================
x3  = squeeze(d3.Data(1,:))';
y3  = squeeze(d3.Data(2,:))';

x10 = squeeze(d10.Data(1,:))';
y10 = squeeze(d10.Data(2,:))';

x13 = squeeze(d13.Data(1,:))';
y13 = squeeze(d13.Data(2,:))';

% =========================
% AVERAGE ACROSS RUNS
% =========================
x_avg = (x3 + x10 + x13) / 3;
y_avg = (y3 + y10 + y13) / 3;

% =========================
% PLOT ONLY AVERAGED RESULT
% =========================
figure;

plot(t, x_avg, 'b'); hold on;
plot(t, y_avg, 'r');

title('AVERAGED Formation Error Evolution over Time');
xlabel('Time (s)');
ylabel('Error (m)');
grid on;

legend('Avg X error','Avg Y error');