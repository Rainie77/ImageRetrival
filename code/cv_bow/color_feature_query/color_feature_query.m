function index = color_feature_query(imagepath, dataset, centers,args, para)
    if isempty(dataset)
        dataset = load('dataMat/dataset_tf_idf.mat');
        dataset = dataset.dataset;
        fprintf(1, 'load dataset from dataMat/dataset_tf_idf.mat');
    end
    if isempty(centers)                                         % ���Ҫ��mat�ļ��ж�ȡ������[],[]  
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        fprintf(1, 'load centers from dataMat/centers_kmeans.mat');
    end

    img = imread(imagepath);
    
    scale = (500 * 800) / (size(img, 1) * size(img, 2));                   % % ���ݴ��ÿ200-400�����ػ���һ��sift���ƽ��1300����
    if scale < 1
        img = imresize(img, sqrt(scale));
    end
        
    feature = query_get_index_feature(img, centers,dataset);
    feature.color_feature = get_color_feature( imagepath, feature.f, para );
    save(strcat('dataMat/', 'feature'),'feature');
    
    K = args.K;
    similar = query_in_dataset(feature, dataset, K, para);
%     save('similar','similar');
    %similar'
    [~, index]=sort(similar);                         %index(i)��¼����������i������indexλ��
    %similar(:) = similar(length(similar):-1:1);
    index(:) = index(length(index):-1:1);
    
    classCount = args.classCount;
    numPerClass = args.numPerClass;
%     rsimilar = zeros(classCount, 1);
%     
%     for i = 1:classCount
%         for j = 1: numPerClass
%            rsimilar(i) = rsimilar(i) + similar(numPerClass*(i-1)+j);% / index(numPerClass*(i-1)+j); 
%         end
%     end
    
    KNN_K = args.KNN_K;
    vote = zeros(classCount, 1);
    %similar(index)'
    %(floor((index(1:100)-1)'./20) + 1)
    for i = 1: KNN_K
        class = uint16(str2double(dataset.class{index(i)}));
        vote(class) = vote(class) + 1;%similar(index(i));
    end
    
    [vote, maxI] = max(vote);
    if vote > 1
        index = maxI;
    else
        index = uint16(str2double(dataset.class{index(1)}));
    end
end

function similar=query_in_dataset(feature, dataset, K, para)
    similar = zeros(size(dataset.d, 2), 1);
    for i = 1:size(dataset.d, 2)
        similar(i) = cal_similar(feature, dataset.d{i}, dataset.sig{i}, dataset.idf, dataset.tf{i}, dataset.color_feature{i}, K, para);
    end
%     save('dataMat/similar.mat','similar');
end

function similar = cal_similar(Q, Dd, Dsig, Didf, Dtf, Dcf, K, para)
    similar = sum(Q.color_feature .* Dcf) / (distance(Q.color_feature) * distance(Dcf));
end 
    
function l = distance(vec)
    l = (sum(vec.*vec)).^(0.5);
end
% ����ע��ctrl+R ����ȡ��ctl+T

% ���㵥��ͼƬ�� index feature%
function feature = query_get_index_feature(img, centers, dataset)
    if isempty(centers)
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        fprintf(1,'load centers from dataMat/centers_kmeans.mat');
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
        [~, index] = min(sum(((repmat(descriptor, K, 1) - centers).^2), 2));    %sum(a,2)��ʾ��a����������ͣ�Ĭ�����������
        feature.d(i) = index;
    end
    feature=get_sift_signature(feature, dataset.P, dataset.T, d);
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
    index_feature.sig(:) = index_feature.sig(i);
end

function index_feature=get_sift_signature(index_feature, P, T, sift)
    Z_array = P * double(sift)';                  % ÿ����һ������
    index_feature.sig = mex_get_signature(Z_array, uint32(index_feature.d), T');
end
