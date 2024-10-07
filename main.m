%% 主程序
clc
clear

run('sys_config.m');
ber=comm.ErrorRate;
BER=[];
rng(1); %set the seed
for snr_db=config.snr_dbs %在不同的信噪比上仿真
    i = 0;
    while true
        [b,c,G,pcmatrix] = encoder(config);
        x = pskmod(cast(c,'int8'), 2,InputType='bit');% BPSK调制结果也要用复数表示 1->-1+0i 0->1+0i
        [y,sigma2] = awgn(x, snr_db+10*log10(config.coderate)); %AWGN信道 应该需要把码率算进去？
        llr=pskdemod(y, 2, OutputType='approxllr', NoiseVariance=sigma2);
        b_final=decoder(config,llr,y,sigma2,G,pcmatrix);
        % b_final=hard_decision(llr);
        % b_final=b_final(1:config.k);
            
        errstate=ber(b,b_final); % ber, err bits, total_bits
        i=i+1;
        fprintf('\rsnr:%f iter:%d err:%d total:%d',snr_db,i,errstate(2),errstate(3));
        if errstate(2)>config.target_err_bits || errstate(3)>config.max_iter
            BER=[BER,errstate(1)];
            reset(ber);
            break;
        end
    end
end

% save the result
if config.saveAsFile
    matname=sprintf('./results/%s/ber_%s_n=%d_k=%d.mat',...
                    config.encoding_type,...
                    config.decoding_type,...
                    config.n,...
                    config.k);
    save(matname,'BER');
end

% plot n=20 k=10
clc
clear
run("sys_config.m");
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_BP_n=20_k=10.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_Gibbs_n=20_k=10.mat').BER;
BER_Gibbs_s=load('./results/ldpc/ber_Gibbs_s_n=20_k=10.mat').BER;
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
ylim([1e-5,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('BP','Gibbs','Gibbs\_s');
title('n=20 k=10');
grid on

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
ylim([1e-5,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('BP','Gibbs','Gibbs\_s');
title('n=32,k=16');
grid on

























 