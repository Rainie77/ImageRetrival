function color_feature = get_color_feature( imagepath, f, para )
%RERANK Summary of this function goes here
%   Detailed explanation goes here
    image=imread(imagepath);
    scale = (500 * 800) / (size(image, 1) * size(image, 2));                   % % ���ݴ��ÿ200-400�����ػ���һ��sift���ƽ��1300����
    if scale < 1
        image = imresize(image, sqrt(scale));
    end
    
    M = size(image, 1);
    N = size(image, 2);
    
    sift_count = size(f, 1);
    c = zeros(sift_count * 3, 1);
    color = [0;0;0];
    d = floor(para.block_size / 2);                                 % para.block_size Ϊ����
    for i=1: sift_count
        if f(i, 1) - d >= 1 && f(i, 1) + d <= M && ...
                f(i,2) -d >= 1 && f(i,2)+d <= N
            block = image(floor(f(i,1)- d) : floor(f(i,1) + d), floor(f(i,2)-d):floor(f(i,2)+d), :);
            color(1) = sum(sum(block(:,:,1))./ (para.block_size)) / (para.block_size);
            color(2) = sum(sum(block(:,:,1))./ (para.block_size)) / (para.block_size);
            color(3) = sum(sum(block(:,:,1))./ (para.block_size)) / (para.block_size);
        end
        
        c([i, i+sift_count, i + 2 *sift_count]) = color;
    end
    c = c / para.color_bin_size + 1;                                               % ��0-255(ʵ�ʵ���ɫֵ����ֳ����ɵȾ�Ƭ�Σ�para.color_bin_size ��ʾÿ�ε����䳤��
    
    c = floor(c);
    bin_count = ceil(256 / para.color_bin_size);
    color_feature = zeros(bin_count * 3, 1);
    for i = 1 : sift_count
        index = [c(i), c(i + sift_count) + bin_count, c(i+sift_count*2) + bin_count * 2];
        color_feature(index) = color_feature(index) + 1;
    end
    color_feature = color_feature(1:bin_count);
end

