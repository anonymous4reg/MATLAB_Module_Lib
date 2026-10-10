function cases = find_scan_cases(data_root)
%FIND_SCAN_CASES 扫描数据根目录，发现工况文件夹并配对 Lfile/Hfile 录波文件。
%
% 每个工况 = data_root 下的一个子文件夹，内含低频 Lfile*.mat 与高频 Hfile*.mat
% （文件名前缀固定 Lfile/Hfile，后缀不限，如 Lfile_1.mat、Lfile_7.mat）。
%
% 返回 struct 数组：
%   cases(i).folder  工况文件夹完整路径
%   cases(i).lfile   低频录波 .mat 完整路径
%   cases(i).hfile   高频录波 .mat 完整路径
%
% 配对规则：同一文件夹内多个 Lfile/Hfile 时按后缀配对（Lfile_7 <-> Hfile_7）；
% 后缀无法配对时按字母序顺序配对并警告。

cases = struct('folder',{}, 'lfile',{}, 'hfile',{});

d = dir(data_root);
for i = 1:numel(d)
    if ~d(i).isdir || strcmp(d(i).name,'.') || strcmp(d(i).name,'..'), continue; end
    folder = fullfile(data_root, d(i).name);
    lf = find_by_prefix(folder, 'lfile');
    hf = find_by_prefix(folder, 'hfile');
    if isempty(lf) || isempty(hf), continue; end   % 非工况文件夹（无 Lfile 或 Hfile）
    [lfile, hfile] = pair_files(lf, hf);
    for k = 1:numel(lfile)
        cases(end+1) = struct('folder',folder, 'lfile',lfile{k}, 'hfile',hfile{k}); %#ok<AGROW>
    end
end

fprintf('find_scan_cases: 在 %s 发现 %d 组工况数据\n', data_root, numel(cases));
end

function files = find_by_prefix(folder, prefix)
allf = dir(fullfile(folder, '*.mat'));
files = {};
for i = 1:numel(allf)
    if allf(i).isdir, continue; end
    nm = lower(allf(i).name);
    if startsWith(nm, prefix) && endsWith(nm, '.mat')
        files{end+1} = fullfile(folder, allf(i).name); %#ok<AGROW>
    end
end
files = sort(files);
end

function [lf, hf] = pair_files(lfiles, hfiles)
lf = {}; hf = {};
if numel(lfiles) == 1 && numel(hfiles) == 1
    lf = lfiles; hf = hfiles;
    return;
end
% 后缀配对：Lfile_7 <-> Hfile_7
lmap = containers.Map(); hmap = containers.Map();
for i = 1:numel(lfiles), lmap(scan_suffix(lfiles{i})) = lfiles{i}; end
for i = 1:numel(hfiles), hmap(scan_suffix(hfiles{i})) = hfiles{i}; end
for k = 1:numel(lmap.keys)
    key = lmap.keys{k};
    if hmap.isKey(key)
        lf{end+1} = lmap(key); hf{end+1} = hmap(key); %#ok<AGROW>
    end
end
if isempty(lf)
    warning('find_scan_cases: 后缀无法配对，按字母序顺序配对 %d 个 Lfile 与 %d 个 Hfile', numel(lfiles), numel(hfiles));
    n = min(numel(lfiles), numel(hfiles));
    lf = lfiles(1:n); hf = hfiles(1:n);
end
end

function s = scan_suffix(f)
[~, base] = fileparts(f);
s = lower(base(6:end));   % 去掉 'lfile'/'hfile' 前缀后剩余部分
end
