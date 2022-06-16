function AutoZscan2ZP22()
clear
clc

NN = 50000; %仿真步长de倒数

RootDir = 'D:\华锐维谛-ScanData\Vertiv2.5MW\test_fc_20220610 - v16\';

    Data1 = load([RootDir, 'Lfile_fc0'  '.mat']);

    ScanImpedance1(NN,Data1);
    
    Data2 = load([RootDir, 'Lfile_fc1'   '.mat']);

    ScanImpedance2(NN,Data2);

    ScanImpedance2plusV5;





