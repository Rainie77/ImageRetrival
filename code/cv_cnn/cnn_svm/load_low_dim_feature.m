function dataset = load_low_dim_feature( dataset, para )
%LOAD_LOW_DIM_FEATURE Summary of this function goes here
%   Detailed explanation goes here
    if isempty(dataset)
        dataset = load('../dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end
    
    if para.useSVD
        [dV_sigma, D] = svd_solve(dataset, para);
        for i = 1 : size(dataset, 1)
            dataset{i}.svm_feature = D(i, :)';
        end
        save('dV_sigma', 'dV_sigma');
        
    else
        for i = 1 : size(dataset, 1)
            dataset{i}.svm_feature = dataset{i}.feature;
        end
    end
    
    save('../dataMat/dataset.mat','dataset');
end

function [dV_sigma, D]=svd_solve(dataset, para)
    D = zeros(size(dataset, 1), size(dataset{1}.feature, 1));
    for i = 1 : size(dataset, 1)
        D(i, :) = dataset{i}.feature;
    end
    [~, sigma, V] = svd(D);
    
    % ��ȡ��֤90%������ά��
    ss = 0;
    sigma_sum = sum(sum(sigma));
    dim = size(sigma, 1);
    for i = 1 : size(sigma, 1)
        ss = ss + sigma(i, i);
        if ss / sigma_sum >= para.svd_engine_rate
            dim = i;
            break;
        end
    end
    
    dV_sigma = V(:, 1:dim) * sigma(1:dim, 1:dim);
    
    % ��D��ÿһ�У�ÿһ��ͼƬ�����������д���ͶӰ��V�ϵĻ��ϣ��ڳ��Ա�ʾ���ȵ�����ֵ��Ϊ��Ȩ����VΪ��λ��������
    % ��ά��ÿһ�л��Ƕ�Ӧһ��ͼƬ
    D = D * dV_sigma;
end
