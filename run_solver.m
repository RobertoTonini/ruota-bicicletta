function [n_elem, n_nod, n_spokes, R, asservimenti, disp_vec, igl, ai_nod, n_elem_rim, ai_N_spokes, ai_N_rim, P, ai_M_rim, Table] = run_solver(pname, fname, connection_type, R, nsub, P, n_spokes, outputpath)
clc; close all;
[n_nod, n_elem, n_sez, n_mat, n_gdl, n_vincl, inc, isez, imat, igl, coor, csez, cmat, card, incl, KstfE, KstfG, ai_nod, strspars, load_vec, disp_vec, F_neE, F_extG] = Telai_MdS_fun(fname, pname, outputpath);


asservimenti = isequal(connection_type, 'Cerniera');

%% Plot configurazione deformata    
[n_elem_rim, wheel_deformed, wheel_not_deformed] = plot_deformed_wheel(n_elem, n_nod, n_spokes, R, asservimenti, 5, disp_vec, igl, true, 1e3, 'r');
figure(5);
legend("Configurazione indeformata", "Configurazione deformata (x10^3)");

% [n_elem_rim, wheel_deformed, wheel_not_deformed] = plot_deformed_wheel(n_elem, n_nod, n_spokes, R, asservimenti, 5, disp_vec, igl, false, 1e2, 'g');


%% Plot azioni assiali raggi
[ai_N_spokes, ai_T_spokes, ai_M_spokes, ai_N_rim, ai_M_rim] = load_ai(ai_nod, n_elem_rim, n_spokes);

plot_ai_N_spokes(n_spokes,ai_N_spokes, 6, 'blue', 2*P);


%% Azioni interne cerchione

plot_ai_cerchione(n_elem_rim,ai_N_rim, P, ai_M_rim, 7, 8, 'red');


%% Azioni interne in sistema di riferimento globale
Table = eq_table(ai_N_rim, ai_nod, wheel_not_deformed, n_spokes, n_elem_rim, ai_N_spokes, ai_T_spokes, ai_M_spokes, ai_M_rim, R)

% save(fname(1:end-6), "n_elem", "n_nod", "n_spokes", "R", "asservimenti", "disp_vec", "igl", "ai_nod", "n_elem_rim", "ai_N_spokes", "ai_N_rim", "P", "ai_M_rim", "Table");
