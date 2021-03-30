function fun_word_table_GoodorFail_NBT31053(data,name)
%����MATLAB����Word�ĵ�
%	ԭժ��xiezhh��������̳�ϵ���ؽ��飬������΢�ĸĶ�������

filespec_user = [pwd '\BPA��RTLAB�Ա�-����ж�.doc'];

%===����word���ù���========================================================
try    
    Word = actxGetRunningServer('Word.Application');
catch    
    Word = actxserver('Word.Application'); 
end
Word.Visible = 1; % ʹwordΪ�ɼ�����set(Word, 'Visible', 1); 
%===��word�ļ������·����û���򴴽�һ���հ��ĵ���========================
if exist(filespec_user,'file'); 
    Document = Word.Documents.Open(filespec_user);    
else
    Document = Word.Documents.Add;     
    Document.SaveAs2(filespec_user);
end
%===��ʽ����===============================================================
Content = Document.Content;
Selection = Word.Selection;
Paragraphformat = Selection.ParagraphFormat;
%===�ĵ���ҳ�߾�===========================================================
Document.PageSetup.TopMargin    = 60;
Document.PageSetup.BottomMargin = 45;
Document.PageSetup.LeftMargin   = 45;
Document.PageSetup.RightMargin  = 45;
%==========================================================================
%�����ͷ
%�趨�������ݵ���ʼλ�ã������������ߣ� 
% Selection.TypeParagraph; 
Selection.Start = Content.end;
Selection.TypeParagraph;
Selection.Text = name;
Selection.Font.Size = 12;
Paragraphformat.Alignment = 'wdAlignParagraphCenter';
set(Paragraphformat, 'Alignment','wdAlignParagraphCenter'); 
Selection.MoveDown;
% ������
Selection.TypeParagraph;% ����һ���µĿն���
Selection.Font.Size = 8;% �µĿն����ֺ�
Selection.Start     = Content.end;
% Selection.TypeParagraph;
Paragraphformat.Alignment = 'wdAlignParagraphLeft';
Selection.MoveDown;

Errorstable = Document.Tables.Add(Selection.Range,8,14);    % ����һ��13��10�еı��
% DTI = Document.Tables.Item(1); % �����
DTI = Errorstable; % �����
DTI.Borders.OutsideLineStyle    = 'wdLineStyleSingle';  % �����ʵ��
DTI.Borders.OutsideLineWidth    = 'wdLineWidth100pt';   % �߿�
DTI.Borders.InsideLineStyle     = 'wdLineStyleSingle';  % ���е��ڿ�����
DTI.Borders.InsideLineWidth     = 'wdLineWidth150pt';   % �߿�
DTI.Rows.Alignment                          = 'wdAlignRowCenter'; %�������
% DTI.Rows.Item(8).Borders.Item(1).LineStyle  = 'wdLineStyleNone'; % �ڰ��е��ϱ�����ʧ
DTI.Rows.Item(2).Borders.Item(3).LineStyle  = 'wdLineStyleNone';% �ڰ��е��±���r��ʧ
% DTI.Rows.Item(11).Borders.Item(1).LineStyle = 'wdLineStyleNone';
% DTI.Rows.Item(11).Borders.Item(3).LineStyle = 'wdLineStyleNone';

% �����иߣ��п�
column_width = [35,35,32,32,32,35,32,32,32,32,32,32,32,32];
row_height = [12,8,8,12,12,12,12,12];
% column_width = [53.7736,85.1434,53.7736,35.0094,...
%     35.0094,76.6981,55.1887,52.9245,54.9057];
% row_height = [28.5849,28.5849,28.5849,28.5849,25.4717,25.4717,...
%     32.8302,312.1698,17.8302,49.2453,14.1509,18.6792];
for i = 1:14
    DTI.Columns.Item(i).Width = column_width(i);
end

for i = 1:8
    DTI.Rows.Item(i).Height = row_height(i);
end
% ���ô�ֱ����
for i = 1:8        % ��
    for j = 1:14     % ��
        DTI.Cell(i,j).VerticalAlignment = 'wdCellAlignVerticalCenter';
    end
end

% �ϲ���Ԫ��
DTI.Cell(1, 2).Merge(DTI.Cell(1, 4)); % �ϲ�
DTI.Cell(1, 3).Merge(DTI.Cell(1, 6));
DTI.Cell(1, 4).Merge(DTI.Cell(1, 6));
DTI.Cell(1, 5).Merge(DTI.Cell(1, 7));
DTI.Cell(2, 1).Merge(DTI.Cell(3, 1));
DTI.Cell(2, 5).Merge(DTI.Cell(3, 5));
DTI.Cell(2, 9).Merge(DTI.Cell(3, 9));
DTI.Cell(2, 10).Merge(DTI.Cell(3, 10));
DTI.Cell(2, 11).Merge(DTI.Cell(3, 11));
DTI.Cell(2, 12).Merge(DTI.Cell(3, 12));
DTI.Cell(2, 13).Merge(DTI.Cell(3, 13));
DTI.Cell(2, 14).Merge(DTI.Cell(3, 14));
DTI.Cell(4, 9).Merge(DTI.Cell(8, 9));
DTI.Cell(4, 10).Merge(DTI.Cell(8, 10));
DTI.Cell(4, 11).Merge(DTI.Cell(8, 11));
% �������е�����%num2str(a(2,1))
DTI.Cell(1,1).Range.Text = '����';
DTI.Cell(1,2).Range.Text = '����ƽ��ƫ��';
DTI.Cell(1,3).Range.Text = '����ƽ������ƫ��';
DTI.Cell(1,4).Range.Text = '��Ȩƽ������ƫ��';
DTI.Cell(1,5).Range.Text = '��̬�������ƫ��';
DTI.Cell(2,1).Range.Text = '������';
DTI.Cell(4,1).Range.Text = 'A';
DTI.Cell(5,1).Range.Text = 'B1';
DTI.Cell(6,1).Range.Text = 'B2';
DTI.Cell(7,1).Range.Text = 'C1';
DTI.Cell(8,1).Range.Text = 'C2';
DTI.Cell(2,2).Range.Text = 'F1_IQ/';
DTI.Cell(3,2).Range.Text = 'F2_IQ';
DTI.Cell(2,3).Range.Text = 'F1_P/';
DTI.Cell(3,3).Range.Text = 'F2_P';
DTI.Cell(2,4).Range.Text = 'F1_Q/';
DTI.Cell(3,4).Range.Text = 'F2_Q';
DTI.Cell(2,5).Range.Text = 'F_U';
DTI.Cell(2,6).Range.Text = 'F3_IQ/';
DTI.Cell(3,6).Range.Text = 'F4_IQ';
DTI.Cell(2,6).Range.Text = 'F3_IQ/';
DTI.Cell(3,6).Range.Text = 'F4_IQ';
DTI.Cell(2,7).Range.Text = 'F3_P/';
DTI.Cell(3,7).Range.Text = 'F4_P';
DTI.Cell(2,8).Range.Text = 'F3_Q/';
DTI.Cell(3,8).Range.Text = 'F4_Q';
DTI.Cell(2,9).Range.Text = 'FG_IQ';
DTI.Cell(2,10).Range.Text = 'FG_P';
DTI.Cell(2,11).Range.Text = 'FG_Q';
DTI.Cell(2,12).Range.Text = 'F5_IQ';
DTI.Cell(2,13).Range.Text = 'F5_P';
DTI.Cell(2,14).Range.Text = 'F5_Q';

ERROR_NB = [0.07 0.07 0.05 0.05  0.1 0.1 0.07 0.15 0.15 0.15 0.15 0.15 0.1;
            0.2 0.2 0.2 NaN 0.3 0.25 0.25 NaN NaN NaN NaN NaN NaN;
            0.07 0.07 0.05 0.05 0.1 0.1 0.07 NaN NaN NaN 0.15 0.15 0.1;
            0.2 0.2 0.2 NaN 0.3 0.25 0.25 NaN NaN NaN NaN NaN NaN;
            0.07 0.07 0.05 0.05 0.1 0.1 0.07 NaN NaN NaN 0.15 0.15 0.1];
for i=1:5
    for j=1:13
        if (i==2||i==4)&&(j==4||j==11||j==12||j==13)
            DTI.Cell(i+3,j+1).Range.Text = '/';
        else
            if j==8||j==9||j==10
               if data(1,8)>ERROR_NB(1,8)
                  DTI.Cell(4,9).Range.Text = '��';
               else
                  DTI.Cell(4,9).Range.Text = '��'; 
               end
               if data(1,9)>ERROR_NB(1,9)
                  DTI.Cell(4,10).Range.Text = '��';
               else
                  DTI.Cell(4,10).Range.Text = '��'; 
               end
               if data(1,10)>ERROR_NB(1,10)
                  DTI.Cell(4,11).Range.Text = '��';
               else
                  DTI.Cell(4,11).Range.Text = '��'; 
               end
            else
                if data(i,j)>ERROR_NB(i,j)
                  DTI.Cell(i+3,j+1).Range.Text = '��';
                else
                  DTI.Cell(i+3,j+1).Range.Text = '��';  
                end
            end               
        end
    end
end
% Selection.MoveDown;
% Selection.TypeParagraph; 
Document.Save;  % �����ĵ�