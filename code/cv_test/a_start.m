% �ýű�Ӧ�ڸմ�matlabʱ�� ����һ�Σ�֮��Ӧ������
function a_start()
    % load sift libary %
    if strcmp(which('vl_sift'),'')
        run('D:/IDE/matlab/third_part/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
    end
    
    try
        pool = parpool;
        pool.IdleTimeout = 1;
    catch                                            % ����ʧ�ܴ��ʱ�����Ѿ�������
        option = 'parallel open failed, maybe you have open parallel'
    end
%     else if isa(pool,'parallel.Pool')           % ������
%             try
%                 if ~pool.Connected                  % �Ͽ�������, pool.IdelTimeOut������೤ʱ�䲻�þ͹ر����ӣ�Ĭ��30����
%                     delete(pool);
%                     pool = parpool;
%                 end
%             catch                                   % �����Ѿ�delete����
%                 pool = parpool;
%             end
%         else
%         end
%     end
end