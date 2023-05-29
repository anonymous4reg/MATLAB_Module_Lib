clear
clc
P_seq_WT_No1 = {'P1.0','P0.9','P0.8','P0.7','P0.6','P0.5','P0.4','P0.3','P0.2','P0.1','P0.0'};
P_seq_agg = {'P1.0','P0.9','P0.8','P0.7','P0.6','P0.5','P0.4','P0.3','P0.2','P0.1','P0.0'};
Q_seq_WT_No1 = {'Q1.0','Q0.0','Q-1.0'};
Q_seq_agg = {'Q1.0','Q0.0','Q-1.0'};
% P_seq_WT_No1 = {'U1.0'};%
% P_seq_agg = {'U1.0'};%
% Q_seq_WT_No1 = {'Q1.0' 'Q0.2'  'Q-0.2' 'Q-1.0'};
% Q_seq_agg = {'Q1.0' 'Q0.2'  'Q-0.2' 'Q-1.0'};


WT_No1_seq = ZscanFolderSeqGen(P_seq_WT_No1, Q_seq_WT_No1, '-');
Agg_seq = ZscanFolderSeqGen(P_seq_agg, Q_seq_agg, '-');

SubDirL = '1-250Hz\';
SubDirH = '1-250Hz\';
% WT_File1='【茂盛】特变光伏2500\';
% SubDir = '250-2500Hz\';
% WT_File1='高频\';

figure
for agg_idx = 1:length(Agg_seq)
    file_name_PL = strcat( SubDirL, WT_No1_seq{agg_idx},'\', 'DATA_ZPD.mat');
    ZPD_PL = load(file_name_PL);
    ZPD_PL = cell2mat(struct2cell(ZPD_PL));

    file_name_PH = strcat( SubDirH, WT_No1_seq{agg_idx},'\', 'DATA_ZPD.mat');
    ZPD_PH = load(file_name_PH);
    ZPD_PH = cell2mat(struct2cell(ZPD_PH));

    

%     for ff=1:249
%         if  ZPD(ff,3)<-160
%             ZPD(ff,3) = ZPD(ff,3) + 360;
%         elseif ZPD(ff,3)>200
%             ZPD(ff,3) = ZPD(ff,3) - 360;
%         end    
%     end
   

    subplot(2,1,1);

    semilogx(ZPD_PL(1:249,1),20*log10(ZPD_PL(1:249,2)));
     hold on
    semilogx(ZPD_PH(1:249,1),20*log10(ZPD_PH(1:249,2)));
    grid on;
    xlabel('频率(Hz)');
    ylabel('幅值(dB)');
       set(gca,'XLim',[0 250]);
    subplot(2,1,2);

    semilogx(ZPD_PL(1:249,1),ZPD_PL(1:249,3));
     hold on
    semilogx(ZPD_PH(1:249,1),ZPD_PH(1:249,3));
    grid on;
    xlabel('频率(Hz)');
    ylabel('相角(°)');
       set(gca,'XLim',[0 250]);
end
saveas(gca, '新能源场站——正序阻抗_1-250Hz.png')
% saveas(gca, '正序阻抗_1-100Hz.tiff')
figure
for agg_idx = 1:length(Agg_seq)
    
    file_name_NL = strcat( SubDirL, WT_No1_seq{agg_idx},'\', 'DATA_ZND.mat');
    ZND_NL = load(file_name_NL);
    ZND_NL = cell2mat(struct2cell(ZND_NL));
    file_name_NH = strcat( SubDirH, WT_No1_seq{agg_idx},'\', 'DATA_ZND.mat');
    ZND_NH = load(file_name_NH);
    ZND_NH = cell2mat(struct2cell(ZND_NH));
%     for ff=1:249
%         if  ZPD(ff,3)<-160
%             ZPD(ff,3) = ZPD(ff,3) + 360;
%         elseif ZPD(ff,3)>200
%             ZPD(ff,3) = ZPD(ff,3) - 360;
%         end    
%     end
   

    subplot(2,1,1);
   
    semilogx(ZND_NL(:,1),20*log10(ZND_NL(:,2)));
     hold on
   semilogx(ZND_NH(:,1),20*log10(ZND_NH(:,2)));
    grid on;
    xlabel('频率(Hz)');
    ylabel('幅值(dB)');
       set(gca,'XLim',[0 250]);
    subplot(2,1,2);

   semilogx(ZND_NL(:,1),ZND_NL(:,3));
    hold on
    semilogx(ZND_NH(:,1),ZND_NH(:,3));
    grid on;
    xlabel('频率(Hz)');
    ylabel('相角(°)');
       set(gca,'XLim',[0 250]);
end
saveas(gca, '新能源场站——负序阻抗_1-250Hz.png')
close all