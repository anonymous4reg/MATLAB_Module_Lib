function fun_word_title(name, font_size, word_file_url)
% Generate a title in Word
%   Detailed explanation goes here

if nargin == 2
    filespec_user = [pwd, '\', 'rpt_autogen.doc'];
elseif nargin == 3
    filespec_user = word_file_url;
end

%===����word���ù���========================================================
try    
    Word = actxGetRunningServer('Word.Application');
catch    
    Word = actxserver('Word.Application'); 
end
Word.Visible = 1; % ʹwordΪ�ɼ�����set(Word, 'Visible', 1); 
%===��word�ļ������·����û���򴴽�һ���հ��ĵ���========================
if exist(filespec_user,'file')
    document = Word.Documents.Open(filespec_user);    
else
    document = Word.Documents.Add;     
    document.SaveAs2(filespec_user);
end
%===��ʽ����===============================================================
content = document.Content;
selection = Word.Selection;
paragraphformat = selection.ParagraphFormat;
%===�ĵ���ҳ�߾�===========================================================
% document.PageSetup.TopMargin    = 60;
% document.PageSetup.BottomMargin = 45;
% document.PageSetup.LeftMargin   = 45;
% document.PageSetup.RightMargin  = 45;
%==========================================================================
%�趨������ʼλ�úͱ���
% set(content, 'Start',0); 
% title='��  ��  ��  ��';
% set(content, 'Text',title); 
% set(paragraphformat, 'Alignment','wdAlignParagraphCenter');    
% ���� % set(paragraphformat, 'Alignment','wdAlignParagraphLeft');    
% ���� % set(paragraphformat, 'Alignment','wdAlignParagraphRight');   
% ���� %�趨���������ʽ 
% rr=document.Range(0,10);  
% rr.Font.Size=18;                                               % �����С���� 
% rr.Font.Bold=4;                                                % ��������Ӵ� 
%�趨�������ݵ���ʼλ�ã������������ߣ� 
end_of_doc = get(content,'end'); 
set(selection,'Start',end_of_doc);
%����һ��  
selection.TypeParagraph;  
% ���֮��Ķ���
selection.Start = content.end;
% selection.TypeParagraph;
% paragraphformat.Alignment = 'wdAlignParagraphLeft';
% set(paragraphformat, 'Alignment','wdAlignParagraphLeft'); 
selection.Text = name;
selection.Font.Size = font_size;
selection.Font.Bold = 1;
selection.Font.name = '����';
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
document.Save;  % �����ĵ�