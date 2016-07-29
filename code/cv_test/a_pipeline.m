function a_pipeline()
    % ��������Ŀ�ͻ���
    %a_start();

    basedir = 'C:/Users/yinglang/Desktop/cv/';
    dataset_path = strcat(basedir, 'dataset/');
    queryset_path = strcat(basedir, 'queryset/');
    %query_file = 'all_souls_000013.jpg';
    
%     %dataset = [];centers=[];
%     fprintf(1, '[parse]: get sift from dataset');
%     dataset = load_sift_cell(dataset_path);             % ��ȡsift
%     %input('press Enter to continue.');
%     fprintf(1, '[parse]: kmeans cluster for BOW of sift');
%     [dataset, centers] = load_sift_kmeans(dataset);     % kmean���࣬����sift ��ʾΪindex����
%     %input('press Enter to continue.');
%     fprintf(1, '[parse]: post sovle for dataset sift, sort and calculate tf idf terms.');
%     dataset=load_sorted_data(dataset);
%     %input('press Enter to continue.');
%     dataset = load_tf_idf(dataset, centers);             % ����tf��idf��
    %input('press Enter to continue.');
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    option = 'load dataset from dataMat/dataset_tf_idf.mat'
    rerank_mat=load_the_rerank_mat(dataset);             % ����rerank_mat
    %input('press Enter to continue.');
    
    fprintf(1, '[parse]: query image in dataset.');
    %query_test(strcat(queryset_path, query_file), centers, dataset, rerank_mat);
    %sovle_queryset(queryset_path, dataset, centers);    % �Դ���ѯ��ͼƬ���в�ѯ����
end

% ����ע��ctrl+R ����ȡ��ctl+T

function Q = query_test(filepath, centers, dataset,rerank_mat)
    img = imread(filepath);
    Q = query_get_index_feature(img, centers);
    image_index = query_in_dataset(Q, dataset,rerank_mat);
end

function sovle_queryset(dir, dataset, centers)
    files = ls(dir);
    for i = 3: size(files,1)
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        Q = get_index_feature(img, centers);
        query(Q, dataset);
    end
end  
    