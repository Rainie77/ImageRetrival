function open_parallel()
    try
            pool = parpool;
            pool.IdleTimeout = 1;
        catch                                            % ����ʧ�ܴ��ʱ�����Ѿ�������
            fprintf(1, '[state]: parallel open failed, maybe you have open parallel\n');
    end
end

