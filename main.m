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
        x = pskmod(cast(c,'int8'), 2, InputType='bit'); % BPSK调制结果也要用复数表示 1->-1+0i 0->1+0i
        [y,sigma2] = awgn(x, snr_db+10*log10(config.coderate)); % AWGN信道 应该需要把码率算进去？
        llr=pskdemod(y, 2, OutputType='approxllr');

        b_final=decoder(config, llr, y, sigma2, G, pcmatrix);
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
    if config.decoding_type=="Gibbs" || config.decoding_type=="Gibbs_s"
    matname=sprintf('./results/%s/ber_%s_n=%d_k=%d_iter=%d.mat',...
                    config.encoding_type,...
                    config.decoding_type,...
                    config.n,...
                    config.k, ...
                    config.Gibbs_iter);
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

%% plot n=20 k=10
clc
clear
run("sys_config.m");
Gibbs_iter=config.Gibbs_iter;
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_BP_n=20_k=10.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_Gibbs_n=20_k=10.mat').BER;

mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=%d.mat',Gibbs_iter);
BER_Gibbs_s=load(mat_name).BER;

BER_hard=load('./results/ldpc/ber_hard_n=20_k=10.mat').BER;
figure
ber=semilogy(config.snr_dbs,BER_BP,...
             config.snr_dbs,BER_Gibbs,...
             config.snr_dbs,BER_Gibbs_s,...
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
ylim([1e-5,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('BP','Gibbs','Gibbs\_s','hard');
title(sprintf('n=20 k=10 Gibbs iter=%d',Gibbs_iter));
grid on

pic_name=sprintf('./pic/ber_Gibbs_iter=%d.png',Gibbs_iter);
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

%% 
clc 
clear
b33=0.864;b32=-1.44;b31=-0.6;
k3=-b33
b21=(b31+k3*b32)/(1-k3^2)
b22=(b32+k3*b31)/(1-k3^2)
k2=-b22
b11=(b21+k2*b21)/(1-k2^2)
k1=-b11

b=[1,-0.6,-1.44,0.864];
k=-tf2latc(b).'
%% 
clc 
clear
b33=-0.898;b32=0.9;b31=-0.98;
k3=-b33
b21=(b31+k3*b32)/(1-k3^2)
b22=(b32+k3*b31)/(1-k3^2)
k2=-b22
b11=(b21+k2*b21)/(1-k2^2)
k1=-b11

b=[1,-0.98,0.9,-0.898];
k=-tf2latc(b).'
%%
clc
clear
b=[1,-0.6,-1.44,0.864];
a=[1,-0.98,0.9,-0.898];
[k,c]=tf2latc(b,a);
k=-k.'
c=c.'
























 