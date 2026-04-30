% Extract data (adjust based on your Simulink output variable names)
z_a = out.z_actual;      % or out.temp_measured
z_p = out.z_pred;      % or out.temp_predicted

% Handle timeseries objects if needed
if isobject(z_a) || isstruct(z_a)
    if isprop(z_a, 'Data') || isfield(z_a, 'Data')
        z_p = z_p.Data;
        z_a = z_a.Data;
    end
end

% Force column vectors
z_p = z_p(:);
z_a = z_a(:);

% Create sample indices
samples = 1:length(z_a);

figure;
plot(samples, z_p, 'b-', 'LineWidth', 1.5);  % z in blue
hold on;
plot(samples, z_a, 'r-', 'LineWidth', 1.5); % z_a in red

% Formatting to match your image
title('Measurement Model Z');
xlabel('Samples');
ylabel('Z');
xlim([0 5000]);
ylim([0 10]);
grid on;
legend('z\_predicted', 'z\_actual', 'Location', 'best');
hold off;