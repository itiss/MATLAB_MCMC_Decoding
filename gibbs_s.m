function [b_final,sigma_list]=gibbs_s(config,llr,y,G,sigma2)
    p_list=[];
    sigma2_list=[];
    hard_bits=hard_decision(llr); 
    b_hat=hard_bits(1:config.k); %先利用硬判决初始化估计值
    y=y.'; b_hat=b_hat.';
    newOrder=gibbsNewOrder(config,y,G,b_hat);
    for i = 1:config.Gibbs_iter %Gibbs译码循环
        for j = newOrder %按照newOrder的顺序依次更新k位比特，测试结果表明顺序调整对性能提升较大
        %for j = 1:config.k %依次更新k位比特   仿真过程中收敛很快，几轮过后就不变了           
           %计算L
           b_hat0=b_hat;b_hat0(j)=0;
           b_hat1=b_hat;b_hat1(j)=1;
           x_hat0=pskmod(mod(b_hat0*G,2), 2, InputType='bit');
           x_hat1=pskmod(mod(b_hat1*G,2), 2, InputType='bit');
           L=(norm(y-x_hat0)^2-norm(y-x_hat1)^2)/(2*sigma2);
           %概率
           P=1/(1+exp(-L));%p(x=1)
           p_list=[p_list,P];
           %依概率更新
           u=rand;
           if u<P %第j位取1
               b_hat(j)=1;         
           else %第j位取0
               b_hat(j)=0;
           end  
           %更新噪声功率
           x_hat=pskmod(mod(b_hat*G,2), 2, InputType='bit');
           sigma2=norm(y-x_hat)^2/(2*config.n);% 即便是信噪比为6 sigma2也只更新了一次
           sigma2_list=[sigma2_list,sigma2];
        end
    end
    b_final=b_hat;

% 按照出错概率的大小对k位比特进行排序，容易出错的最先更新
% return newOrder 新的更新顺序，将1到k的序号按新顺序排列
function newOrder = gibbsNewOrder(config,y,G,b_hat)
    norms=zeros(1,config.k);
    for i = 1:config.k
        b_hat_flip=b_hat;
        b_hat_flip(i)=1-b_hat(i);%分别翻转1到k位的比特
        x_hat_flip=pskmod(mod(b_hat_flip*G,2), 2, InputType='bit');
        norms(i)=norm(y-x_hat_flip)^2;
    end
    [~,newOrder]=sort(norms);%升序排列
    
