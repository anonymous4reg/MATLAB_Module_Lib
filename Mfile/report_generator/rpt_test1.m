%设定测试Word文件名和路径
filespec_user=[pwd '\me.doc'];
%判断Word是否已经打开，若已打开，就在打开的Word中进行操作，
%否则就打开Word
try
    Word = actxGetRunningServer('Word.Application');
catch
    Word = actxserver('Word.Application');
end
%设置Word属性为可见
set(Word, 'Visible', 1);
%返回Word文件句柄
documents = Word.Documents;
%若测试文件存在，打开该测试文件，否则，新建一个文件，并保存，文件名为测试.doc
if exist(filespec_user,'file')
    document = invoke(documents,'Open',filespec_user);
else
    document = invoke(documents, 'Add');
    document.saveas(filespec_user);
end

content = document.Content;
selection = Word.Selection;
paragraphformat = selection.ParagraphFormat;
%页面设置
document.PageSetup.TopMargin = 60;
document.PageSetup.BottomMargin = 45;
document.PageSetup.LeftMargin = 45;
document.PageSetup.RightMargin = 45;
%设定内容起始位置和标题
set(content, 'Start',0);
title='测  试  文  件';
set(content, 'Text',title);
set(paragraphformat, 'Alignment','wdAlignParagraphCenter');
%设定标题字体格式
rr=document.Range(0,10);
rr.Font.Size=16;
rr.Font.Bold=4;
%设定下面内容的起始位置
end_of_doc = get(content,'end');
set(selection,'Start',end_of_doc);
%另起一段
selection.TypeParagraph;
%如果当前工作文档中有图形存在，通过循环将图形全部删除
shape=document.Shapes;
shape_count=shape.Count;
if shape_count~=0
    for i=1:shape_count
        shape.Item(1).Delete;
    end
end

%随机产生标准正态分布随机数，画直方图，并设置图形属性
zft=figure('units','normalized','position',...
    [0.280469 0.553385 0.428906 0.251302],'visible','off');
set(gca,'position',[0.1 0.2 0.85 0.75]);
data=normrnd(0,1,1000,1);
hist(data);
grid on;
xlabel('考试成绩');
ylabel('人数');
%将图形复制到粘贴板
hgexport(zft, '-clipboard');
%将图形粘贴到当前文档里，并设置图形属性为浮于文字上方
selection.Range.PasteSpecial;
shape.Item(1).WrapFormat.Type=3;
shape.Item(1).ZOrder('msoBringInFrontOfText');
%删除图形句柄
delete(zft);