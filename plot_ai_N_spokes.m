function plot_ai_N_spokes(n_spokes,ai_N_spokes, ifigure, bar_color, P)

    theta = linspace(180/n_spokes(1), 180 - 180/n_spokes(1), n_spokes(1));
    
    figure(ifigure);
    hold on
    % bar(theta, ai_N_spokes/P, 'FaceColor', bar_color);
    if P == 0
        P = 1;
    end
    bar(theta, ai_N_spokes ./ P);
    hold off
    title("Azioni normali sui raggi");
    xlabel("\theta [°]");
    ylabel("N/P");
    max_ai_N_spokes = max(abs(ai_N_spokes))
end