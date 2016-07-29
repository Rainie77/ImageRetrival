% ����:
%   ���� load_sift_kmens���ص�dataset��������

% ����:
%   ��ÿ��ͼƬ�ľ�����index_feature  dataset.d{i}������������

function dataset=load_sorted_data(dataset)
    if isempty(dataset)
            dataset = load('dataMat/dataset_sift_signature.mat');
            dataset = dataset.dataset;
            fprintf(1,'load dataset from dataMat/dataset_sift_signature.mat\n');
    end
    
    image_count = size(dataset.d, 2);
    for i = 1 : image_count
        [dataset.d{i},index] = sort(dataset.d{i});
        dataset.f{i}(:,:) = dataset.f{i}(index,:);
        dataset.sig{i}(:, :) = dataset.sig{i}(index,:);
    end
    
    save('datamat/dataset_sorted.mat', 'dataset');
    fprintf(1, 'save dataset from datamat/dataset_sorted.mat\n');
end