function [] = plot_ai_cerchione(n_elem_rim,ai_N_rim, P, ai_M_rim, ifigure_m, ifigure_n, plot_color)
theta = linspace(0, 180, n_elem_rim+1);
theta_n = linspace(0, 180, n_elem_rim);

figure(ifigure_m);
% tiledlayout(1, 2);

% nexttile
hold on
plot(theta_n, ai_N_rim/(2*P), 'Color', plot_color, 'LineStyle', '--');
hold off
axis square
grid on
title("Azioni normali cerchione normalizzate");
xlabel("\theta [°]");
ylabel("N/P");

max_N = max(abs(ai_N_rim))

figure(ifigure_n);
hold on
plot(theta, -ai_M_rim/max(abs(ai_M_rim)), 'Color', plot_color, 'LineStyle', '--');
hold off
axis square
grid on
title("Momenti cerchione normalizzati su momento massimo");
xlabel("\theta [°]");
ylabel("M/Max|M|");

max_ai_M_rim = max(abs(ai_M_rim))

end