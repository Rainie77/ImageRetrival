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

function dataset=load_sift_cell(dir)
    files = ls(dir);
    for i = 3: size(files,1)       % ǰ������ .�� ..
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        s =  size(img);
        dataset.s{i-2} = s(1:2);
        [f, d] = get_sift(img);
        dataset.f{i-2} = f;                            % ����ֵÿһ�ж�Ӧһ���ؼ��㣬������matlab����ϰ���෴�����ｫ������Ϊÿ�ж�Ӧһ���ؼ���
        dataset.d{i-2} = d;
        option = strcat('  get_sift of ',int2str(i-2) ,' / ', int2str(size(files,1)-2))
    end
    % ������Ӧ������־û��洢
    save('datamat/dataset_sift.mat', 'dataset');
    option = '[BIG]: get sift over. dataset save to datamat/dataset_sift.mat.'
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