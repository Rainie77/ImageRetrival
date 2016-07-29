function [dataset_cpp, dataset_matlab]=test1()
    % ��������
    dataset = load('datamat/dataset_sift.mat');
    dataset = dataset.dataset;
    sift_descriptors = dataset.d;
    fprintf(1, 'load dataset from datamat/dataset_sift.mat\n');

    dataset = load('D:\IDE\matlab\myFunction\cv_simple_cut\dataMat\dataset_sift_signature.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from datamat/dataset_kmeans.mat\n');

    % ʹ�����ַ����ֱ�����
    tic
    dataset_cpp = cppbit(dataset, sift_descriptors);
    toc
    tic
    dataset_matlab = matlabbit(dataset, sift_descriptors);
    toc
    
    % �Ա����ַ����Ľ��
    image_count = size(dataset.d, 2);
    for i=1:image_count
        res = sum(dataset_cpp.sig{i} ~= dataset_matlab.sig{i});
        if res ~= 0
            i
        end
    end
end

function dataset=matlabbit(dataset, sift_descriptors)
    image_count = size(dataset.d, 2);
    dataset.sig = cell(1, image_count);
    for i=1:image_count
        labels = dataset.d{i};
        descriptors = double(sift_descriptors{i});
        descriptors = (dataset.P * descriptors')';                  % ת�ú�ÿ����һ������ 
        dataset.sig{i} = uint64(zeros(length(labels), 1));
        for j = 1:length(labels)
            for k = size(descriptors, 2):-1:1
                bit = 0;
                if descriptors(j,k) > dataset.T(labels(j), k)
                    bit = 1;
                end
                
                dataset.sig{i}(j) = bitshift(dataset.sig{i}(j), 1) + bit;
            end
        end
        fprintf(1, 'state image %g get signature over.\n', i);
    end
end

function dataset=cppbit(dataset, sift_descriptors)
    image_count = size(dataset.d, 2);
    dataset.sig = cell(1, image_count);
    for i=1:image_count
        Z_array = dataset.P * double(sift_descriptors{i})';                  % ÿ����һ������
        dataset.sig{i} = mex_get_signature(Z_array, uint32(dataset.d{i}), dataset.T');
    end
end
