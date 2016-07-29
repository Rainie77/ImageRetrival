function Q=query_get_index_feature_by_R_S(Q, rotations, scales)
    len_r = length(rotations);
    len_s = length(scales);
    R = zeros(len_r, 2,2);
    for i = 1 : len_r
        R(i,:,:) = get_rotate_matrix(rotations(i));
    end
    
    Q.rs_p = {};
    for j = 1 : len_s
        Q.rs_p{1, j} = Q.f(:, 1:2).*scales(j);                  % �����任�������е�location�ȱȷ���
        for i = 1 : len_r
            Q.rs_p{i,j} = R(i) * Q.rs_p{1,j};                      % ��ת�任�������е�rotation��תһ���Ƕ�
        end
    end
end

% ���ݻ����ƵĽǶ�thetaȷ��һ����ת����R * p �õ�����p��ʱ����תtheta�Ƕȵ�������
function R=get_rotate_matrix(theta)
    R = [cos(theta), -sin(theta);
         sin(theta), cos(theta)];
end