function plot_comparison(filenames, path)
    close all;
    fig_id = 1:4;
    k = 1;
    colors = get(gca, 'ColorOrder');
    legend_names = [];
    n_spokes_matrix = [];
    ai_N_spokes_matrix = [];
    colors_matrix = [];

    for file = filenames
        jj = mod(k, 7);
        if jj == 0
            jj = 7;
        end
        load(strcat(path, "\", file), "n_elem", "n_nod", "n_spokes", "R", "asservimenti", "disp_vec", "igl", "ai_nod", "n_elem_rim", "ai_N_spokes", "ai_N_rim", "P", "ai_M_rim", "Table", "legend_name");
        [n_elem_rim, wheel_deformed, wheel_not_deformed] = plot_deformed_wheel(n_elem, n_nod, n_spokes, R, asservimenti, fig_id(1), disp_vec, igl, k == 1, 1e3, colors(jj, :));
        [ai_N_spokes, ai_T_spokes, ai_M_spokes, ai_N_rim, ai_M_rim] = load_ai(ai_nod, n_elem_rim, n_spokes);
        
        % plot_ai_N_spokes(n_spokes, ai_N_spokes, fig_id(2), colors(jj, :), P);
        n_spokes_matrix = [n_spokes_matrix; n_spokes];
        ai_N_spokes_matrix = [ai_N_spokes_matrix, ai_N_spokes];
        colors_matrix = [colors_matrix; colors(jj, :)];

        plot_ai_cerchione(n_elem_rim,ai_N_rim, P, ai_M_rim, fig_id(3), fig_id(4), colors(jj, :));
        legend_names = [legend_names; string(legend_name)];
        k = k+1;
    end
    plot_ai_N_spokes(n_spokes_matrix, ai_N_spokes_matrix, fig_id(2), colors(jj, :), P);
    for id = fig_id
        figure(id);
        if id == 1
            legend(["Ruota non deformata"; legend_names]);
        else
            legend(legend_names);
        end
    end
end