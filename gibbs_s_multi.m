% 没有并行采样，仅仅考虑multichannel的Gibbs_s
function [b_final,sigma_list]=gibbs_s_multi(config,llr,y,G,sigma2)
    p_list=[];
    sigma2_list=[];
    hard_bits=hard_decision(llr); 
    b_hat=hard_bits(1:config.k,:); %先利用硬判决初始化估计值
    y=y.'; b_hat=b_hat.';%(batch, k)
    newOrder=gibbsNewOrder_parallel(config,y,G,b_hat);%(batch, k)

    opt_norm=10000*ones(config.batch,1);%存放目前为止最小的残差
    opt_b_hat=zeros(config.batch,config.k);%存放使得残差最小的译码比特结果    
    for i = 1:config.Gibbs_iter %Gibbs译码循环
        for j = newOrder %j(batch, 1)
           %更新噪声功率
           x_hat=pskmod(mod(b_hat*G,2), 2, InputType='bit');
           norm=vecnorm(y-x_hat,2,2).^2;
           sigma2=norm./(2*config.n);% 即便是信噪比为6 sigma2也只更新了一次
           %sigma2_list=[sigma2_list,sigma2];

           %每个batch都选取残差最小的译码结果而非迭代至最后的译码结果 begin
           opt_id=norm<opt_norm;
           opt_norm(opt_id)=norm(opt_id);
           opt_b_hat(opt_id,:)=b_hat(opt_id,:);
           %每个batch都选取残差最小的译码结果而非迭代至最后的译码结果 end

           %计算L
           rows = (1:size(b_hat, 1))';% 获取每一行的行号
           b_hat0=b_hat;b_hat0(sub2ind(size(b_hat0),rows,j))=0;%行号加每行索引转为线性索引，避免循环替换
           b_hat1=b_hat;b_hat1(sub2ind(size(b_hat1),rows,j))=1;             
           x_hat0=pskmod(mod(b_hat0*G,2), 2, InputType='bit');
           x_hat1=pskmod(mod(b_hat1*G,2), 2, InputType='bit');
           L=(vecnorm(y-x_hat0,2,2).^2-vecnorm(y-x_hat1,2,2).^2)./(2*sigma2);
           %概率
           P=ones(config.batch,1)./(1+exp(-L));%p(x=1)
           %p_list=[p_list,P];
           %依概率更新
           u=rand(config.batch,1);
           judge=u<P;%(batch, 1)
           indice_one=find(judge==1);indice_zero=find(judge==0);
           j_one=j(indice_one);j_zero=j(indice_zero);
           b_hat(sub2ind(size(b_hat),indice_one,j_one))=1;
           b_hat(sub2ind(size(b_hat),indice_zero,j_zero))=0;           
        end
    end
    %b_final=b_hat;
    b_final=opt_b_hat;

% 按照出错概率的大小对k位比特进行排序，容易出错的最先更新
% return newOrder 新的更新顺序，将1到k的序号按新顺序排列
% b_hat(batch, k) y(batch, n)
function newOrder = gibbsNewOrder_parallel(config,y,G,b_hat)
    norms=zeros(config.batch,config.k);%存储所有batch的k bit的norm
    for i = 1:config.k%依次翻转k位比特并计算翻转后的范数
        b_hat_flip=b_hat;
        b_hat_flip(:,i)=1-b_hat(:,i);%分别翻转1到k位的比特
        x_hat_flip=pskmod(mod(b_hat_flip*G,2), 2, InputType='bit');%(batch, n)
        norm_temp=vecnorm(y-x_hat_flip,2,2).^2;
        norms(:,i)=norm_temp;
    end
    [~,newOrder]=sort(norms,2);%对每一行升序排列
    