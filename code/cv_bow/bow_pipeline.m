% ��д���򣬱�Ҫ���ص㿪ʼд���Ե�����ͻ�ƣ�
% ͬʱ��취ȷ���Լ��뷨����ȷ�ԣ���˿�ʼ������ϵͳ�����ƣ��������ȿ���Ч��
% ֻ���ܹ�Ԥ֪��ȷ�Ͻ�����ź�ϵͳ������
%

% ��ȡsift
% ��sift���� kmeans����
% ����ƥ��� idf �� tf����ȡ���ƶ�

function res=bow_pipeline()
    addpath('./load_train');
    addpath('./tool');
    addpath('./bow_query');
    addpath('./bow_svm_query');
    addpath('./color_feature_query');

    basedir = '../../data/cvcut/';
    dataset_path = strcat(basedir, 'dataset/');
    queryset_path = strcat(basedir, 'queryset/');
    
        % load sift libary %
    if strcmp(which('vl_sift'),'')
        run('../../third_part_lib/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
    end
    
    if ~exist('datamat/dataset_sift.mat', 'file')
        load_sift_cell(dataset_path);
    end
    if ~exist('dataMat/dataset_kmeans.mat', 'file') || ~ exist('dataMat/centers_kmeans.mat', 'file')
        load_sift_kmeans([]);
    end
    if ~exist('dataMat/dataset_sift_signature.mat', 'file')
        load_sift_signature();
    end
    load_sorted_data([]);
    load_tf_idf([],[]);  
    load_uint_name(dataset_path, []);
    
%     i = 1;
%     for KNN_K = 5 : 5 : 60
%         
%         i = i + 1;
%     end

%     args.K = 100;
%     args.classCount = 52;
%     args.numPerClass = 20;
%     args.KNN_K = 5;
%     query(strcat(queryset_path ,'ƹ�������\IMG_2000.JPG'), [], [], args)
    
    mex('./tool/mex_cal_similar.cpp');
    para.dataset_path = dataset_path;
    para.recalculate_color_feature = 0;
    
    tic
    res =query_set(queryset_path, 5, para);                                        % �����KNN_K������
    toc
    
%     tic
%     KNN = 1:5:50;
%     rightRate=zeros(length(KNN), 1);
%     for i = 1:length(KNN)
%         tic
%         res =query_set(queryset_path, KNN(i), para);                                        % �����KNN_K������
%         toc
%         rightRate(i) = res.rightRate;
%         res.rightRate
%     end
%     res.rightRate = rightRate;
%     res.KNN = KNN;
%     toc
%     save('dataMat/res', 'res');
end

function res=query_set(querySet, KNN_K, para)
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from dataMat/dataset_tf_idf.mat\n');
    centers = load('dataMat/centers_kmeans.mat');
    centers = centers.centers;
    fprintf(1, 'load centers from dataMat/centers_kmeans.mat\n');
    
    args.K = size(centers, 1);
    args.classCount = 52;
    args.numPerClass = 20;
    args.KNN_K = KNN_K;
    
    para.useSVM = 0;                                                            % �Ƿ�ʹ��svm  rightRate=0.7308
    
    para.useColorFeature=0;                                                     % �Ƿ�ֻʹ��color feature
    para.color_bin_size = 8;
    para.block_size = 5;
    
    para.use_sift_signature = 0;                                                % �����ʹ��svm���Ƿ�ʹ��64bit sift signatrue,�����ʹ�ã�
                                                                                % ��ֱ��ʹ�����ҼнǼ������ƶȣ�rightRate=0.5433
    para.hamming_threshold = 30;                                                % ���ʹ��sift signature, �趨hamming������ֵ
    
    
    %delete(gcp('nocreate'));parpool(2);
    if para.useSVM
        svmModel = svm_train();                                                 % SVM
    end
    
    if para.useColorFeature && para.recalculate_color_feature
        tic;dataset=load_color_feature(para.dataset_path, dataset, para);toc;
    end
    
    dirs = ls(querySet);
    k = 1;
    for i = 3 : size(dirs, 1)
        dir = strcat(querySet,dirs(i, :), '/');
        files = ls(dir);
        for j = 3 : size(files, 1)
            right(j-2) = uint16(str2double(dirs(i,:)));
            file = strcat(dir, files(j, :));
         
            if para.useSVM
                    test(j-2) = svm_query(file, dataset, centers, svmModel);        % SVM
            else if para.useColorFeature
                    test(j-2) = color_feature_query(file, dataset, centers, args, para);
                else
                    test(j-2) = query(file, dataset, centers, args, para);
                end
            end
            fprintf(1, 'right: %g, recognzie: %g\n', right(j-2), test(j-2));
        end  
        res.right(k:k+size(files, 1)-2-1) = right(:);
        res.test(k:k+size(files, 1)-2-1) = uint16(test(:));
        k = k + size(files, 1)-2;
    end
    
    res.rightRate = sum(res.right == res.test) / length(res.right);
end
