% =========================
% LOAD DATA
% =========================
e1 = out.position_error1;
e5 = out.position_error5;
e7 = out.position_error7;

% =========================
% FORCE VECTOR FORMAT
% (handles row/column safely)
% =========================
e1 = e1(:);
e5 = e5(:);
e7 = e7(:);

% =========================
% COMBINE ALL DATA
% =========================
error_signed = [e1; e5; e7];

% remove NaN or Inf (important in Simulink logs)
%error_signed = error_signed(~isnan(error_signed) & ~isinf(error_signed));

error_abs = abs(error_signed);

% =========================
% PLOTS
% =========================
figure;

subplot(1,2,1);
cdfplot(error_abs);
title('Error Norm (|Error|) - Averaged');
xlabel('|Error|');
ylabel('Cumulative Probability');
grid on;

subplot(1,2,2);
cdfplot(error_signed);
title('Signed Error - Averaged');
xlabel('Error');
ylabel('Cumulative Probability');
grid on;

% =========================
% STATS
% =========================
fprintf('Mean signed error: %.4f\n', mean(error_signed));
fprintf('Mean absolute error: %.4f\n', mean(error_abs));