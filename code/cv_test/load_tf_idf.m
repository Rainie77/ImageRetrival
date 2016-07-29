% ����:
%   dataset ���� load_sift_kmeans/load_sorted_data ���ص�dataset�ĸ�ʽ
%   centers ���� load_sift_kmeans ���صľ������ĵĸ�ʽ

% ����:
%   ����ÿ����(kmeans�����ÿ����)��idf ��tf��
%   idf : ��ӳһ���������Ͽ��г��ִ�������Ҫ�Գɷ��ȡ�����ʹ�������Ͽ�(����ͼƬ)�г���Ƶ�ʺ͵ĵ�����
%       ��Ϊ��������ܻ��С�������漰���ļ��㣬Ӧ��ʹ��log
%   tf  : ��ӳһ�����ڴ���ѯͼƬ�г��ִ�������Ҫ�Գ����ȡ� ����ʹ�õ�����һ��ͼ�г��ֵ�Ƶ�ʡ�

% ���أ�
%   dataset.f{i} = matrix(n, 4)  ÿһ�ж�Ӧһ�������㣬ÿһ�е�ǰ������Ӧ���������ꡣ û��
%   dataset.s{i} = matrix(1, 2)  ��¼��i��ͼƬ��size (weight,height)��          û��
%   dataset.d{i} = matrix(n, 1). n �ǵ�i��ͼƬ���������������        û��
%   dataset.tf{i} = matrix(K,1)  K �Ǿ��������       
%   dataset,idf = matrix(K,1)

function dataset=load_tf_idf(dataset, centers)
    if isempty(dataset)                                         % ���Ҫ��mat�ļ��ж�ȡ������[],[]
        dataset = load('dataMat/dataset_sorted.mat');
        dataset = dataset.dataset;
        option = 'load dataset from dataMat/dataset_sorted.mat'
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        option = 'load centers from dataMat/centers_kmeans.mat'
    end
    
    K = size(centers, 1);
    image_count = size(dataset.d, 2);
    dataset.idf = zeros(K, 1);
    for i = 1 : image_count
        index_feature = dataset.d{i};
        tf = zeros(K, 1);
        for j = 1 : size(index_feature,1)
            tf(index_feature(j)) = tf(index_feature(j)) + 1;
        end
        dataset.idf = dataset.idf + (tf > 0);
        dataset.tf{i} = tf;
    end
    dataset.idf = idf_function(image_count, dataset.idf);
    
    save('dataMat/dataset_tf_idf.mat','dataset');
    option = 'save dataset with idf and tf item to dataMat/dataset_tf_idf.mat'
end

function idf=idf_function(image_count, idf)
    idf = image_count./idf;
end
