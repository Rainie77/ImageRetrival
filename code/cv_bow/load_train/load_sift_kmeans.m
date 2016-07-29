% ���棺
%   kmeans �������ǲ����������м���������˽�����֤����֪����û��Ӱ��

% ����:
%   dataset ��Ҫ����load_sift_cell�������ص�dataset�ĸ�ʽ

% ����:
%   ʹ��kmeans��dataset�е�����sift��descriptor���о��࣬��ȡ�������ģ�
%   ����ʹ�þ����index����descriptor�����������㣬ʵ���������һ����ά�Ĳ���

% ���أ�
%   dataset.f{i} = matrix(n, 4)  ÿһ�ж�Ӧһ�������㣬ÿһ�е�ǰ������Ӧ���������ꡣ û��
%   dataset.s{i} = matrix(1, 2)  ��¼��i��ͼƬ��size (weight,height)��  û��
%   dataset.d{i} = matrix(n, 1). n�ǵ�i��ͼƬ���������������
%   centers  sift��������

function [dataset,centers] = load_sift_kmeans(dataset)
    % ��Ӧ�Ĵ�����Ӧ������Ӵ��̶�ȡ
    if isempty(dataset)                                         % ���ʹ�ü��ص����ݣ�dataset����Ϊ[]
        dataset = load('datamat/dataset_sift.mat');
        dataset = dataset.dataset;
        option = 'load dataset from datamat/dataset_sift.mat'
		
% 		centers = load('dataMat/centers_kmeans.mat');
% 		centers = centers.centers;
% 		option = 'load centers from dataMat/centers_kmeans.mat'
    end
    K = 200;
    
    image_count = size(dataset.d, 2);                           % ͼƬ����������cell����Ĭ���Ƕ�ά�ģ�cell{i} = cell{1,i}
    
    % ��������ǽ�����descriptors���ϵ�һ�������ͬʱ�ͷ�ԭ�пռ�
    sift_length = size(dataset.d{1}, 2);                        % sift descriptor���ȣ�Ĭ����128
    all_sift_count = 0;                                         % sift descriptor��������
    for i = 1 : image_count
        all_sift_count = all_sift_count + size(dataset.d{i}, 1);
    end
    
    all_sift_descriptors = zeros(all_sift_count, sift_length);  % ����ռ�
    b = 1;
    for i = 1 : image_count
        len = size(dataset.d{i}, 1);
        all_sift_descriptors(b:b + len-1, :) = double(dataset.d{i});
        b = b + len;
        dataset.d{i} = [];                                      % �ͷſռ䣬d�ں��������洢 index feature
    end
    
    size(all_sift_descriptors)
    option = '  begin kmeans '
    
    % ������ÿ�ֳ�ʼ��֮�䲢�У�һ�γ�ʼ���ǲ��Ტ�еģ���ֻ��Replicates > 1ʱ��������
    % open_parallel();
    stream = RandStream('mlfg6331_64');                         % Random number stream,α�����Ҫ��һ�����ɣ�matlab��������
                                                                % ֻ�����֧��substreams(��Ӧ�����UseSubStreams),mt19937ar ���ɺ�����֧��������
    opts=statset('Display', 'iter','MaxIter', 100, 'UseParallel',1, 'UseSubStreams', 1, 'Streams', stream); % UseSubStreamsӦ����ÿ�����еĽ���ʹ�ò�ͬ������
    opts=statset('Display', 'iter','MaxIter', 100);
    [labels, centers] = kmeans(all_sift_descriptors, K, 'Options', opts, 'Replicates',1, 'start', 'plus'); 
	%[labels, centers] = kmeans(all_sift_descriptors, K, 'Options', opts, 'Replicates',1, 'start', centers); 
    % [idx, c, sumd, D] = kmenas(X, K, 'Replicates',5 ,'Options', opts)
    % X: ÿ����һ�����ݵ㣬�������ݼ� (n * p)��K ���������'Replicates',5ʹ��5���ʼ�㣨���ѡ�������С�ģ�
    % idx ÿ�����ݵ㱻�ֵ���һ����    (n * 1)
    % c �Ǿ������ģ�ÿһ����һ������  (k * p)
    % sumd ÿ�����ڵľ����          (k * 1)
    % D ÿ���㵽ÿ����ľ���         (n * k)
    % Display iterÿ�ε�����ʾ���ķֱ��� ���������� �׶�(�ο�matlab2016�ĵ����� ������֤����ĵ�ĸ����� sum�����
    % start plus ��ʾʹ��k-means++�ķ���ȷ����ʼ���ĵ�
    option = '[BIG]: kmeans over.'
    
    % hist(labels, K);
    % size(labels)
    b = 1;
    for i = 1:image_count
        len =  size(dataset.f{i}, 1);
        dataset.d{i} = labels(b: b + len-1);
        b = b + len;
    end
    
    save('dataMat/dataset_kmeans.mat','dataset');
    option = 'save dataset to dataMat/dataset_kmeans.mat.'
    save('dataMat/centers_kmeans.mat', 'centers');
    option = 'save centers to dataMat/centers_kmeans.mat.'
end