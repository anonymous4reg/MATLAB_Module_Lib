function fun_word_tabletitle(name)
%����MATLAB����Word�ĵ�
%	ԭժ��xiezhh��������̳�ϵ���ؽ��飬������΢�ĸĶ�������

filespec_user = [pwd '\BPA��RTLAB�Ա�.doc'];

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
% end_of_doc = get(content,'end'); 
% set(selection,'Start',end_of_doc);
% hgexport(fg, '-clipboard');  
% % copygraphics(fg);
% selection.Range.Paste; 
% paragraphformat.Alignment = 'wdAlignParagraphCenter';
%ɾ��ͼ�ξ�� 
% delete(fg); 
% selection.TypeParagraph; 
% ���֮��Ķ���
selection.Start = content.end;
selection.TypeParagraph;
selection.Text = name;
selection.Font.Size = 10.5;
selection.Font.Bold = 1;
selection.Font.name = '����';
selection.Font.name = 'Times New Roman';
paragraphformat.Alignment = 'wdAlignParagraphCenter';
% set(paragraphformat, 'Alignment','wdAlignParagraphCenter'); 
selection.MoveDown;
selection.Font.Bold = 0;
%����һ��  
selection.TypeParagraph;
document.Save;  % �����ĵ�