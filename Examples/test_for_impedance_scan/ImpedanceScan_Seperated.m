clear;clc
Freq = 1:100;
SimModel = 'test_model_for_impedance_scan';
SimDuration = 5;
SaveTempFile = 0;

warning('off')
for freq = 1:length(Freq)
    disp(['Scanning ', num2str(freq), ' Hz...'])
    sim(SimModel, SimDuration);
    movefile('scan.mat', ['scan_', num2str(freq), 'Hz.mat']);
end

disp('Concatenating files...')
scan_concat = [];
for freq = 1:length(Freq)
    load(['scan_', num2str(freq), 'Hz.mat']);
    if SaveTempFile == 0
        delete(['scan_', num2str(freq), 'Hz.mat'])
    end
    scan_concat = [scan_concat, scan];
end

disp('Done.')