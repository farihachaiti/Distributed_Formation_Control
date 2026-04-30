data = out.position_error;


datax = data(1,:);
datay = data(2,:);
figure;

subplot(1,2,1);
cdfplot(datax);
title('CDF of X Error');
grid on;

subplot(1,2,2);
cdfplot(datay);
title('CDF of Y Error');
grid on;

figure;

subplot(1,2,1);
histogram(datax, 'Normalization', 'pdf');
hold on;

mux = mean(datax);
sigmax = std(datax);

x = linspace(min(datax), max(datax), 100);
plot(x, normpdf(x, mux, sigmax), 'LineWidth', 2);

title('PDF of X Error');
xlabel('Error X');
ylabel('Probability Density');
grid on;
legend('Histogram','Gaussian Fit');


subplot(1,2,2);
histogram(datay, 'Normalization', 'pdf');
hold on;

muy = mean(datay);
sigmay = std(datay);

y = linspace(min(datay), max(datay), 100);
plot(y, normpdf(y, muy, sigmay), 'LineWidth', 2);

title('PDF of Y Error');
xlabel('Error Y');
ylabel('Probability Density');
grid on;
legend('Histogram','Gaussian Fit');

figure;

subplot(1,2,1);
boxplot(datax);
title('X Error Distribution');
grid on;

subplot(1,2,2);
boxplot(datay);
title('Y Error Distribution');
grid on;


mux = mean(datax);
muy = mean(datay);

semx = std(datax)/sqrt(length(datax));
semy = std(datay)/sqrt(length(datay));

CIx = [mux - 1.96*semx, mux + 1.96*semx];
CIy = [muy - 1.96*semy, muy + 1.96*semy];

figure;

subplot(1,2,1);
hold on;
plot(mux,1,'ro','LineWidth',2);
plot(CIx,[1 1],'b-','LineWidth',3);
xlim([min(datax) max(datax)]);
title('X Mean & 95% CI');
yticks([]);
grid on;

subplot(1,2,2);
hold on;
plot(muy,1,'ro','LineWidth',2);
plot(CIy,[1 1],'b-','LineWidth',3);
xlim([min(datay) max(datay)]);
title('Y Mean & 95% CI');
yticks([]);
grid on;