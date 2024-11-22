% function [b_final]=gibbs_l(config,y,G)
%     L=config.Gibbs_L;y=y.';
%     path=zeros(2 * L, config.k); % 每行是一条路径 前L行用于存储路径，后L行用于存储拓展后的路径
%     d=zeros(1, 2*L);
%     for i =1:config.k %依次处理k个比特
%         num_path=min(2^(i-1), config.Gibbs_L);%拓展前，包含i个比特时路径数量为2^(i-1)个 但有个L的最大限幅
%         % 将已有的路径拓展
%         for p=1: num_path 
%             path(L+p,:)=path(p,:);
%             path(L+p,i)=1-path(p,i);%翻转第i位比特，拓展路径
%             % 对路径计算度量值并排序
%             for j=1: 2* num_path
%                 b_hat=path(j,:);
%                 x_hat=pskmod(mod(b_hat*G,2), 2, InputType='bit');
%                 d(j)=norm(y-x_hat)^2;
%             end
%             [~,s]=sort(d);
%             path(p,:)=path(s(p),:);
%         end  
%     end
%     b_final=path(1,:);


function [b_final]=gibbs_l(config,y,G)
    L=config.Gibbs_L;y=y.';
    path=zeros(2 * L, config.k); % 每行是一条路径 前L行用于存储路径，后L行用于存储拓展后的路径
    d=zeros(1, 2*L);
    for i =1:config.k %依次处理k个比特
        num_path=min(2^(i-1), config.Gibbs_L);%拓展前，包含i个比特时路径数量为2^(i-1)个 但有个L的最大限幅
        % 将已有的路径拓展
        for p=1: num_path 
            path(L+p,:)=path(p,:);
            path(L+p,i)=1-path(p,i);%翻转第i位比特，拓展路径
        end  
        % 对路径计算度量值并排序 
        % 这里的循环数肯定不是num_path 后面再改
        for j=1: 2* num_path
            b_hat=path(j,:);
            x_hat=pskmod(mod(b_hat*G,2), 2, InputType='bit');
            d(j)=norm(y-x_hat)^2;
        end
        [~,s]=sort(d);
        for k=1:L
            path(k,:)=path(s(k),:);
        end
        
    end
    b_final=path(1,:);

