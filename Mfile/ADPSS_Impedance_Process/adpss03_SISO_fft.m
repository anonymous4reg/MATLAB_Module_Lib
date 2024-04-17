clear; close all;clc
Freq_begin = 1;
Freq_end = 100;
Freq_step = 1;

TS = 0.0002;
NN = double(int64(1/TS));
% NN = 5000;


RootDir = "D:\Travail\RE\HIL\[Routine] 沽源振荡\20240105_沽源振荡_华北捅国调\03-ADPSS仿真复现\01-扫频结果数据\";
SrcSubDir = '20240219_沽源大网_B机型_变压器问题-03-扫频结果600台（供FFT）';
SrcDir = fullfile(RootDir, SrcSubDir, 'process');
FileName = "Lfile_0.mat";
DstFileName = "DATA_ZPD.mat";
DstFileUrl = fullfile(SrcDir, DstFileName);

FileUrl = fullfile(SrcDir, FileName);
Data = importdata(FileUrl);

[ZPD_SISO,ZND_SISO] = U_I_Z_F_1hz_1_250(Freq_begin,Freq_end,Freq_step,NN,Data);
save(DstFileUrl, 'ZPD_SISO', 'ZND_SISO')
