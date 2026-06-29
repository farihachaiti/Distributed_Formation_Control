% =========================
% LOAD ALL DATASETS
% =========================
d1 = out.position_error2;
d2 = out.position_error8;
d3 = out.position_error11;

% =========================
% AVERAGE ACROSS DATASETS
% =========================
datax = (d1(1,:) + d2(1,:) + d3(1,:)) / 3;
datay = (d1(2,:) + d2(2,:) + d3(2,:)) / 3;

% =========================
% CDF PLOTS
% =========================
figure;

subplot(1,2,1);
cdfplot(datax);
title('AVERAGED X Error CDF');
grid on;

subplot(1,2,2);
cdfplot(datay);
title('AVERAGED Y Error CDF');
grid on;

% =========================
% PDF PLOTS (NO GAUSSIAN FIT)
% =========================
figure;

subplot(1,2,1);
histogram(datax, 'Normalization', 'pdf');
title('AVERAGED X Error PDF');
xlabel('Error X');
ylabel('Probability Density');
grid on;

subplot(1,2,2);
histogram(datay, 'Normalization', 'pdf');
title('AVERAGED Y Error PDF');
xlabel('Error Y');
ylabel('Probability Density');
grid on;

% =========================
% BOXPLOTS
% =========================
figure;

subplot(1,2,1);
boxplot(datax);
title('AVERAGED X Error Distribution');
grid on;

subplot(1,2,2);
boxplot(datay);
title('AVERAGED Y Error Distribution');
grid on;

% =========================
% CONFIDENCE INTERVALS
% =========================
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
title('AVERAGED X Mean & 95% CI');
yticks([]);
grid on;

subplot(1,2,2);
hold on;
plot(muy,1,'ro','LineWidth',2);
plot(CIy,[1 1],'b-','LineWidth',3);
xlim([min(datay) max(datay)]);
title('AVERAGED Y Mean & 95% CI');
yticks([]);
grid on;