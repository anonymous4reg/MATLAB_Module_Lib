function fun_word_title(name, font_size, word_file_url)
% Generate a title in Word
%   Detailed explanation goes here

if nargin == 2
    filespec_user = [pwd, '\', 'rpt_autogen.doc'];
elseif nargin == 3
    filespec_user = word_file_url;
end

%===启用word调用功能========================================================
try    
    Word = actxGetRunningServer('Word.Application');
catch    
    Word = actxserver('Word.Application'); 
end
Word.Visible = 1; % 使word为可见；或set(Word, 'Visible', 1); 
%===打开word文件，如果路径下没有则创建一个空白文档打开========================
if exist(filespec_user,'file')
    document = Word.Documents.Open(filespec_user);    
else
    document = Word.Documents.Add;     
    document.SaveAs(filespec_user);
end
%===格式定义===============================================================
content = document.Content;
selection = Word.Selection;
paragraphformat = selection.ParagraphFormat;
%===文档的页边距===========================================================
% document.PageSetup.TopMargin    = 60;
% document.PageSetup.BottomMargin = 45;
% document.PageSetup.LeftMargin   = 45;
% document.PageSetup.RightMargin  = 45;
%==========================================================================
%设定内容起始位置和标题
% set(content, 'Start',0); 
% title='测  试  文  件';
% set(content, 'Text',title); 
% set(paragraphformat, 'Alignment','wdAlignParagraphCenter');    
% 居中 % set(paragraphformat, 'Alignment','wdAlignParagraphLeft');    
% 居左 % set(paragraphformat, 'Alignment','wdAlignParagraphRight');   
% 居右 %设定标题字体格式 
% rr=document.Range(0,10);  
% rr.Font.Size=18;                                               % 字体大小设置 
% rr.Font.Bold=4;                                                % 设置字体加粗 
%设定下面内容的起始位置（将光标放在最后边） 
end_of_doc = get(content,'end'); 
set(selection,'Start',end_of_doc);
%另起一段  
selection.TypeParagraph;  
% 表格之后的段落
selection.Start = content.end;
% selection.TypeParagraph;
% paragraphformat.Alignment = 'wdAlignParagraphLeft';
% set(paragraphformat, 'Alignment','wdAlignParagraphLeft'); 
selection.Text = name;
selection.Font.Size = font_size;
selection.Font.Bold = 1;
selection.Font.name = '宋体';
selection.Font.name = 'Times New Roman';
set(paragraphformat,'outlineLevel', 3);
set(paragraphformat,'spaceBefore', 6);
set(paragraphformat,'leftIndent', 0);
paragraphformat.Alignment = 'wdAlignParagraphLeft';
% set(paragraphformat, 'Alignment','wdAlignParagraphJustify');
selection.MoveDown; 
selection.TypeParagraph; 
set(paragraphformat,'outlineLevel', 10);
set(paragraphformat,'spaceBefore', 0);
document.Save;  % 保存文档