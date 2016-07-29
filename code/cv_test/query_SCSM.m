function [scsm, T] = query_SCSM(Q_RS, D, para)
    if ~is_Q_RS(Q_RS)
        Q_RS = query_get_index_feature_by_R_S(Q_RS,para.rotations, para.scales);
    end
    
    score = cal_score_k(Q_RS, D);
    T = find_best_tranform(Q_RS, D, para,score);
    % T=[8.0000    8.0000   25.6250  208.6200];
    % option = '      find best T over.'
    scsm=cal_SCSM(Q_RS, D, T, para.max_location_error, score);
    %show_map_img(map);

%     location_map = zeros(partition_count_r, partition_count_s, nx, ny);
%     for i = 1 : partition_count_r
%         for j = 1 : partition_count_s
%             location_map(i, j) = cal_location_map(Q, D, rotations(i), scales(j),nx, ny);
%         end
%     end

end

% �жϴ����Ĳ�����Q_RS���������rotation��scales����ģ���һ��rs_f�������Q(ֻ����s,f,idf,tf)
function result=is_Q_RS(Q_RS)
    result = length(fieldnames(Q_RS)) == 5;
end

% ��һ����T�¼���SCSM
function scsm=cal_SCSM(Q_RS, D, T, maxerror, score)
    Q_T = Q_RS.rs_p{T(1), T(2)};
    Q_T(:,1) = Q_T(:, 1) + T(3);
    Q_T(:,2) = Q_T(:, 2) + T(4);
    Q_center = Q_RS.s / 2;
    D_center = T(3:4);
    scsm = 0;
    
    %debug_i = 1;
    Qi_le = 0; Di_le= 0;
    K = size(D.idf,1);                                                      % kmeans��������
    for k = 1 : K
        [Qi_e, Di_e] = find_end_index_of_k(Q_RS, D, k, Qi_le, Di_le);
        % Q_location = Q.f(Qi_le+1:Qi_e, 1:2);                             % �ҵ����е���k(kmeans�ֵ���k��)�Ĺؼ��㣬�����ǽ��������ȶ�
        % D_location = D.f(Di_le+1:Di_e, 1:2);
        
        % �����Ƕ�Q_location �� D_location��������ƥ�䣬��ȫ����д�ɶ����ĺ���
        for i = Qi_le+1:Qi_e
            for j = Di_le+1:Di_e
                error = cal_location_error(Q_T(i,:), Q_center, D.f(j,1:2), D_center);
                if error < maxerror
                    scsm = scsm + score(k);
                end
                
                %debug(debug_i) = error;
                %debug_i = debug_i + 1;
            end
        end 
        Qi_le = Qi_e; Di_le= Di_e;
    end
    
    %debug = sort(debug);
    %[debug(1:10);debug(end-9:end)]
    %sqrt_index = debug(int16(sqrt(end)))               % �򵥲��ԣ���ŷֲ���35-60����һ��Ϊ128+��ƽ�������45
end

function error = cal_location_error(Lf, Q_center, Lg, D_center)
    error = (Lf - Q_center- (Lg - D_center));
    error = sqrt(sum(error.*error));
end

% ѡ�����õ�transform=(r, s, t)                         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxindex = find_best_tranform(Q_RS, D, para, score)
    len_r = length(para.rotations);
    len_s = length(para.scales);
    %debug_c = zeros(len_r*len_s,2);
    map = zeros(para.nx, para.ny);
    maxscore =  0;maxindex=[1,1,1,1];
    for i = 1: len_r
        for j = 1:len_s
            % [map(:,:),debug_c((i-1)*len_s+j,:)] = cal_location_score_map(Q_RS, i, j, D, para.grid_size, para.nx, para.ny, score);
            map(:,:) = cal_location_score_map(Q_RS, i, j, D, para.grid_size, para.nx, para.ny, score);
            map(:,:) = gaussian_filter_map(map);
            
            % find the maxsocre tranform (r, s, t)
            [temp,rows] = max(map);
            [temp,col] = max(temp);
            if maxscore < temp
                maxindex = [i,j, rows(col), col];
            end
            
            %rotation_scale = [para.rotations(i), para.scales(j)]
            % debug_c((i-1)*len_s+j,:)
        end
    end
    maxindex(3:4) = (maxindex(3:4) - 0.5) .* para.grid_size;
    %sum(debug_c)
end

function show_map_img(map)
    map(1:10, 1:10)
    map1 = map;
    map = map(map>0);   % �ҳ����з���� map>0���ص��������൱�ڰ�map��������չ���ɵ�һά������±�,��λ��map�����һ��һά��index,���ᰴ����ͬ�Ĺ������
    max_v = max(map);
    min_v = min(map);
    size(map)
    min_v
    max_v
    map1 = map1./max_v;
    figure
    imshow(map1);
end

% ���㾭����תR������S�任��location_map                         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function map=gaussian_filter_map(map)
    %# Create the gaussian filter with hsize = [5 5] and sigma = 2
    G = fspecial('gaussian',[5 5],2);
    %# Filter it
    map = imfilter(map,G,'same');
end

% ��ָ����rotation��scale�£���ѯͼƬ�����map
function [map,debug_c]=cal_location_score_map(Q_RS, rotate_i, scale_j, D, grid_size, nx, ny, score)
    c1 = 0; c2 = 0;
    map = zeros(nx, ny);
    K = size(D.idf,1);                                                      % kmeans��������
    Qi_le = 0; Di_le= 0;
    for k = 1 : K
        [Qi_e, Di_e] = find_end_index_of_k(Q_RS, D,k, Qi_le, Di_le);
        % Q_location = Q.f(Qi_le+1:Qi_e, 1:2);                             % �ҵ����е���k(kmeans�ֵ���k��)�Ĺؼ��㣬�����ǽ��������ȶ�
        % D_location = D.f(Di_le+1:Di_e, 1:2);
        
        % �����Ƕ�Q_location �� D_location��������ƥ�䣬��ȫ����д�ɶ����ĺ���
        for i = Qi_le+1:Qi_e
            for j = Di_le+1:Di_e
                fi = Q_RS.rs_p{rotate_i, scale_j}(i, :);
                location = cal_location(fi, D.f(j, 1:2), Q_RS.s);          % (fi ,gj), ��D��Ѱ��Q; Ҳ���Ը���ʵ�������Q�в���D
                grid_index = cal_grid_of_location(location, grid_size);
                if grid_index(1) > 0 && grid_index(2) > 0  && grid_index(1) <101 && grid_index(2) <101                 % (fi,gi)ƥ��ʹ��D�������㹻�Ŀռ�ƥ����У�������������������޸ģ�
                    map(grid_index(1),grid_index(2)) = map(grid_index(1), grid_index(2)) + score(Q_RS.d(i));
                    c1 = c1 + 1;
                end
                c2 = c2 + 1;
            end
        end
        
        Qi_le = Qi_e;
        Di_le = Di_e;
    end   
   
    debug_c = [c1, c2]; %c ���������鿴�����Ƿ���������
end

% �ҵ����һ������k�ĵ���±꣬�����ҵ����е���k�Ĺؼ���
function [Qi_e, Di_e]=find_end_index_of_k(Q, D,k, Qi_le, Di_le)                          % Qi_e end(beggest) index i of Q(i)=k, Qi_le end(beggest) index i of Q(i) < k 
    Qs = size(Q.d, 1);
    Ds = size(D.d, 1);
    for i = Qi_le+1: Qs                                                   % find first i of Q(i) > k
        if Q.d(i) > k
            break;
        end
    end
    Qi_e = i - 1;
    
    for i = Di_le+1: Ds
        if D.d(i) > k
            break;
        end
    end
    Di_e = i -1;
end

% �������������������������(fi,gj)ʱ��grid_index��socre��        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function grid_index=cal_grid_of_location(location, grid_size)
    grid_index = int32(location./grid_size) + 1;
end

% location ȡֵ(0,0)-->(size(D)-1)
function center_location = cal_location(Lf, Lg, s)                                   
%   Lf �� queryͼ��ƥ��ؼ�������꣬�Ѿ�������rotation��scale�任
%   Lg �� dataset �д�ƥ��ͼD�Ķ�Ӧ�ؼ��������
%   location ��Dͼ�ж�Ӧ��queryͼƬ��ԭ�������(����Ϊ�˷��㣬û��ʹ�����ĵ�����꣬ʹ�õ������Ͻǵ�-��1,1��)
%   Lf - center = Lg - location;
    center_location = Lg - Lf + s./2;
end

function score = cal_score_k(Q, D)
    idf = D.idf;
    score = (idf./ Q.tf).* (idf./D.tf);
end
