% ����ע��ctrl+R ����ȡ��ctl+T

% ���㵥��ͼƬ�� index feature%
function feature = query_get_index_feature(img, centers)
    if isempty(centers)
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        option = 'load centers from dataMat/centers_kmeans.mat'    
    end
    s = size(img);
    feature.s = s(1:2);
    [f, d] = get_sift(img);
    feature.f = f;
    feature.d = zeros(size(d,1), 1);
    K = size(centers, 1);
    
    % ����ڴ���ţ�ʹ���������
%     for i = 1 : size(d,1)
%         descriptor = double(d(i, :));
%         min_index = -1;
%         min_dis2 = inf;
%         for j = 1 : K
%             dis2 = sum((descriptor - centers(k, :)).^2);
%             if dis2 < min_dis2
%                 min_dis2 = dis2;
%                 min_index = j;
%             end
%         end
%         feature.d(i) = min_index;
%     end
    
    % ����ڴ�OK�� û�����ò��У�ʹ���������
    for i = 1 : size(d, 1)
        descriptor = double(d(i, :));
        [value, index] = min(sum(((repmat(descriptor, K, 1) - centers).^2), 2));    %sum(a,2)��ʾ��a����������ͣ�Ĭ�����������
        feature.d(i) = index;
    end
    feature = sort_by_index(feature);                       % ��index_feature �����ؼ����Ÿ���
    
    % ͳ��tf
    feature.tf = zeros(K, 1);
    for i = 1 : size(feature.d,1)
            feature.tf(feature.d(i)) = feature.tf(feature.d(i)) + 1;
    end
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

function index_feature = sort_by_index(index_feature)
    [index_feature.d, i] = sort(index_feature.d);
    index_feature.f(:, :) = index_feature.f(i, :);
end
