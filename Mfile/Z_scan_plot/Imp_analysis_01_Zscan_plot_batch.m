%% version 0.3, 
% modified by Yamin, 2021/11/12
% description: process Low and High freq and combine them in one .m file
clear;clc
RootDir = "C:\Users\ym\Desktop\";
% RootDir = "F:\SG1250_Data\Zscan\1-250Hz\";
% Mat file name prefix, program will search related files in each folder
MatFilePrefixCell = {"Lfile", "Hfile"};
% MatFilePrefixCell = {"Lfile"};
% MatFilePrefixCell = {"Hfile"};

% Variable name prefix, after loading a .mat file, program will search related variable name
% VarNamePrefixCell = {"Lscan", "Hscan"};
VarNamePrefixCell = {"scan_concat"};
% VarNamePrefixCell = {"Hscan"};

% Idle case processing



PsetCell = {'P1.0'};
QsetCell = {'Q0.0'};

% FreqCell = {'Low', 'High'};  % Low or High
FreqCell = {'Low'};  % Low or High
% FreqCell = { 'High'};  % Low or High

SubFolderCell = {};

SubFolderCell = f_sequence_gen_recursive({PsetCell, QsetCell}, '-');
SubFolderCell = SubFolderCell{1};

SubFolderCell = {'THU_imp'};

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
		disp(append('Processing ', Freq, ' ...'))
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
			load(strcat(sub_folder_dir, file_wanted{1}))
			
			var_name_found = who;
			var_name_found = var_name_found(~cellfun(@isempty, regexpi(var_name_found, strcat(VarNamePrefix, '.*'))));
			if length(var_name_found) == 1
				scan_0 = eval(var_name_found{1});

                try
                    if strcmp(Freq, 'Low') == 1
                        U_I_Z_F
                        sub_freq_dir = append(sub_folder_dir, '/1-250Hz/');
                        ZPD_low = ZP;
                        ZND_low = ZN;
                    elseif strcmp(Freq, 'High') == 1
                        U_I_Z_F_10hz
                        sub_freq_dir = append(sub_folder_dir, '/250-2500Hz/');
                        ZPD_high = ZP;
                        ZND_high = ZN;
                    else
                        disp('Please set __Freq__ properly, either Low or High')
                    end
                    
                    mkdir(sub_freq_dir)
                    %% Save mat file
                    ZPD=ZP;
                    save(append(sub_freq_dir, '\', 'DATA_ZPD.mat'), 'ZPD')
                    save(append(sub_freq_dir, '\', 'DATA_ZPD_', SubFolderCell{each_folder}, '_', Freq,'.mat'), 'ZPD')
                    ZND=ZN;
                    save(append(sub_freq_dir, '\', 'DATA_ZND.mat'), 'ZND')
                    save(append(sub_freq_dir, '\', 'DATA_ZND_', SubFolderCell{each_folder}, '_', Freq, '.mat'), 'ZND')
                    
                    %%
                    this_file_path = append(sub_freq_dir, '\ZP_BodePlot_', SubFolderCell{each_folder});
				    figure
				    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
				    subplot(2,1,1);
				    plot(ZP(:,1), 20*log10(ZP(:,2)), '.-', 'MarkerIndices', 1:2:length(ZP), 'color', 'k', ...
					    'linewidth', 1.0, 'color', 'k');
				    xlabel('Frequency (Hz)');
				    ylabel('Magnitude (dB)');
				    title(append(SubFolderCell{each_folder}, ' - ', 'Positive Sequence'))
				    grid on
				    set(gca, 'fontname', 'Times new roman')
                    set(gca, 'xlim', [0, 250])
				    subplot(2,1,2);
                    f_plot_risk_area_mmc_hvdc(gca)
				    plot(ZP(:,1),ZP(:,3), '.-', 'MarkerIndices', 1:2:length(ZP), 'color', 'k', ...
					    'linewidth', 1.0, 'color', 'k');
				    xlabel('Frequency (Hz)');
				    ylabel('Phase (Deg)');
				    grid on
				    set(gca, 'fontname', 'Times new roman')
                    set(gca, 'xlim', [0, 250])
                    f_savefig(sub_freq_dir, 'ZP_BodePlot', {'fig', 'png'}, 300)
                    

                    this_file_path = append(sub_freq_dir, '\ZN_BodePlot_', SubFolderCell{each_folder});
				    figure
				    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
				    subplot(2,1,1);
				    plot(ZN(:,1), 20*log10(ZN(:,2)), '.-', 'MarkerIndices', 1:2:length(ZN), 'color', 'k', ...
					    'linewidth', 1.0, 'color', 'k');
				    xlabel('Frequency (Hz)');
				    ylabel('Magnitude (dB)');
				    title(append(SubFolderCell{each_folder}, ' - ', 'Negative Sequence'))
				    grid on
				    set(gca, 'fontname', 'Times new roman')
				    subplot(2,1,2);
				    plot(ZN(:,1),ZN(:,3), '.-', 'MarkerIndices', 1:2:length(ZN), 'color', 'k', ...
					    'linewidth', 1.0, 'color', 'k');
				    xlabel('Frequency (Hz)');
				    ylabel('Phase (Deg)');
				    grid on
				    set(gca, 'fontname', 'Times new roman')
                    f_savefig(sub_freq_dir, 'ZN_BodePlot', {'fig', 'png'}, 300)
                

                close all

                catch ME
                    disp('something wrong')
                    rethrow(ME)  % debug only
                end
            else
        	    disp(strcat("Multiple variables found in ", sub_folder_dir, sub_folder_files{1}))
			    disp(var_name_found)
			    disp("Please check your mat file! Pass...")
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
    sub_freq_dir = append(sub_folder_dir, '/1-2500Hz/');
    mkdir(sub_freq_dir)
    ZPD_all = [ZPD_low; ZPD_high];
    ZND_all = [ZND_low; ZND_high];

    ZPD = ZPD_all;
    ZND = ZND_all;
    save(append(sub_freq_dir, '\', 'DATA_ZPD.mat'), 'ZPD')
    save(append(sub_freq_dir, '\', 'DATA_ZPD_', SubFolderCell{each_folder}, '_', Freq,'.mat'), 'ZPD')
    save(append(sub_freq_dir, '\', 'DATA_ZND.mat'), 'ZND')
    save(append(sub_freq_dir, '\', 'DATA_ZND_', SubFolderCell{each_folder}, '_', Freq, '.mat'), 'ZND')

%     this_file_path = append(sub_freq_dir, '\ZP_BodePlot_', SubFolderCell{each_folder});
%     figure
%     set(gcf,'unit','centimeters','position',[10,5,18,8+3])
%     subplot(2,1,1);
%     semilogx(ZPD_all(:,1), 20*log10(ZPD_all(:,2)), '.-', 'MarkerIndices', 1:2:length(ZPD_all), 'color', 'k', ...
% 	    'linewidth', 1.0, 'color', 'k');
%     xlabel('Frequency (Hz)');
%     ylabel('Magnitude (dB)');
%     title(append(SubFolderCell{each_folder}, ' - ', 'Positive Sequence'))
%     grid on
%     set(gca, 'fontname', 'Times new roman')
%     subplot(2,1,2);
%     semilogx(ZPD_all(:,1),ZPD_all(:,3), '.-', 'MarkerIndices', 1:2:length(ZPD_all), 'color', 'k', ...
% 	    'linewidth', 1.0, 'color', 'k');
%     xlabel('Frequency (Hz)');
%     ylabel('Phase (Deg)');
%     grid on
%     set(gca, 'fontname', 'Times new roman')
% 
%     if ExportFig == true
%         saveas(gcf, append(this_file_path, '.fig'))
%     end 
%     if ExportEmf == true
%         saveas(gcf, append(this_file_path, '.emf'))
%     end 
%     if ExportEps == true
%         saveas(gcf, append(this_file_path, '.eps'), 'epsc')
%     end 
%     if ExportPng == true
%         print(append(this_file_path, '.png'), '-dpng', append('-r', ExportResolution))
%     end 
%     if ExportTiff == true
%         print(append(this_file_path, '.tif'), '-dtiff', append('-r', ExportResolution))
%     end

% 	this_file_path = append(sub_freq_dir, '\ZN_BodePlot_', SubFolderCell{each_folder});
%     figure
%     set(gcf,'unit','centimeters','position',[10,5,18,8+3])
%     subplot(2,1,1);
%     semilogx(ZND_all(:,1), 20*log10(ZND_all(:,2)), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
% 	    'linewidth', 1.0, 'color', 'k');
%     xlabel('Frequency (Hz)');
%     ylabel('Magnitude (dB)');
%     title(append(SubFolderCell{each_folder}, ' - ', 'Negative Sequence'))
%     grid on
%     set(gca, 'fontname', 'Times new roman')
%     subplot(2,1,2);
%     semilogx(ZND_all(:,1),ZND_all(:,3), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
% 	    'linewidth', 1.0, 'color', 'k');
%     xlabel('Frequency (Hz)');
%     ylabel('Phase (Deg)');
%     grid on
%     set(gca, 'fontname', 'Times new roman')
% 
%     if ExportFig == true
%         saveas(gcf, append(this_file_path, '.fig'))
%     end 
%     if ExportEmf == true
%         saveas(gcf, append(this_file_path, '.emf'))
%     end 
%     if ExportEps == true
%         saveas(gcf, append(this_file_path, '.eps'), 'epsc')
%     end 
%     if ExportPng == true
%         print(append(this_file_path, '.png'), '-dpng', append('-r', ExportResolution))
%     end 
%     if ExportTiff == true
%         print(append(this_file_path, '.tif'), '-dtiff', append('-r', ExportResolution))
%     end

    
    
    figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    plot(ZPD_all(:,1), 20*log10(ZPD_all(:,2)), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title(append(SubFolderCell{each_folder}, ' - ', 'Positive Sequence'))
    grid on
    set(gca, 'fontname', 'Times new roman')
    subplot(2,1,2);
    plot(ZPD_all(:,1),ZPD_all(:,3), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'Times new roman')
    f_savefig(sub_freq_dir, 'ZP_BodePlot_Linear', {'fig', 'png'}, 300)

    figure
    set(gcf,'unit','centimeters','position',[10,5,18,8+3])
    subplot(2,1,1);
    semilogx(ZND_all(:,1), 20*log10(ZND_all(:,2)), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title(append(SubFolderCell{each_folder}, ' - ', 'Negative Sequence'))
    grid on
    set(gca, 'fontname', 'Times new roman')
    subplot(2,1,2);
    semilogx(ZND_all(:,1),ZND_all(:,3), '.-', 'MarkerIndices', 1:2:length(ZND_all), 'color', 'k', ...
	    'linewidth', 1.0, 'color', 'k');
    xlabel('Frequency (Hz)');
    ylabel('Phase (Deg)');
    grid on
    set(gca, 'fontname', 'Times new roman')
    f_savefig(sub_freq_dir, 'ZN_BodePlot_Linear', {'fig', 'png'}, 300)

    close all
end				
	
	
% 	break  % debug only
	

disp('Compl¨¦ter.')
toc
