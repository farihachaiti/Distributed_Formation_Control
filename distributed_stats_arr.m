


% Extract data
zP = out.z_pred;
zA = out.z_actual;



figure;

    

    plot(zP,'b'); % blue

    hold on;

    plot(zA, 'r'); % red

    title('Measurement Model z');
    xlabel('Samples');
    ylabel('Value');

    legend('Predicted','Actual');

    grid on;
