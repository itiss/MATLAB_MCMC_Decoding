function b_final=gibbs_decoder(config,llr,y,G,sigma2)
    hard_bits=hard_decision(llr); 
    b_hat=hard_bits(1:config.k); %先利用硬判决初始化估计值
    y=y.';
    b_hat=b_hat.';
    for i = 1:config.Gibbs_iter %Gibbs译码循环
        for j = 1:config.k %依次更新k位比特
           b_hat0=b_hat;b_hat0(j)=0;
           b_hat1=b_hat;b_hat1(j)=1;
           x_hat0=pskmod(mod(b_hat0*G,2), 2, InputType='bit');
           x_hat1=pskmod(mod(b_hat1*G,2), 2, InputType='bit');
           
           L=(norm(y-x_hat0)^2-norm(y-x_hat1)^2)/(2*sigma2);
           P=1/(1+exp(-L));
           u=rand;
           if u<P %第j位取1
               b_hat(j)=1;
           else %第j位取0
               b_hat(j)=0;
           end      
        end
    end
    b_final=b_hat;

    