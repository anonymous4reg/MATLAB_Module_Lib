% 2020/10/20 - version 1: Generate report automatically
% will recognize mat-file and variable automatically according to 
% __MatFilePrefix__ and __VarNamePrefix__, these two var act as
% regular expression
clear;clc
RootDir = "D:\Work\新能源工作\[Routine] 建模\20200923_佩特DFIG2.0MW\HaiDe_DFIG_2MW_matfile\02-mat_file\";

% Idle case processing
PrefixCell = {'VRT'};

PostfixCell = {'p2.0', 'p0.4'};

PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
SubFolderCell = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell}, '_');

SubFolderCell = SubFolderCell{1};

FigureNameCell = {'U+', 'P+', 'Q+', 'Ip+', 'Iq+'};
FigureType = '.emf';
ReportTitle = 'Haide DLL test';

tic

% Import report API classes (optional)
import mlreportgen.report.*
import mlreportgen.dom.*

% Add report container (required)
rpt = Report(ReportTitle,'docx');

% Add content to container (required)
% Types of content added here: title 
% page and table of contents reporters
titlepg = TitlePage;
titlepg.Title = ReportTitle;
titlepg.Author = 'NCEPRI';
add(rpt,titlepg);
add(rpt,TableOfContents);

for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, SubFolderCell{each_folder}, "\");
    disp(sub_folder_dir);
    
    % Add content to report sections (optional)
    % Text and formal image added to chapter
    chap = Chapter(SubFolderCell{each_folder});
    add(chap, SubFolderCell{each_folder});
    
    for each_fig = 1:length(FigureNameCell)
%         p = Paragraph(chap,FormalImage('Image',...
%             strcat(sub_folder_dir, strcat(FigureNameCell{each_fig}, FigureType)),'Height','3in',...
%             'Width','4in','Caption', FigureNameCell{each_fig}));
%         add(chap,FormalImage('Image',...
%             strcat(sub_folder_dir, strcat(FigureNameCell{each_fig}, FigureType)),'Height','3in',...
%             'Width','4in','Caption', FigureNameCell{each_fig}));
%         add(rpt,chap);
        image = FormalImage('Image',...
            strcat(sub_folder_dir, strcat(FigureNameCell{each_fig}, FigureType)),'Height','4.5in',...
            'Width','6.5in','Caption', FigureNameCell{each_fig});
        append(chap, Section('Title', ...
            FigureNameCell{each_fig}, ...
            'Content', ...
            image));
    end
    add(rpt,chap);
    
	break  % debug only
	
end
% Close the report (required)
close(rpt);
% Display the report (optional)
rptview(rpt);
disp('Compléter.')
toc
