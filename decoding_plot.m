%% plot n=20 k=10
% 比较增加并行采样数以及迭代轮数对性能的影响
clc
clear
run("sys_config.m");
Gibbs_iter=config.Gibbs_iter;
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_BP_n=20_k=10_iter=10.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_Gibbs_n=20_k=10.mat').BER;

mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=%d.mat',Gibbs_iter);
BER_Gibbs_s=load(mat_name).BER;

mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=50_np=16_hardinit=0.mat');
BER_Gibbs_s_iter50np16=load(mat_name).BER;
mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=50_np=32_hardinit=0.mat');
BER_Gibbs_s_iter50np32=load(mat_name).BER;
mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=100_np=16_hardinit=0.mat');
BER_Gibbs_s_iter100np16=load(mat_name).BER;
mat_name=sprintf('./results/ldpc/ber_Gibbs_s_n=20_k=10_iter=100_np=32_hardinit=0.mat');
BER_Gibbs_s_iter100np32=load(mat_name).BER;

BER_hard=load('./results/ldpc/ber_hard_n=20_k=10.mat').BER;
figure('Position', [100, 100, 600, 400]); 
ber=semilogy(config.snr_dbs,BER_hard,...
             config.snr_dbs,BER_BP,...
             config.snr_dbs,BER_Gibbs,...
             config.snr_dbs,BER_Gibbs_s_iter50np16,...
             config.snr_dbs,BER_Gibbs_s_iter50np32,...
             config.snr_dbs,BER_Gibbs_s_iter100np16,...
             config.snr_dbs,BER_Gibbs_s_iter100np32);
ber(1).LineWidth=LineWidth;
ber(1).Marker='+';
ber(2).LineWidth=LineWidth;
ber(2).Color='red';
ber(2).Marker='o';
ber(3).LineWidth=LineWidth;
ber(3).Color='red';
ber(3).Marker='d';
ber(4).LineWidth=LineWidth;
ber(4).Marker='^';
ber(5).LineWidth=LineWidth;
ber(5).Marker='<';
ber(6).LineWidth=LineWidth;
ber(6).Marker='v';
ber(7).LineWidth=LineWidth;
ber(7).Marker='>';
ylim([1e-5,1]);  
xlabel('SNR(dB)');
ylabel('BER');
legend('hard', ...
    'BP', ...
    'Gibbs', ...
    sprintf('Gibbs-s iter=%d np=%d  hardinit=%d',50,16,0), ...
    sprintf('Gibbs-s iter=%d np=%d  hardinit=%d',50,32,0), ...
    sprintf('Gibbs-s iter=%d np=%d  hardinit=%d',100,16,0), ...
    sprintf('Gibbs-s iter=%d np=%d  hardinit=%d',100,32,0), ...
    Location='southwest');
title('n=20 k=10 Gibbs\_s');
grid on

pic_name='./pic/ber_Gibbs_s.png';
exportgraphics(gca,pic_name);