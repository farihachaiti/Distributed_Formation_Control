%% ── Test 3: Cross-correlation between robots ─────────────────────────────
% Compare innovation sequences of robot pairs
% Before fusion: should be uncorrelated
% After fusion:  will be correlated (by design)

fprintf('\nCross-Correlation Between Robots (x channel shown)\n');
fprintf('%s\n', repmat('─',1,60));
fprintf('%-15s  %-12s  %-12s  %-15s\n', ...
        'Robot Pair','Correlation','p-value','Verdict');
fprintf('%s\n', repmat('─',1,60));

robot_pairs      = [1,2; 1,3; 2,3];
robot_pair_names = {'Robot 1 vs 2', 'Robot 1 vs 3', 'Robot 2 vs 3'};

% Pull x-channel innovation per robot from stored data
% Adjust field names to match your stored struct
e_r1 = squeeze(stored{1}.z_actual(:)  - stored{1}.z_pred(:));
e_r2 = squeeze(stored{1}.z_actual1(:) - stored{1}.z_pred1(:));
e_r3 = squeeze(stored{1}.z_actual2(:) - stored{1}.z_pred2(:));

robot_errors = {e_r1, e_r2, e_r3};

for p = 1:3
    r1 = robot_pairs(p,1);
    r2 = robot_pairs(p,2);
    e1 = robot_errors{r1};
    e2 = robot_errors{r2};
    N  = min(length(e1), length(e2));
    e1 = e1(1:N);   e2 = e2(1:N);

    rho_r  = corr(e1, e2);
    t_stat = rho_r * sqrt(N-2) / sqrt(1 - rho_r^2);
    p_val  = 2*(1 - tcdf(abs(t_stat), N-2));

    if abs(rho_r) < 0.1
        verdict = 'Uncorrelated — CI fusion safe';
    else
        verdict = 'Correlated — CI fusion needed';
    end

    fprintf('%-15s  %-12.4f  %-12.4f  %s\n', ...
            robot_pair_names{p}, rho_r, p_val, verdict);
end