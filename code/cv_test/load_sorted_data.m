% ����:
%   ���� load_sift_kmens���ص�dataset��������

% ����:
%   ��ÿ��ͼƬ�ľ�����index_feature  dataset.d{i}������������

function dataset=load_sorted_data(dataset)
    if isempty(dataset)
        dataset = load('datamat/dataset_kmeans.mat');
        dataset = dataset.dataset;
        option = 'load dataset from datamat/dataset_kmeans.mat'
    end
    
    image_count = size(dataset.d, 2);
    for i = 1 : image_count
        [dataset.d{i},index] = sort(dataset.d{i});
        dataset.f{i}(:,:) = dataset.f{i}(index,:);
    end
    
    save('datamat/dataset_sorted.mat', 'dataset');
    option = 'load dataset from datamat/dataset_sorted.mat'
end