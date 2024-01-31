%% File description
% 将“去头”的数据导入，删掉扰动注入间隔之间的等待部分，重新叠合成半实物扫频程序能直接处理的数据
% Data rearrangement
clear; close all; clc
RootDir = "D:\Travail\RE\HIL\[Routine] 沽源振荡\20240105_沽源振荡_华北捅国调\03-ADPSS仿真复现\01-扫频结果数据\远景5MW-已优化_01_35kV_有倍乘200台\";
DstSubDir = "\process\";
DstDir = fullfile(RootDir, DstSubDir);
FileName = {"远景5MW-已优化_01_35kV_有倍乘200台_head_cutted.mat"};
mkdir(DstDir)


T_DELAY = 0;
T_DISTURB = 1.1;
T_REST = 0.1;
T_REC = 1.0;
TS = 0.0002;
FS = int64(1/TS);

FreqBegin = 1;
FreqEnd = 100;
FreqStep = 1;

%% Specify the column index number of time/uabc/iabc
TIME_COLUMN_INDEX = 1;

UNIFORM_THRESHOLD = 1e-9;
FileUrl = {};
BaseName = {};
for idx = 1:length(FileName)
    [~, file_name, ~] = fileparts(FileName{idx});
    BaseName = [BaseName, file_name];
    FileUrl = [FileUrl, fullfile(RootDir, FileName{idx})];
end

for idx = 1:length(FileUrl)
    % raw_data_table = readtable(FileUrl{idx});
    % raw_data_mat = table2array(raw_data_table);
    raw_data_mat = importdata(FileUrl{idx});

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


                    % raw_data = importdata(FileUrl{idx});
                    data = raw_data_mat;
                    %% find the fist edge index
                    FIRST_INDEX = T_DELAY * FS + 1;
                    % 这里是int64(T_REC/TS)，表明只选取长度为T_REC长度的数据。因为如果扰动时长不为1s，又想取出1s的数据，就得使用这种方法。
                    select_range = [FIRST_INDEX, FIRST_INDEX + int64(T_REC/TS) - 1];
                    %% Pre-alloc spaces
                    scan_concat = [];

                    
                    for freq = FreqBegin:FreqStep:FreqEnd
                        tmp_data = data(select_range(1):select_range(2), :);

                        scan_concat = [scan_concat; tmp_data];
                        select_range = select_range + int64((T_DISTURB + T_REST)/TS);

                    end
                    Lscan = scan_concat';
                    save(fullfile(DstDir, "\Lfile_0.mat"), 'Lscan')

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