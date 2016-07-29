% ����:
%   dir ����ͼƬ���ļ���·��

% ����:
%   ��ȡһ���ļ����£����������ļ���������ͼƬ��sift�����뷵�ص�dataset��

% ����ֵ:
% dataset.f{i} = matrix(n, 4)  ÿһ�ж�Ӧһ�������㣬ÿһ�е�ǰ������Ӧ����������
% dataset.s{i} = matrix(1, 2)  ��¼��i��ͼƬ��size (weight,height)
% dataset.d{i} = matix(n,128)  ÿһ�ж�Ӧһ���������descriptor

% warnning:
%   ����cell����Ĭ���Ƕ�ά�ģ�cell{i} = cell{1,i}
function dataset=load_sift_cell(basedir)
    dirs = ls(basedir);
    i = 1;
    delete(gcp('nocreate'));parpool(2);
    for dir_i = 3 : size(dirs, 1)
        dir = strcat(basedir, dirs(dir_i, :), '/');
        sub_dataset = load_sift_cell_of_dir(dir, dir_i-2);
        for j = 1: size(sub_dataset.s, 2)
            dataset.s{i} = sub_dataset.s{j};
            dataset.f{i} = sub_dataset.f{j};
            dataset.d{i} = sub_dataset.d{j};
            i = i + 1;
        end
    end
    
        % ������Ӧ������־û��洢
    save('datamat/dataset_sift.mat', 'dataset');
    option = '[BIG]: get sift over. dataset save to datamat/dataset_sift.mat.'
end

function dataset=load_sift_cell_of_dir(dir, dir_i)
    files = ls(dir);
    files_count = size(files, 1);
    ds = cell(1, files_count -2);
    df = cell(1, files_count -2);
    dd = cell(1, files_count -2);
    
    parfor i = 3: files_count       % ǰ������ .�� ..
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        
        scale = (500 * 800) / (size(img, 1) * size(img, 2));                   % ���ݴ��ÿ200-400�����ػ���һ��sift���
        if scale < 1
            img = imresize(img, sqrt(scale));
        end

        s =  size(img);
        ds{i-2} = s(1:2);
        [f, d] = get_sift(img);
        df{i-2} = f;                            % ����ֵÿһ�ж�Ӧһ���ؼ��㣬������matlab����ϰ���෴�����ｫ������Ϊÿ�ж�Ӧһ���ؼ���
        dd{i-2} = d;
        fprintf(1, '[load_sift]:  %d / %d / %d\n', i-2, files_count-2 , dir_i);
    end
    dataset.s = ds;
    dataset.f = df;
    dataset.d = dd;
end

% ����ֵÿһ�ж�Ӧһ���ؼ��㣬������matlab����ϰ���෴
function [f,d] = get_sift(img)
% f is info of each keypoints, center f(1:2, i), scale f(3, i) and orientation f(4, i) %
% d is descriptors for every keypoint %
    img = single(rgb2gray(img));
    [f, d] = vl_sift(img);
    
    % ��ʽ����matlabͼƬ������(row,col),��f(1:2, i) = (col,row)
    t = f(1,:);
    f(1,:) = f(2,:);
    f(2,:) = t;
    % matlab ����һ��ÿ����һ�����ݣ����������ݸ���������ȡһ��ת��
    f = f';
    d = d';
end