function [ai_N_spokes, ai_T_spokes, ai_M_spokes, ai_N_rim, ai_M_rim] = load_ai(ai_nod, n_elem_rim, n_spokes)
ai_N_spokes = zeros(n_spokes, 1);
ai_T_spokes = zeros(n_spokes, 1);
ai_M_spokes = zeros(n_spokes, 1);

for ii=1:n_spokes
  ai_N_spokes(ii) = -ai_nod(ii+n_elem_rim,1);
  ai_T_spokes(ii) = ai_nod(ii+n_elem_rim, 2);
  ai_M_spokes(ii) = ai_nod(ii+n_elem_rim, 3);
end

ai_N_rim = zeros(n_elem_rim, 1);
ai_M_rim = zeros(n_elem_rim+1, 1);

ai_M_rim(1) = -ai_nod(1,3);


for ii=1:n_elem_rim
    ai_N_rim(ii) = ai_nod(ii,4);
    ai_M_rim(ii+1) = ai_nod(ii,6);
end

end