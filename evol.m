t = out.position_error.Time;

data = out.position_error.Data;

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