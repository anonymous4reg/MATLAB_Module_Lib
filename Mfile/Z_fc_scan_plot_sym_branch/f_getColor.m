function color = f_getColor(value, min, max)
 cmap = get(groot,'defaultfigurecolormap');
 cmap = colormap('parula');
 [m, ~] = size(cmap);
 row = round((value/(max-min+1))*(m-1)) + 1;
 color = cmap(row, :);  
end