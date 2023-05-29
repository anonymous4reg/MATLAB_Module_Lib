clc; close all

%% Insert your data here
UABC_IABC = [B220kV_Num5_uabc, L220kV_ShuoJiu_iabc];

%% Specify your setting
WHICH_FREQ = [44, 50, 56];  % which freq you want to parse
SAMPLE_FREQ = 2e3;
T_SPAN = 1;  % signal real time span for selected window
L = T_SPAN * SAMPLE_FREQ;  % lenght of signal
SAMPLE_TIME = 1/SAMPLE_FREQ;
WINDOW_SLIDE_STEP = 10;  % sliding window width, more wider window, more sparser result

RESULT_NEED_STORE_CELL = {'MemFreq', 'MemUpMag', 'MemUpArg',...
    'MemIpMag', 'MemIpArg', 'MemR', 'MemX', 'MemP', 'MemQ',...
    'MemZimg'}; 
%% Code start
DATA_SIZE = size(UABC_IABC);
DATA_ROW = DATA_SIZE(1); DATA_COL = DATA_SIZE(2);

WINDOW_LENGTH = floor((DATA_ROW - L)/WINDOW_SLIDE_STEP)+1; % Combien de fenetrer ici
assert(WINDOW_LENGTH > 0, 'Window length must > 0: please make sure your input data is long enough')

%% Data store

ANS_TABLE = cell(2, length(WHICH_FREQ));

DATA_STORE_MAT = zeros(length(WHICH_FREQ),WINDOW_LENGTH, length(RESULT_NEED_STORE_CELL));


for window_idx = 1:WINDOW_LENGTH
    w_left_edge_idx = (window_idx-1) * WINDOW_SLIDE_STEP + 1;
    w_right_edge_idx = w_left_edge_idx + L - 1;
    fprintf('[%i/%i]-[%i, %i]\n', window_idx, WINDOW_LENGTH,...
        w_left_edge_idx, w_right_edge_idx);

    uabc = UABC_IABC(w_left_edge_idx:w_right_edge_idx, 1:3);
    iabc = UABC_IABC(w_left_edge_idx:w_right_edge_idx, 4:6);
    tmp_tab = f_gen_fft_tab(uabc, iabc, WHICH_FREQ, SAMPLE_FREQ, 'off');
    tmp_mat = cell2mat(table2cell(tmp_tab(:, RESULT_NEED_STORE_CELL)));

    for s_dim = 1:length(WHICH_FREQ)
        DATA_STORE_MAT(s_dim, window_idx, :) = ...
            tmp_mat(s_dim, :);
        
    end
end
[dim3, row, col] = size(DATA_STORE_MAT);

% ANS_T: this var store the resampled time t axis for further plotting
ANS_T = [0:(WINDOW_LENGTH-1)] *   (WINDOW_SLIDE_STEP / SAMPLE_FREQ);

for s_dim = 1:length(WHICH_FREQ)
    tmp_mat = reshape(DATA_STORE_MAT(s_dim, :, :), [row, col]);
    tmp_tab = array2table(tmp_mat, 'VariableNames',RESULT_NEED_STORE_CELL);
    ANS_TABLE{1, s_dim} = strcat(num2str(WHICH_FREQ(s_dim)), 'Hz');
    ANS_TABLE{2, s_dim} = tmp_tab;
end

disp('Calc results stored in variable: ANS_TABLE')

% template plot for post-calc analysis
% ATTENTION: the LEGEND below should be verified if change the sequence of 
% variable WHICH_FREQ other than [Sub, Fundamental, Super]
figure
subplot(2, 1, 1)
plot(ANS_T, ANS_TABLE{2, 2}.MemP)
grid on
ylabel('P(MW)')
legend(ANS_TABLE{1, 2})
subplot(2, 1, 2)
plot(ANS_T, ANS_TABLE{2, 1}.MemP, 'color', 'r')
hold on
plot(ANS_T, ANS_TABLE{2, 3}.MemP, 'color', 'b')
grid on
ylabel('P(MW)')
xlabel('t(s)')
legend(ANS_TABLE{1, [1,3]})

% set(gcf, "Position", [20, 20, 18, 6])


