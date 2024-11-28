%% 主程序 multichannel+并行采样
clc
clear

tic
run('sys_config.m');
BER=[];%记录所有snr下的误码率
rng(1); %set the seed
parfor snr_db=config.snr_dbs %在不同的信噪比上仿真
    i = 0;
    err_bits=0;
    total_bits=0;
    while true
        [b,c,G,pcmatrix] = encoder_parallel(config);
        x = pskmod(cast(c,'int8'), 2, InputType='bit'); % BPSK调制结果也要用复数表示 1->-1+0i 0->1+0i
        [y,sigma2] = awgn(x, snr_db+10*log10(config.coderate)); % AWGN信道 应该需要把码率算进去？
        llr=pskdemod(y, 2, OutputType='approxllr');

        b_final=decoder_parallel(config, llr, y, sigma2, G, pcmatrix);
        % 误码性能评估 begin 
        diff=(b~=b_final);
        err_bits=err_bits+sum(diff(:));
        total_bits=total_bits+config.k*config.batch;
        ber=err_bits/total_bits;
        % 误码性能评估 end

        i=i+1;
        fprintf('\rsnr:%f iter:%d err:%d total:%d ber:%.2e',snr_db,i,err_bits,total_bits,ber);
        
        if err_bits>config.target_err_bits || i>config.max_iter
            BER=[BER,ber];
            break;
        end
    end
end

% save the result
if config.saveAsFile
    if config.decoding_type=="Gibbs" || config.decoding_type=="Gibbs_s"
    matname=sprintf('./results/%s/ber_%s_n=%d_k=%d_iter=%d_np=%d_hardinit=%d.mat',...
                    config.encoding_type,...
                    config.decoding_type,...
                    config.n,...
                    config.k, ...
                    config.Gibbs_iter, ...
                    config.np,...
                    config.hard_init);
    else
    matname=sprintf('./results/%s/ber_%s_n=%d_k=%d_iter=%d.mat',...
                    config.encoding_type,...
                    config.decoding_type,...
                    config.n,...
                    config.k, ...
                    config.BP_iter);
    end
    save(matname,'BER');
end
time_end=toc;
disp(['time consumed: ', num2str(time_end/60), 'min']);
%% plot n=20 k=10
clc
clear
run("sys_config.m");
Gibbs_iter=config.Gibbs_iter;
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_BP_n=20_k=10_iter=10.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_Gibbs_n=20_k=10.mat').BER;

mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=%d.mat',Gibbs_iter);
BER_Gibbs_s=load(mat_name).BER;

mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=%d_np=%d_hardinit=%d.mat', ...
    Gibbs_iter,config.np,config.hard_init);
BER_Gibbs_s_np=load(mat_name).BER;

BER_hard=load('./results/ldpc/ber_hard_n=20_k=10.mat').BER;
figure('Position', [100, 100, 500, 400]); 
ber=semilogy(config.snr_dbs,BER_BP,...
             config.snr_dbs,BER_Gibbs,...
             config.snr_dbs,BER_Gibbs_s,...
             config.snr_dbs,BER_Gibbs_s_np,...
             config.snr_dbs,BER_hard);
ber(1).LineWidth=LineWidth;
ber(1).Marker='+';
ber(2).LineWidth=LineWidth;
ber(2).Color='red';
ber(2).Marker='o';
ber(3).LineWidth=LineWidth;
ber(3).Color='red';
ber(3).Marker='^';
ber(4).LineWidth=LineWidth;
ber(4).Marker='d';
ber(5).LineWidth=LineWidth;
ber(5).Marker='<';
ylim([1e-5,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('BP', ...
    'Gibbs', ...
    'Gibbs\_s', ...
    sprintf('Gibbs-s np=%d  hardinit=%d',config.np,config.hard_init), ...
    'hard', ...
    Location='southwest');
title(sprintf('n=20 k=10 Gibbs iter=%d',Gibbs_iter));
grid on

pic_name=sprintf('./pic/ber_Gibbs_iter=%d np=%d hard_init=%d.png',Gibbs_iter,config.np,config.hard_init);
exportgraphics(gca,pic_name);
%% plot n=32 k=16
clc
clear
run("sys_config.m");
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_BP_n=32_k=16.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_Gibbs_n=32_k=16.mat').BER;
BER_Gibbs_s=load('./results/ldpc/ber_Gibbs_s_n=32_k=16.mat').BER;
figure
ber=semilogy(config.snr_dbs,BER_BP,...
             config.snr_dbs,BER_Gibbs,...
             config.snr_dbs,BER_Gibbs_s);
ber(1).LineWidth=LineWidth;
ber(1).Marker='+';
ber(2).LineWidth=LineWidth;
ber(2).Marker='o';
ber(3).LineWidth=LineWidth;
ber(3).Marker='*';
ylim([1e-4,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('BP','Gibbs','Gibbs\_s');
title('n=32,k=16');
grid on

%% norm测试
clc
clear
% 示例矩阵A
A = [
    1, 2, 3, 4;
    5, 6, 7, 8;
    9, 10, 11, 12
];

% 每一行要置为0的列索引
indices = [2, 4];  % 第1行第2列置为0，第2行第3列置为0，第3行第4列置为0

% 获取每一行的索引
rows = [1,2];  % 获取每一行的行号（列向量）

% 直接将指定位置的元素置为0
A(sub2ind(size(A), rows, indices)) = 0;
% 输出结果
disp(A);

%%
a=[1,2,3];
ones(3)/(1+a)























 