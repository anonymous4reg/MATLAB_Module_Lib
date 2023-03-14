%% version 0.3, 
% modified by Yamin, 2021/11/12
% description: process Low and High freq and combine them in one .m file
clear;clc
RootDir = 'E:\YuDaiWan\02-data\02-Scan_data\ZC\';
% RootDir = "F:\SG1250_Data\Zscan\1-250Hz\";
% Mat file name prefix, program will search related files in each folder
MatFilePrefixCell = {"Lfile", "Hfile"};

% Variable name prefix, after loading a .mat file, program will search related variable name
VarNamePrefixCell = {"Lscan", "Hscan"};
% Idle case processing



PsetCell = {'P1.0'};
QsetCell = {'Q0.0'};
FreqCell = {'Low', 'High'};  % Low or High


SubFolderCell = f_sequence_gen_recursive({PsetCell, QsetCell}, '-');
SubFolderCell = SubFolderCell{1};
SubFolderCell = {'U0.95'}

setFontSize = 10;
ExportFig = true;
ExportEmf = true;
ExportPng = true;
ExportTiff = false;
ExportEps = false;
ExportSvg = false;
ExportResolution = '300'; %dpi

tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder}, "\");
	% sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	sub_folder_files = dir(sub_folder_dir);
	sub_folder_files = {sub_folder_files([sub_folder_files.isdir] == 0).name};

	% file_input
	% User input para here!!!
	for freq_idx = 1:length(FreqCell)
		% Process low et high frequency file
		Freq = FreqCell{freq_idx};
		disp(strcat('Processing ', Freq, ' ...'))
		MatFilePrefix = MatFilePrefixCell{freq_idx};
		VarNamePrefix = VarNamePrefixCell{freq_idx};
		file_wanted = sub_folder_files(~cellfun(@isempty, regexpi(sub_folder_files, strcat(MatFilePrefix, '.*(mat)'))));
		if length(file_wanted) == 1
		% If only ONE suitable .mat file founded, then do it.
			clearvars -except RootDir PrefixCell PhaseCell DipCell PostfixCell SubFolderCell each_folder ...
							sub_folder_dir sub_folder_files MatFilePrefix VarNamePrefix FreqCell ...
							setFontSize ExportFig ExportEmf ExportPng ExportTiff ...
	                        ExportEps ExportSvg ExportResolution Freq MatFilePrefixCell VarNamePrefixCell...
                            file_wanted ZPD_low ZND_low ZPD_high ZND_high
	        %% load file according to Low or High
			disp(strcat("Loading ", file_wanted, " ..."))

			% load(strcat(sub_folder_dir, file_wanted{1}))
			file_to_process_url = strcat(sub_folder_dir, file_wanted{1});

            try
                if strcmp(Freq, 'Low') == 1
                    file_name_splite = split(file_wanted{1}, '.');
                    file_name_without_postfix = file_name_splite{1};
                    SrcFileDir  =   sub_folder_dir;
                    FileName    =   file_name_without_postfix;
                    Freq_begin  =   1;
                    Freq_middle =   100;
                    Freq_end    =   350;
                    Freq_step   =   1;
                    SampleTimeMicroSecond  =   100; % Sample time of data(us)
                    SaveTempsFlag = true;
                    
                    %% DON NOT Change this block !!!
                    CmdCell = {
                        SrcFileDir, FileName, Freq_begin, Freq_middle, ...
                        Freq_end, Freq_step, SampleTimeMicroSecond, SaveTempsFlag};
                    
                    sub_freq_dir = strcat(sub_folder_dir, '/1-250Hz/');
                    [ZPD_SISO, ZND_SISO] = AutoZscan2ZPN(CmdCell);
                    ZPD_low = ZPD_SISO;
                    ZND_low = ZND_SISO;
                elseif strcmp(Freq, 'High') == 1
                    tmp_data = load(strcat(sub_folder_dir, file_wanted{1}));
                    tmp_data = struct2cell(tmp_data); tmp_data = cell2mat(tmp_data);

                    file_name_splite = split(file_wanted{1}, '.');
                    file_name_without_postfix = file_name_splite{1};
                    SrcFileDir  =   sub_folder_dir;
                    FileName    =   file_name_without_postfix;
                    Freq_middle =   100;
                    Freq_begin  =   250;
                    Freq_end    =   2500;
                    Freq_step   =   10;
                    SampleTimeMicroSecond = 20;
                    SaveTempsFlag = true;
                    
                    %% DON NOT Change this block !!!
                    CmdCell = {
                        SrcFileDir, FileName, Freq_begin, Freq_middle, ...
                        Freq_end, Freq_step, SampleTimeMicroSecond, SaveTempsFlag};

                    [ZPD_SISO, ZND_SISO] = U_I_Z_F_StepAuto(CmdCell);
                    sub_freq_dir = strcat(sub_folder_dir, '/250-2500Hz/');
                    ZPD_high = ZPD_SISO;
                    ZND_high = ZND_SISO;
                else
                    disp('Please set __Freq__ properly, either Low or High')
                end
                
%                 mkdir(sub_freq_dir)
%                 %% Save mat file
%                 ZPD=ZPD_SISO;
%                 save(strcat(sub_freq_dir, '\', 'DATA_ZPD.mat'), 'ZPD')
% %                 save(strcat(sub_freq_dir, '\', 'DATA_ZPD_', SubFolderCell{each_folder}, '_', Freq,'.mat'), 'ZPD')
%                 ZND=ZND_SISO;
%                 save(strcat(sub_freq_dir, '\', 'DATA_ZND.mat'), 'ZND')
% %                 save(strcat(sub_freq_dir, '\', 'DATA_ZND_', SubFolderCell{each_folder}, '_', Freq, '.mat'), 'ZND')
                
                ZPD = ZPD_SISO;
                ZND = ZND_SISO;
                %%
			    figure
			    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
			    subplot(2,1,1);
			    plot(ZPD(:,1), 20*log10(ZPD(:,2)), '.-', 'MarkerIndices', 1:2:length(ZPD), 'color', 'k', ...
				    'linewidth', 1.0, 'color', 'k');
			    xlabel('Frequency (Hz)');
			    ylabel('Amplitude (dB)');
			    title(strcat(SubFolderCell{each_folder}, ' - ', 'Positive Sequence'))
			    grid on
			    set(gca, 'fontname', 'Times new roman')
			    subplot(2,1,2);
                f_plot_risk_area_mmc_hvdc(1); 
			    plot(ZPD(:,1),ZPD(:,3), '.-', 'MarkerIndices', 1:2:length(ZPD), 'color', 'k', ...
				    'linewidth', 1.0, 'color', 'k');
			    xlabel('Frequency (Hz)');
			    ylabel('Phase (Deg)');
			    grid on
                if strcmp(Freq, 'Low') == 1
                    set(gca, 'xlim', [0, 350])
                elseif strcmp(Freq, 'High') == 1
                    set(gca, 'xlim', [350, 2500])
                end
			    set(gca, 'fontname', 'Times new roman')
                
                
                f_savefig(sub_freq_dir, 'ZP_BodePlot_SISO', {'fig', 'png'}, 300)


                

			    figure
			    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
			    subplot(2,1,1);
			    plot(ZND(:,1), 20*log10(ZND(:,2)), '.-', 'MarkerIndices', 1:2:length(ZND), 'color', 'k', ...
				    'linewidth', 1.0, 'color', 'k');
			    xlabel('Frequency (Hz)');
			    ylabel('Amplitude (dB)');
			    title(strcat(SubFolderCell{each_folder}, ' - ', 'Negative Sequence'))
			    grid on
			    set(gca, 'fontname', 'Times new roman')
			    subplot(2,1,2);
			    plot(ZND(:,1),ZND(:,3), '.-', 'MarkerIndices', 1:2:length(ZND), 'color', 'k', ...
				    'linewidth', 1.0, 'color', 'k');
			    xlabel('Frequency (Hz)');
			    ylabel('Phase (Deg)');
			    grid on
			    set(gca, 'fontname', 'Times new roman')
                f_savefig(sub_freq_dir, 'ZN_BodePlot_SISO', {'fig', 'png'}, 300)


            

            close all

            catch ME
                disp('something wrong')
                rethrow(ME)  % debug only
            end

        elseif length(sub_folder_files) > 1
        % If multiple .mat file founded, then leave this folder untouched.
            disp(strcat("Multiple ", MatFilePrefix, "*.mat files found in folder: ", sub_folder_dir))
            disp(sub_folder_files)
            disp('Please resolve them manually.')					
            
        elseif length(sub_folder_files) == 0
            disp(strcat('No MAT-File in this path: ', sub_folder_dir))
            disp('Pass...')
        else
            disp("Shit happened")
        end

        

    end
        
    disp('Combining low and high frequency ZPD/ZND files ...')
    sub_freq_dir = strcat(sub_folder_dir, '/1-2500Hz/');
    mkdir(sub_freq_dir)
    ZPD_all = [ZPD_low; ZPD_high];
    ZND_all = [ZND_low; ZND_high];

    ZPD = ZPD_all;
    ZND = ZND_all;
    save(strcat(sub_freq_dir, '\', 'DATA_ZPD_SISO.mat'), 'ZPD')
    save(strcat(sub_freq_dir, '\', 'DATA_ZPD_', SubFolderCell{each_folder}, '_', Freq,'.mat'), 'ZPD')
    save(strcat(sub_freq_dir, '\', 'DATA_ZND_SISO.mat'), 'ZND')
    save(strcat(sub_freq_dir, '\', 'DATA_ZND_', SubFolderCell{each_folder}, '_', Freq, '.mat'), 'ZND')


    figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    semilogx(ZPD_all(:,1), 20*log10(ZPD_all(:,2)), '.-', 'MarkerIndices', 1:2:length(ZPD_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (dB)');
    title(strcat(SubFolderCell{each_folder}, ' - ', 'Positive Sequence'))
    grid on
    set(gca, 'fontname', 'Times new roman')
    subplot(2,1,2);
    semilogx(ZPD_all(:,1),ZPD_all(:,3), '.-', 'MarkerIndices', 1:2:length(ZPD_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'Times new roman')
    f_savefig(sub_freq_dir, 'ZP_BodeLogPlot_SISO', {'fig', 'png'}, 300)

    
    figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    semilogx(ZND_all(:,1), 20*log10(ZND_all(:,2)), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (dB)');
    title(strcat(SubFolderCell{each_folder}, ' - ', 'Negative Sequence'))
    grid on
    set(gca, 'fontname', 'Times new roman')
    subplot(2,1,2);
    semilogx(ZND_all(:,1),ZND_all(:,3), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'Times new roman')
    f_savefig(sub_freq_dir, 'ZN_BodeLogPlot_SISO', {'fig', 'png'}, 300)

    

    close all
end				
	
	
% 	break  % debug only
	

disp('Done')
toc
