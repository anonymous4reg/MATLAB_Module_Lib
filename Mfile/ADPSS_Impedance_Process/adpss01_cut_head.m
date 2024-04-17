%% File description
% 已将txt文件分别导出为mat文件，本程序用于将数据中的前奏时间去掉
% 以便塞入后续的分析程序
% Data rearrangement
clear; close all; clc

T_DELAY = 5;
TS = 0.0002;
FS = int64(1/TS);
FIRST_INDEX = T_DELAY * FS + 1;
U_BASE = 525e3;
S_BASE = 100e6;
I_BASE = S_BASE / U_BASE / sqrt(3);

%% Specify the column index number of time/uabc/iabc
TIME_COLUMN_INDEX = 1;
UABC_COLUMN_INDEX = [2:4];
IABC_COLUMN_INDEX = [5:7];


RootDir = "D:\Travail\RE\HIL\[Routine] 沽源振荡\20240105_沽源振荡_华北捅国调\03-ADPSS仿真复现\01-扫频结果数据\20240219_沽源大网_B机型_变压器问题-录波文件\";
FileName = {"20240219_沽源大网_B机型_变压器问题-03-扫频结果600台（供FFT）.csv"};

DstRootDir = RootDir;


UNIFORM_THRESHOLD = 1e-9;
FileUrl = {};
BaseName = {};
for idx = 1:length(FileName)
    [~, file_name, ~] = fileparts(FileName{idx});
    BaseName = [BaseName, file_name];
    FileUrl = [FileUrl, fullfile(RootDir, FileName{idx})];
    if exist(FileUrl, 'file') ~= 2
        error(strcat('File:', file_name, ' does not exist'))
    else
        DstSubDir = file_name; % The same with the original csv file
        DstDir = fullfile(DstRootDir, DstSubDir);
        mkdir(DstDir);
    end
end

fprintf('Total %i files found, start to process...\r\n', length(FileUrl))

for idx = 1:length(FileUrl)
    raw_data_table = readtable(FileUrl{idx});
    raw_data_mat = table2array(raw_data_table);

    TS_estimate = 0;
    try
        if exist('TIME_COLUMN_INDEX')
            t_axis = raw_data_mat(:, TIME_COLUMN_INDEX);
            t1 = diff(t_axis);
            is_uniform = all((t1 - t1(1)) <= UNIFORM_THRESHOLD);
            if (is_uniform == true)
                TS_estimate = t1(1);
                fprintf("Time axis consistent. Detected sample time = %f\n", TS_estimate);
                if (abs(TS_estimate - TS) <= UNIFORM_THRESHOLD)
                    fprintf("Sample time: %f (you provided) = Sample time: %f (from file).\n", TS, TS_estimate);

                    % UABC = raw_data_mat(:, UABC_COLUMN_INDEX);
                    % IABC = raw_data_mat(:, IABC_COLUMN_INDEX);
                    data = raw_data_mat;
                    uabc = data(FIRST_INDEX:end, UABC_COLUMN_INDEX)*U_BASE;
                    iabc = data(FIRST_INDEX:end, IABC_COLUMN_INDEX)*I_BASE;
                    taxis = [0:length(uabc)-1]' * TS_estimate;
                    Lscan = [taxis, taxis, uabc, iabc];
                    save(fullfile(DstDir, strcat(BaseName{idx}, "_head_cutted.mat")), 'Lscan')

                else
                    fprintf("Sample time: %f (you provided) ≠ Sample time: %f (from file).\n", TS, TS_estimate);
                    fprintf("Using estimated sample time instead");

                end


            else
                fprintf("Time axis in your file is not consistent, please pay attention to it.\n")
            end
        end
    catch exceptions
        % fprintf(exceptions)
        throw(exceptions)
    end
    break

end





