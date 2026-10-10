clear; close all; clc
%% description
% This is a template for academic figure plotting, especially suitable for two-column 
% typesetting.

%% dependency
% You need copy dependent .m function, such as "f_savefig.m", to your working directory


Root_Dir = '.\';
Mat_File_Name = 'xxx.mat';


%% Plot configuration
LINE_WIDTH = 1.4;
FONT_SIZE = 14;
FONT_FACE = 'Times New Roman';
FIG_SAVE_FORMAT = {'fig', 'png'};

%% data import
% mat_file_url = fullfile(Root_Dir, Mat_File_Name)
% data = importdata(mat_file_url);

demo_t = (1:20000)*50e-6;
demo_y = sin(100*pi*demo_t);


figure
set(gcf,'unit','centimeters','position',[10,5,16, 11/2])
plot(demo_t, demo_y, 'linewidth', LINE_WIDTH)
xlabel('t (s)');
ylabel('Voltage (V)');
title('demo title')
% xlim([2, 5])
% ylim([-0.1, 1.5])
grid on
set(gca, 'fontname', FONT_FACE, 'fontsize', FONT_SIZE)
% f_savefig(RootDir, 'U1', FIG_SAVE_FORMAT, 300)

figure
set(gcf,'unit','centimeters','position',[10,5,16, 11/2])
plot(demo_t, -demo_y, 'linewidth', LINE_WIDTH, 'Color', "#D95319")
xlabel('t (s)');
ylabel('Active Power (MW)');
title('demo title')
% xlim([2, 5])
% ylim([-10, 500])
grid on
set(gca, 'fontname', FONT_FACE, 'fontsize', FONT_SIZE)

% uncomment below if you want to save figure
% f_savefig(RootDir, 'P1', FIG_SAVE_FORMAT, 300) 



%% dual row plot
figure
set(gcf,'unit','centimeters','position',[10,5,16, 11])
subplot(2, 1, 1)
plot(demo_t, demo_y, 'linewidth', LINE_WIDTH)
title('demo title')
xlabel('t (s)');
ylabel('Voltage (V)');
% xlim([2, 5])
% ylim([-0.1, 1.5])
grid on
set(gca, 'fontname', FONT_FACE, 'fontsize', FONT_SIZE)

subplot(2, 1, 2)
plot(demo_t, -demo_y, 'linewidth', LINE_WIDTH, 'Color', "#D95319")
xlabel('t (s)');
ylabel('Current (A)');
% xlim([2, 5])
% ylim([-10, 500])
grid on
set(gca, 'fontname', FONT_FACE, 'fontsize', FONT_SIZE)

% uncomment below if you want to save figure
% f_savefig(RootDir, 'P1', FIG_SAVE_FORMAT, 300)  