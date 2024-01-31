function color = f_getColor(value, min, max, arg_color_map)
 cmap = get(groot,'defaultfigurecolormap');
 if nargin < 4
     cmap = colormap("parula");
 else
     cmap = colormap(arg_color_map);
 end
 [m, ~] = size(cmap);
 row = round((value/(max-min+1))*(m-1)) + 1;
 color = cmap(row, :);  
end