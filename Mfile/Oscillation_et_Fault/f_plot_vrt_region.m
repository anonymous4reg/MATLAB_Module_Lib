function ret_stat = f_plot_vrt_region(t_fault_start, ubase)
    hold on
    %% LVRT
    plot([t_fault_start-0.2, t_fault_start], [1, 1]*ubase, "Color",   [0, 0, 0], 'LineStyle','--')
    plot([t_fault_start, t_fault_start], [0.2, 1]*ubase, "Color",   [0, 0, 0], 'LineStyle','--')
    plot([t_fault_start, t_fault_start+0.625], [0.2, 0.2]*ubase, "Color",   [0, 0, 0], 'LineStyle','--')
    plot([t_fault_start+0.625, t_fault_start+2], [0.2, 0.9]*ubase, "Color",   [0, 0, 0], 'LineStyle','--')
    plot([t_fault_start+2, t_fault_start+4], [0.9, 0.9]*ubase, "Color",   [0, 0, 0], 'LineStyle','--')
    %% HVRT
    x = [t_fault_start-0.2, t_fault_start, t_fault_start, t_fault_start+0.5, t_fault_start+0.5, t_fault_start+1, t_fault_start+1, t_fault_start+10, t_fault_start+10];
    y = [1, 1, 1.3, 1.3, 1.25, 1.25, 1.2, 1.2, 1.1]*ubase;
    plot(x, y, "Color",   [0, 0, 0], 'LineStyle','--')
end