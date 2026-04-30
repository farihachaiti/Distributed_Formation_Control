% Force ei to be a 1D or 2D array
ei = squeeze(out.position_error);  % Remove singleton dimensions

% If still 3D, take first simulation or average
if ndims(ei) > 2
    ei = squeeze(mean(ei, 3));  % Average across 3rd dimension
end

% If ei is a timeseries object
if isobject(ei) && isprop(ei, 'Data')
    ei = ei.Data;
end

% Ensure ei is a vector
ei = ei(:);  % Force column vector

% Create sample indices
samples = 1:length(ei);

figure;
plot(samples, ei, 'LineWidth', 2);
title('Formation Error Evolution over Samples');
xlabel('Sample Number');
ylabel('||e_i||');
grid on;