clear;clc
% User define zone [start]
Freq = 1:100;
SimModel = 'CVT_4p2_Z_Scan_sym_20200602';
SimDuration = 5;
SaveTempFile = 0;
% User define zone [end]


tic
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
save scan_concat
toc
disp('Done.')
