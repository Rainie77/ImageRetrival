function rerank_mat = load_the_rerank_mat(dataset)
    image_count = size(dataset.d, 2);
    rerank_mat = zeros(image_count, image_count);
    Q = {};
    
    tic
    for i = 1 : image_count
        Q.d = dataset.d{i};
        Q.f = dataset.f{i};
        Q.s = dataset.s{i};
        Q.tf = dataset.tf{i}; 
        mat = load_the_scsm_mat(Q, dataset, i);
        rerank_mat(i,:)= mat;
        fprintf(1, '[bigbig] train rerank mat of %g / %g\n',i, image_count);
        save(strcat('dataMat/scsm/scsm_', int2str(i)), 'mat');
        fprintf(1, '[bigbig] save rerank mat of %g / %g\n',i, image_count);
    end
    save('dataMat/dataset_scsm.mat','rerank_mat');
    fprintf(1, 'save rerank_mat to dataMat/dataset_scsm.mat');
    toc
    
    for i = 1 : image_count
        [~, order_index] = sort(rerank_mat(i,:));
        rerank_mat(i, order_index) = image_count : -1 : 1;                       % rerank_mat(i,j) ��ʾ ���к�i�����scsm ��j��ͼƬ��i�����scsm�ŵڼ�λ�� ��������������Ƚ�û�����壬����rerank_mat(i,i)=image_count
    end
    save('dataMat/rerank.mat','rerank_mat');
    fprintf(1, 'save rerank_mat to dataMat/rerank.mat\n');
end
