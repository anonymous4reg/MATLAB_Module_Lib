%% User could change here
SrcDir = 'E:\HW_FuNing_data\';  % Your .mat file location
DstDir = SrcDir;  % where your doc will be generated

WordFileName = 'rpt_autogen.doc';  % your doc name
WordFileUrl = strcat(DstDir, WordFileName); 
WordTitle = '¸§ÄþÔË´ïºÌÍû3.0MW';   % title of your report

PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u130', 'u125', 'u120'};
PostfixCell = {'p1.0', 'p0.2'};
SubFolderCell = f_sequence_gen_recursive({PrefixCell, PhaseCell, DipCell, PostfixCell, }, '_');
SubFolderCell = SubFolderCell{1};


%% Main program here
tic
fun_word_title(WordTitle, 32, WordFileUrl)
for file_idx=1:length(SubFolderCell)
	sub_folder_name = SubFolderCell{file_idx};
    sub_folder_dir = [SrcDir, '\', sub_folder_name];
    fun_word_title(sub_folder_name, 15, WordFileUrl)
    
	disp(strcat('[', num2str(file_idx), '/', num2str(length(SubFolderCell)) , '] - ', ...
        'Working on: ', SubFolderCell{file_idx}))
    
    fig_url = strcat(sub_folder_dir, '\', 'U+.emf');
    fun_word_figure(fig_url, 'U+', WordFileUrl)
    
    fig_url = strcat(sub_folder_dir, '\', 'PQ+.emf');
    fun_word_figure(fig_url, 'PQ+', WordFileUrl)
    
    fig_url = strcat(sub_folder_dir, '\', 'IpIq+.emf');
    fun_word_figure(fig_url, 'IpIq+', WordFileUrl)
    
%     break

end
toc