function [Table] = eq_table(ai_N_rim, ai_nod, wheel_not_deformed, n_spokes, n_elem_rim, ai_N_spokes, ai_T_spokes, ai_M_spokes, ai_M_rim, R)
% Pattino inferiore
N_inf = ai_N_rim(1);
T_inf = ai_nod(1,2);
xx_inf = [wheel_not_deformed(1:2, 1)];
yy_inf = [wheel_not_deformed(1:2, 2)];
theta_rim_element = atan(abs((yy_inf(2) - yy_inf(1))/(xx_inf(2) - xx_inf(1))));

F_inf = [-N_inf * cos(theta_rim_element) - T_inf * sin(theta_rim_element), -N_inf * sin(theta_rim_element) + T_inf * cos(theta_rim_element)];

% Pattino superiore
N_up =  ai_N_rim(end);

T_up = -ai_nod(n_elem_rim, 5);
F_up = [-N_up * cos(theta_rim_element) + T_up * sin(theta_rim_element), N_up * sin(theta_rim_element) + T_up * cos(theta_rim_element)];


% Azioni sui raggi
thetas = linspace(pi/(2*n_spokes), pi - pi/(2*n_spokes), n_spokes)';
F_mozzo = [-ai_N_spokes .* sin(thetas) + ai_T_spokes.*cos(thetas), ai_N_spokes.*cos(thetas) + ai_T_spokes.*sin(thetas)];

R_mozzo = [sum(F_mozzo(:, 1)), sum(F_mozzo(:, 2))];


Vincolo = ["Pattino in basso", "Pattino in alto", "Cerniera (mozzo)", "Risultante"]';
Rx_N = [F_inf(1); F_up(1); R_mozzo(1)];
Rx_N = [Rx_N; sum(Rx_N)];
Ry_N = [F_inf(2); F_up(2); R_mozzo(2)];
Ry_N = [Ry_N; sum(Ry_N)];
M_Nm = [-ai_M_rim(1), ai_M_rim(end), sum(ai_M_spokes)]';
M_eq = -R * (R_mozzo(1) + 2*F_up(1));


M_Nm = [M_Nm; sum(M_Nm) + M_eq];

format long

Table = table(Vincolo, Rx_N, Ry_N, M_Nm);
end