function [drop_starts, drop_ends] = f_voltage_fault_detect_plot(uabc, Ubase, FS_IN_USE)
%F_VOLTAGE_FAULT_DETECT_PLOT Detects voltage faults and plots the results
%
%   [drop_starts, drop_ends] = F_VOLTAGE_FAULT_DETECT_PLOT(uabc, Ubase, FS_IN_USE)
%
%   This function detects voltage drops in three-phase voltage data,
%   calculates RMS values, and plots both instantaneous and RMS voltages.
%
%   Inputs:
%   uabc        - n by 3 matrix, phase-ground or line voltage data
%                 Each column represents a phase (A, B, C)
%                 Each row represents a time sample
%   Ubase       - Nominal (base) voltage in volts
%                 If uabc is phase-ground, Ubase should be phase-ground base voltage
%                 If uabc is line voltage, Ubase should be line-to-line base voltage
%   FS_IN_USE   - Sampling frequency in Hz
%
%   Outputs:
%   drop_starts - Vector containing the start times (in samples) of detected voltage drops
%   drop_ends   - Vector containing the end times (in samples) of detected voltage drops
%
%   Key variables:
%   window_size       - Size of the sliding window for RMS calculation (in samples)
%   threshold_percent - Percentage of nominal voltage used as threshold for drop detection
%   rms_values        - Calculated RMS values for each phase
%   voltage_drops     - Boolean matrix indicating where voltage drops occur
%   
%   The function also creates a figure showing:
%   1. Instantaneous voltages (top subplot)
%   2. RMS voltages with threshold (bottom subplot)
%   Voltage drops are highlighted with red patches on both subplots.
%
%   Note: This function requires the f_set_fontface function to set the font face.

    FONT_SIZE = 14;
    LINEWIDTH = 2;

    % Ensure all inputs are double
    uabc = double(uabc);
    Ubase = double(Ubase);
    FS_IN_USE = double(FS_IN_USE);

    % Parameters
    window_size = round(FS_IN_USE * 0.02);  % 20 ms window (1 cycle for 50 Hz)
    threshold_percent = 0.9;  % 90% of nominal voltage

    % Calculate RMS values using a sliding window
    n_samples = size(uabc, 1);
    rms_values = zeros(n_samples - window_size + 1, 3);
    for i = 1:(n_samples - window_size + 1)
        window = uabc(i:(i+window_size-1), :);
        rms_values(i, :) = sqrt(mean(window.^2, 1));
    end

    nominal_voltage = Ubase;
    threshold = threshold_percent * nominal_voltage;

    % Detect voltage drops
    voltage_drops = rms_values < threshold;
    any_phase_drop = any(voltage_drops, 2);

    % Find the start and end indices of voltage drop periods
    state_changes = diff([0; any_phase_drop; 0]);
    drop_starts = find(state_changes == 1);
    drop_ends = find(state_changes == -1) - 1;

    % Adjust indices to account for window size
    drop_starts = drop_starts + floor(window_size/2);
    drop_ends = drop_ends + floor(window_size/2);

    % Merge drops that are close together
    min_separation = 50;  % Minimum samples between separate drops
    i = 1;
    while i < length(drop_starts)
        if drop_starts(i+1) - drop_ends(i) <= min_separation
            drop_ends(i) = drop_ends(i+1);
            drop_starts(i+1) = [];
            drop_ends(i+1) = [];
        else
            i = i + 1;
        end
    end

    % Display results
    for i = 1:length(drop_starts)
        drop_duration = drop_ends(i) - drop_starts(i) + 1;
        fprintf('Voltage Drop %d: Starts at %.4f s, Ends at %.4f s, Duration: %.4f s\n', ...
                i, drop_starts(i)/FS_IN_USE, drop_ends(i)/FS_IN_USE, drop_duration/FS_IN_USE);
    end

    % Plot results
    window_extension = 3 * window_size;  % 3 windows before and after

    figure;
    set(gcf, 'Position', [173 291 896 624]);

    for i = 1:length(drop_starts)
        % Calculate plot range
        plot_start = max(1, drop_starts(i) - window_extension);
        plot_end = min(n_samples, drop_ends(i) + window_extension);
        t_plot = (plot_start:plot_end) / FS_IN_USE;
        t_rms_plot = ((plot_start:plot_end) - floor(window_size/2)) / FS_IN_USE;
        
        % Plot instantaneous voltages
        subplot(2,1,1);
        plot(t_plot, uabc(plot_start:plot_end, :) / (Ubase * sqrt(2)), 'LineWidth', LINEWIDTH);
        xlabel('Time (s)');
        ylabel('Voltage (p.u.)');
        legend('Phase A', 'Phase B', 'Phase C');
        hold on;
        grid on;
        patch([drop_starts(i) drop_ends(i) drop_ends(i) drop_starts(i)]/FS_IN_USE, ...
              [min(ylim) min(ylim) max(ylim) max(ylim)], ...
              'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        hold off;
        set(gca, 'FontSize', FONT_SIZE);
        f_set_fontface(gca, 'times new roman');
        xlim([plot_start, plot_end]/FS_IN_USE);
        
        % Plot RMS voltages
        subplot(2,1,2);
        plot(t_rms_plot+0.02, rms_values(plot_start:plot_end, :) / Ubase, 'LineWidth', LINEWIDTH);
        hold on;
        plot(t_rms_plot, threshold*ones(1, length(t_rms_plot)) / Ubase, 'k--', 'LineWidth', LINEWIDTH);
        xlabel('Time (s)');
        ylabel('RMS Voltage (p.u.)');
        legend('Phase A', 'Phase B', 'Phase C', 'Threshold');
        patch([drop_starts(i) drop_ends(i) drop_ends(i) drop_starts(i)]/FS_IN_USE, ...
              [min(ylim) min(ylim) max(ylim) max(ylim)], ...
              'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        hold off;
        grid on;
        set(gca, 'FontSize', FONT_SIZE);
        f_set_fontface(gca, 'times new roman');
        
        % Adjust x-axis limits to show 3 windows before and after
        xlim([plot_start, plot_end]/FS_IN_USE);
    end

    % Print the determined nominal voltage
    fprintf('Nominal voltage: %.2f\n', nominal_voltage);
end