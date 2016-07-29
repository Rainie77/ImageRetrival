function dataset = load_uint_name( basedir, dataset )
    if isempty(dataset)                                         % ���Ҫ��mat�ļ��ж�ȡ������[],[]
        dataset = load('dataMat/dataset_tf_idf.mat');
        dataset = dataset.dataset;
    end

    dirs = ls(basedir);
    i = 1;

    for dir_i = 3 : size(dirs, 1)
        classname = dirs(dir_i, :);
        dir = strcat(basedir, dirs(dir_i, :), '/');
        files = ls(dir);
        for j = 1: (size(files, 1)-2)
            dataset.class{i} = classname;
            i = i + 1;
        end
    end
    
    save('dataMat/dataset_tf_idf', 'dataset');
    fprintf(1, 'save dataset to dataset_tf_idf\n');
end

