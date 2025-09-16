function [n_elem_rim, wheel_deformed, wheel_not_deformed] = plot_deformed_wheel(n_elem, n_nod, n_spokes, R, asservimenti, ifigure, disp_vec, igl, plot_not_deformed, gain, plot_color)
n_elem_rim = n_elem - n_spokes;

if asservimenti
    n = n_nod - 1 - n_spokes;
else 
    n = n_nod - 1;
end

alpha = linspace(-pi/2, pi/2, n);
wheel_not_deformed = R*[cos(alpha); sin(alpha)]';

figure(ifigure);
if plot_not_deformed
    hold on
    plot([wheel_not_deformed(:, 1); -flip(wheel_not_deformed(:, 1))], [wheel_not_deformed(:, 2); flip(wheel_not_deformed(:, 2))], 'Color', '#757575', 'Marker', '.');
    % plot(-wheel_not_deformed(:, 1), wheel_not_deformed(:, 2),  'Color', '#757575', 'LineStyle', '--', 'Marker', '.');
    hold off
    axis square
end




disp_mat = zeros(n, 2);
for i1 = 1:n
    for i2 = 1:2
        if(igl(i1, i2) > 0)
            disp_mat(i1, i2) = disp_vec(igl(i1,i2));
        else
            disp_mat(i1, i2) = 0;
        end
    end
end


wheel_deformed = wheel_not_deformed + disp_mat * gain;

hold on
plot([wheel_deformed(:, 1); -flip(wheel_deformed(:, 1))], [wheel_deformed(:, 2); flip(wheel_deformed(:, 2))], 'Color', plot_color, 'Marker', '.');
% plot(-wheel_deformed(:, 1), wheel_deformed(:, 2),'Color', plot_color, 'LineStyle', '--', 'Marker', '.');
hold off
grid on

title("Deformazione cerchione")
xlabel("Coordinata x [m]");
ylabel("Coordinata y [m]");

end