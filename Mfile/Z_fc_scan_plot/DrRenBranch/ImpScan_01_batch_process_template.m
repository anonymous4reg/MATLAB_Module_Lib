%% 
clear; clc; close all

%% ------------------Low freq code--------------------- %%
%% ------------------��Ƶ������--------------------- %%

% User setting here
SrcFileDir  =   'C:\Users\ym\Desktop\test\P1.0-Q0.0\��Ƶ\';

FileName    =   {'P1.0-Q0.0', 'P1.0-Q1.0'};
Freq_begin  =   1;
Freq_middle =   100;
Freq_end    =   350;
Freq_step   =   1;
SampleTimeMicroSecond  =   100; % Sample time of data(us)
SaveTempsFlag = true;

%% DON NOT Change this block !!!
CmdCell = {
	SrcFileDir, FileName, Freq_begin, Freq_middle, ...
	Freq_end, Freq_step, SampleTimeMicroSecond, SaveTempsFlag
};
%%


[ZPD_SISO, ZND_SISO] = AutoZscan2ZPN(CmdCell);

% [ZPD_SISO, ZND_SISO, ZPD_MIMO, ZND_MIMO] = AutoZscan2ZPN(CmdCell);


    


%% ------------------High freq code--------------------- %%
%% ------------------��Ƶ������--------------------- %%
SrcFileDir  =   'C:\Users\ym\Desktop\test\P1.0-Q0.0\��Ƶ\';
FileName    =   {'P1.0-Q0.0', 'P1.0-Q1.0'};
Freq_begin  =   250;
Freq_middle =   100;
Freq_end    =   2500;
Freq_step   =   10;
SampleTimeMicroSecond  =   20; % Sample time of data(us)
SaveTempsFlag = true;

%% DON NOT Change this block !!!
CmdCell = {
	SrcFileDir, FileName, Freq_begin, Freq_middle, ...
	Freq_end, Freq_step, SampleTimeMicroSecond, SaveTempsFlag
};
%%

[ZPD_SISO, ZND_SISO] = AutoZscan2ZPN_250_2500(CmdCell);

close all

