ProjectDir = 'D:\PJ\Matlab\MATLAB_Module_Lib\Mfile\report_generator\';

%% User could change here
SrcDir = ProjectDir;
DstDir = SrcDir;

WordFileUrl = [ProjectDir, 'rpt_autogen.doc'];

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u10%', 'u20%'};
PostfixCell = {'P1.0', 'P0.2'};
SubFolderCell = f_sequence_gen_recursive({DipCell, PostfixCell, PhaseCell}, '_');
SubFolderCell = SubFolderCell{1};


%% Main program here
tic
fun_word_title('Report test', 48, WordFileUrl)
for file_idx=1:length(SubFolderCell)
	sub_folder_name = SubFolderCell{file_idx};
    sub_folder_dir = [SrcDir, '\', sub_folder_name];
    
	disp(strcat("[", num2str(file_idx), "/", num2str(length(SubFolderCell)) , "] - ", ...
        "Working on: ", SubFolderCell{file_idx}))
    
    fun_word_title(sub_folder_name, 15, WordFileUrl)
    fun_word_figure('D:\PJ\Matlab\MATLAB_Module_Lib\Mfile\report_generator\test_figure.png', sub_folder_name, WordFileUrl)
end


toc