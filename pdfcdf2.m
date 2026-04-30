% Get signed error
error_signed = out.position_error;

% Compare distributions
figure;
cdfplot(abs(error_signed));
title('Error Norm (Magnitude)');
xlabel('|Error|');
ylabel('Cumulative Probability');

subplot(1,2,2);
cdfplot(error_signed);
title('Signed Error');
xlabel('Error');
ylabel('Cumulative Probability');
grid on;

% Check for bias
fprintf('Mean signed error: %.3f\n', mean(error_signed));
fprintf('Mean error norm: %.3f\n', mean(abs(error_signed)));