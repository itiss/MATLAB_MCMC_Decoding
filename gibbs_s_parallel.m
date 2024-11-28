function [b_final,sigma_list]=gibbs_s_parallel(config,llr,y,G,sigma2)
    % init
    p_list=[];sigma2_list=[];
    np=config.np; k=config.k; batch=config.batch;n=config.n;
    hard_init=config.hard_init;
    opt_norm=10000*ones(np, 1, batch);%存放目前为止最小的残差
    opt_b_hat=2*ones(np, k, batch);%存放使得残差最小的译码比特结果 初始化为异常值2   

    hard_bits=hard_decision(llr); 
    b_hat=hard_bits(1:config.k,:); %先利用硬判决初始化估计值
    y=y.'; %(batch, n)
    b_hat=b_hat.';%(batch, k)

    % extend the dimension for parallel sampling
    if hard_init
        b_hat_extend = repmat(b_hat, [1, np]);%(batch, np*k)
        b_hat_extend=b_hat_extend.';%(k*np, batch)
        b_hat_extend=reshape(b_hat_extend, [k, np, batch]);%(k, np, batch)
        b_hat_extend = permute(b_hat_extend, [2, 1, 3]);%(np, k, batch)
    else
        b_hat_extend = randi([0 1], np, k, batch);%(np, k, batch)
    end
    G_extend = repmat(G, [1, 1, batch]);%(k, n, batch)
    y_extend = repmat(y, [1, np]);%(batch, np*n)
    y_extend = y_extend.';%(n*np, batch)
    y_extend = reshape(y_extend, [n, np, batch]);%(n, np, batch)
    y_extend = permute(y_extend, [2, 1, 3]);%(np, n, batch)
    
    newOrder = gibbsNewOrder_parallel(config, y, G, b_hat);%(np, k, batch)
    for i = 1:config.Gibbs_iter %Gibbs译码循环
        for ii = 1 : k % 按顺序更新k位比特
           update_id = newOrder(:,ii,:); % (np, 1, batch)
           %更新噪声功率
           x_hat=pskmod(mod(pagemtimes(b_hat_extend, G_extend), 2), 2, InputType='bit');%(np, n, batch)
           norm=vecnorm(y_extend-x_hat, 2, 2).^2;%(np, 1, batch)
           sigma2=norm./(2*config.n);
           %sigma2_list=[sigma2_list,sigma2];

           %每个batch都选取残差最小的译码结果而非迭代至最后的译码结果 begin
           opt_id = norm < opt_norm;
           opt_norm(opt_id) = norm(opt_id); 
           opt_id_extend=repmat(opt_id, 1, k, 1);
           opt_b_hat(opt_id_extend) = b_hat_extend(opt_id_extend);%(np, k, batch)
           %每个batch都选取残差最小的译码结果而非迭代至最后的译码结果 end

           %计算L
           d1=1:np;d1=repmat(d1,[1,batch]).'; %row
           d2=reshape(update_id,[np*batch,1]);%col
           d3=1:batch;d3=repmat(d3,[np,1]);d3=reshape(d3,[np*batch,1]);%page
           indices=sub2ind(size(b_hat_extend), d1, d2, d3);%在每个维度分别给出需要引用的索引集合即可
            
           b_hat0=b_hat_extend;b_hat0(indices)=0;%行号加每行索引转为线性索引，避免循环替换
           b_hat1=b_hat_extend;b_hat1(indices)=1;             
           x_hat0=pskmod(mod(pagemtimes(b_hat0, G_extend), 2), 2, InputType='bit');
           x_hat1=pskmod(mod(pagemtimes(b_hat1, G_extend), 2), 2, InputType='bit');
           L=(vecnorm(y_extend-x_hat0, 2, 2).^2 - vecnorm(y_extend-x_hat1, 2, 2).^2)./(2*sigma2);
           %概率
           P=ones(np, 1, batch)./(1+exp(-L));%p(x=1)
           %p_list=[p_list,P]; 依概率更新
           u=rand(np, 1, batch);
           judge = u < P;%(np, 1, batch)
           [bit1_row,~,bit1_page]=ind2sub(size(judge), find(judge == 1));
           [bit0_row,~,bit0_page]=ind2sub(size(judge), find(judge == 0));%已分别知道三个维度的索引，在三维矩阵中引用元素，用sub2ind非常合适

           linear_indices=sub2ind(size(update_id), bit1_row, ones([size(bit1_row,1), 1]), bit1_page);
           bit1_col=update_id(linear_indices);bit1_col=bit1_col(:);
           linear_indices=sub2ind(size(update_id), bit0_row, ones([size(bit0_row,1), 1]), bit0_page);
           bit0_col=update_id(linear_indices);bit0_col=bit0_col(:);
                     
           bit1_indices=sub2ind(size(b_hat_extend), bit1_row, bit1_col, bit1_page);
           bit0_indices=sub2ind(size(b_hat_extend), bit0_row, bit0_col, bit0_page);
           b_hat_extend(bit1_indices)=1;%update the bits
           b_hat_extend(bit0_indices)=0;           
        end
    end
    % 选取np个采样器中残差最小的最为最后的输出
    x_hat=pskmod(mod(pagemtimes(opt_b_hat, G_extend), 2), 2, InputType='bit');%(np, n, batch)
    norm=vecnorm(y_extend-x_hat, 2, 2).^2;%(np, 1, batch)
    [~,min_indices]=min(norm,[],1);%(1, 1, batch)
    d1=reshape(min_indices,1,batch);d1=repmat(d1,k,1);d1=reshape(d1,batch*k,1);
    d2=1:k;d2=repmat(d2(:),batch,1);
    d3=1:batch;d3=repmat(d3,k,1);d3=reshape(d3,batch*k,1);
    indices=sub2ind(size(opt_b_hat), d1, d2, d3);
    
    b_final=opt_b_hat(indices);
    b_final=reshape(b_final,[k,batch]);

% 按照出错概率的大小对k位比特进行排序，容易出错的最先更新 return newOrder 新的更新顺序，将1到k的序号按新顺序排列 b_hat
% (np, k, batch) y     (np, n, batch)
function newOrder_extend = gibbsNewOrder_parallel(config,y,G,b_hat)
    norms=zeros(config.batch,config.k);%存储所有batch的k bit的norm
    np=config.np;k=config.k;batch=config.batch;
    for i = 1:config.k%依次翻转k位比特并计算翻转后的范数
        b_hat_flip=b_hat;
        b_hat_flip(:,i)=1-b_hat(:,i);%分别翻转1到k位的比特
        x_hat_flip=pskmod(mod(b_hat_flip*G,2), 2, InputType='bit');%(batch, n)
        norm_temp=vecnorm(y-x_hat_flip,2,2).^2;
        norms(:,i)=norm_temp;
    end
    [~,newOrder]=sort(norms,2);%对每一行升序排列

    newOrder_extend = repmat(newOrder, [1, np]);%(batch, np*k)
    newOrder_extend = newOrder_extend.';%(k*np, batch)
    newOrder_extend = reshape(newOrder_extend, [k, np, batch]);%(k, np, batch)
    newOrder_extend = permute(newOrder_extend, [2, 1, 3]);%(np, k, batch)
