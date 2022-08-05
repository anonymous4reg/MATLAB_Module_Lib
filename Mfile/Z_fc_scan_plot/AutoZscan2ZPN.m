function [retZPDSISO, retZNDSISO, ...
          retZPDMIMO, retZNDMIMO] = AutoZscan2ZPN(InputCmdCell)

SrcFileDir  =   InputCmdCell{1};
NameMatrix  = { InputCmdCell{2} };
Freq_begin  =   InputCmdCell{3};
Freq_middle =   InputCmdCell{4};
Freq_end    =   InputCmdCell{5};
Freq_step   =   InputCmdCell{6};
Step        =   InputCmdCell{7}; % Sample time of data(us)
SaveTempsFlag = InputCmdCell{8};





% SrcFileDir = 'C:\Users\ym\Desktop\test\'
% NameMatrix = {'Lfile_2'};
OutSubDir = '1-250Hz\';

% Freq_begin=1;
% Freq_middle = 100;
% Freq_end=350;
% Freq_step=1;
% Step = 100;%20; %仿真步长单位us,举例如果仿真步长是20us,输入20即可
NN=1/Step*10^6;
%% 将扫频数据命名为下面矩阵名称形式
%风机或者光伏



for i=1:length(NameMatrix)

    filename = [NameMatrix{i}];
    OutRoot=[SrcFileDir, '\', OutSubDir, '\'];
    mkdir(OutRoot);
    Data = load([SrcFileDir, '\', filename  '.mat']);
   %% 计算1~100Hz
    
    [Ip_f_1_350,Vp_f_1_350,Ip_coupled1_350,Vp_coupled1_350] = ScanImpedanceP(Freq_begin,Freq_end,Freq_step,NN,Data);
    Ip1 = Ip_f_1_350(1,Freq_begin:Freq_middle);
    Vp1 = Vp_f_1_350(1,Freq_begin:Freq_middle);
    Ip_coupled1 = Ip_coupled1_350(1,Freq_begin:Freq_middle);
    Vp_coupled1 = Vp_coupled1_350(1,Freq_begin:Freq_middle);
    Ip2 = fliplr(Ip_coupled1);
    Vp2 = fliplr(Vp_coupled1);
    Ip_coupled2 = fliplr(Ip1);
    Vp_coupled2 = fliplr(Vp1);
    [ZPD1_99,ZND_n99_n1]= ScanImpedance2plusV5(Freq_begin,Freq_middle,Freq_step,Ip1,Vp1,Ip_coupled1,Vp_coupled1,Ip2,Vp2,Ip_coupled2,Vp_coupled2);
    
    %% 计算101~250Hz
    Ip3 = Ip_f_1_350(1,Freq_middle+1:Freq_end-1);
    Vp3 = Vp_f_1_350(1,Freq_middle+1:Freq_end-1);
    Ip_coupled3 = Ip_coupled1_350(1,Freq_middle+1:Freq_end-1);
    Vp_coupled3 = Vp_coupled1_350(1,Freq_middle+1:Freq_end-1);
    [In4temp,Vn4temp,In_coupled4temp,Vn_coupled4temp] = ScanImpedanceN(Freq_begin,Freq_end,Freq_step,NN,Data);
    In4 = In4temp(1,Freq_begin:Freq_end-Freq_middle-1);
    Vn4 = Vn4temp(1,Freq_begin:Freq_end-Freq_middle-1);
    In_coupled4 = In_coupled4temp(1,Freq_middle:Freq_end-1);
    Vn_coupled4 = Vn_coupled4temp(1,Freq_middle:Freq_end-1);
    Ip4 = In_coupled4;
    Vp4 = Vn_coupled4;
    Ip_coupled4 = In4;
    Vp_coupled4 = Vn4;
    [ZPD100_349,ZND_1_249]= ScanImpedance2plusV5(Freq_middle+1,Freq_end,Freq_step,Ip3,Vp3,Ip_coupled3,Vp_coupled3,Ip4,Vp4,Ip_coupled4,Vp_coupled4);

    ZPD = [ZPD1_99;ZPD100_349];
    ZND = [ZND_n99_n1;ZND_1_249];
    ZPD_MIMO = ZPD; % save a copy for variable name consistence without changing original code
    ZND_MIMO = ZND;

    %测试用，正序+负序处理程序形成SISO阻抗
    [ZPD_SISO,ZND_SISO]=U_I_Z_F_1hz_1_250(Freq_begin,Freq_end,Freq_step,NN,Data);

    retZPDSISO = ZPD_SISO;
    retZNDSISO = ZND_SISO;
    retZPDMIMO = ZPD;
    retZNDMIMO = ZND;

    if SaveTempsFlag == true
        save(strcat(OutRoot, 'DATA_ZPD_SISO.mat'), 'ZPD_SISO');
        save(strcat(OutRoot, 'DATA_ZND_SISO.mat'), 'ZND_SISO');
        save(strcat(OutRoot, 'DATA_ZPD_MIMO.mat'), 'ZPD_MIMO');
        save(strcat(OutRoot, 'DATA_ZND_MIMO.mat'), 'ZND_MIMO');

        save(strcat(OutRoot, 'Vp_coupled1.mat'), 'Vp_coupled1')
        save(strcat(OutRoot, 'Vp_coupled2.mat'), 'Vp_coupled2')
        save(strcat(OutRoot, 'Vp_coupled3.mat'), 'Vp_coupled3')
        save(strcat(OutRoot, 'Vp_coupled4.mat'), 'Vp_coupled4')

        save(strcat(OutRoot, 'Ip_coupled1.mat'), 'Ip_coupled1')
        save(strcat(OutRoot, 'Ip_coupled2.mat'), 'Ip_coupled2')
        save(strcat(OutRoot, 'Ip_coupled3.mat'), 'Ip_coupled3')
        save(strcat(OutRoot, 'Ip_coupled4.mat'), 'Ip_coupled4')
    end


    
    % figure
    % subplot(2,1,1);
    % plot(ZPD(:,1),20*log10(ZPD(:,2)),'r');
    % hold on;
    % plot(ZPD_SISO(:,1),20*log10(ZPD_SISO(:,2)),'b');
    % xlabel('频率(Hz)');
    % ylabel('幅值(dB)');
    % legend('聚合new','正负序无耦合SISO')
    % title('正序阻抗')
    % subplot(2,1,2);
    % hold on;
    % plot(ZPD(:,1),ZPD(:,3),'r');
    % plot(ZPD_SISO(:,1),ZPD_SISO(:,3),'b');
    % xlabel('频率(Hz)');
    % ylabel('相角(度)');
    % saveas(gca, '频耦正序阻抗.fig')
    % saveas(gca, '频耦正序阻抗.tiff')
    
    % figure
    % subplot(2,1,1);
    % plot(ZND(:,1),20*log10(ZND(:,2)),'r');
    % hold on;
    % plot(ZND_SISO(:,1),20*log10(ZND_SISO(:,2)),'b');
    % xlabel('频率(Hz)');
    % ylabel('幅值(dB)');
    % legend('聚合new','正负序无耦合SISO')
    % title('负序阻抗')
    % subplot(2,1,2);
    % plot(ZND(:,1),ZND(:,3),'r');
    % hold on;
    % plot(ZND_SISO(:,1),ZND_SISO(:,3),'b');
    % xlabel('频率(Hz)');
    % ylabel('相角(度)');
    % saveas(gca, '频耦负序阻抗.fig')
    % saveas(gca, '频耦负序阻抗.tiff') 


end

