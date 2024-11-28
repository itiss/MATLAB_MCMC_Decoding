%% 定义一个复数矩阵
A = [1+2i, 3+4i; 5+6i, 7+8i];

% 对矩阵A的每一个元素求模值


% 显示结果
disp((abs(A)).^2);

%% 排序测试
a=[3,2,1];
[b,I]=sort(a);
b
I
%% extend dimension: repeat+transpose
clc
clear
% 原始矩阵 A，维度为 (2, 2)
A = [2, 3; 3, 4];

% 设置扩展的倍数
c = 3;

% 使用 repmat 函数将矩阵 A 沿第二个维度复制 c 次
A_expanded = repmat(A, 1, c);
A_expanded=A_expanded.'
A_expanded=reshape(A_expanded,[3,2,2])
%A_expanded=permute(A_expanded,[2,1,3])
%% 三维数组中按行提取
% 示例三维数组
clc
clear
A = rand(5, 4, 6);  % 假设这是一个 5x4x6 的三维矩阵
rows = [1, 2, 3, 4, 1, 3];  % 每一页中需要提取的行索引

% 创建列索引和页索引
cols = repmat(1:size(A, 2), length(rows), 1);  % 每一页需要提取的所有列
pages = 1:length(rows);  % 页索引

% 提取每一页指定行的所有元素
result = A(sub2ind(size(A), rows, cols, pages));  % 使用 sub2ind 获取线性索引
disp(result);








%% cat 
clc
clear


A = [1, 2, 3; 4, 5, 6];
B = repmat(A, [3, 1, 1]);  % 沿第三维堆叠 3 次
disp(squeeze(B(1,:,:)));
disp(squeeze(B(2,:,:)));
disp(squeeze(B(3,:,:)));
%% transpose for 3D array
clc
clear
% 创建一个 2x3x4 的三维矩阵
A = cat(3, [1, 2, 3; 4, 5, 6], [7, 8, 9; 10, 11, 12], [13, 14, 15; 16, 17, 18], [19, 20, 21; 22, 23, 24]);

% 显示原矩阵的大小
disp('原始矩阵 A 的大小:');
disp(size(A));

% 使用 permute 交换第二维和第三维
B = permute(A, [1, 3, 2]);

% 显示结果
disp('交换第二维和第三维后的矩阵 B 的大小:');
disp(size(B));

% 显示交换后的矩阵
disp('交换后的矩阵 B:');
disp(B);
%% multi dimension matrix
A = ones(3, 2, 4);  % 3x2x4 矩阵
B = ones(2, 5, 4);  % 2x5x4 矩阵

A*B
%% 转线性索引
clc
clear
A = reshape(1:18, 3, 3, 2);  % 3x3x2 的三维数组
disp('原始三维数组：');
disp(A);
% 定义要修改的位置：[页数, 行, 列]
positions = [
    1, 1, 1;  % 第1页，位置(1,1)
    3, 2, 2    % 第2页，位置(3,2)
];

% 定义每个位置的新的值
new_values = [100, 200];
% 使用 sub2ind 计算线性索引
linear_indices = sub2ind(size(A), positions(:,1), positions(:,2), positions(:,3));

% 修改这些位置的值
A(linear_indices) = new_values;

disp('修改后的三维数组：');
disp(A);
%% find
A = rand(3, 3, 3);  % 创建一个 3x3x3 的随机数组
A(1, 2, 3) = 1;     % 假设在 (1, 2, 3) 位置设置为 1
disp(A);
% 找到所有等于 1 的元素的线性索引
[rows, cols, pages] = ind2sub(size(A), find(A == 1));

% 显示结果
disp('等于 1 的元素的各维度索引：');
disp([rows, cols, pages]);

%% broadcast
clc
clear
A = rand(5, 1, 3);  % 创建一个大小为 (5, 1, 3) 的矩阵
disp(A);
b = 4;  % 要扩展到的第二维大小

% 使用 repmat 扩展 A 为 (5, 4, 3)
B = repmat(A, 1, b, 1);

% 检查结果的大小
disp(size(B));  % 应该输出 [5, 4, 3]
disp(B);
%% call of ele from 3D matrix
clc
clear
A = reshape(1:27, [3, 3, 3]);  % 创建一个3x3x3的矩阵，元素从1到27

% 定义行、列、页的索引
i = [1, 2];  % 行索引
j = [2, 3];  % 列索引
k = [1, 2];  % 页索引

% 使用 sub2ind 将 (i, j, k) 转换为线性索引
linear_indices = sub2ind(size(A), i, j, k);

% 使用线性索引从 A 中获取数据
values = A(linear_indices);

% 显示结果
disp(values);



%% 主程序 感觉调制情况下光是纯硬判决都和MCMC差不多了，难道JJJ的工作里真没有调制？
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
        %x = pskmod(cast(c,'int8'), 2, InputType='bit'); % BPSK调制结果也要用复数表示 1->-1+0i 0->1+0i
        [y,sigma2] = awgn(cast(c,'double'), snr_db+10*log10(config.coderate)); % AWGN信道 应该需要把码率算进去？
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
BER
% save the result
if config.saveAsFile
    matname=sprintf('./results/%s/ber_no_modulation_%s_n=%d_k=%d.mat',...
                    config.encoding_type,...
                    config.decoding_type,...
                    config.n,...
                    config.k);
    save(matname,'BER');
end
%% plot n=20 k=10
clc
clear
run("sys_config.m");
LineWidth=1.5;
BER_BP=load('./results/ldpc/ber_no_modulation_BP_n=20_k=10.mat').BER;
BER_Gibbs=load('./results/ldpc/ber_no_modulation_Gibbs_n=20_k=10.mat').BER;
BER_Gibbs_s=load('./results/ldpc/ber_no_modulation_Gibbs_s_n=20_k=10.mat').BER;
%BER_Gibbs_l=load('./results/ldpc/ber_Gibbs_l_n=20_k=10.mat').BER;
BER_hard=load('./results/ldpc/ber_no_modulation_hard_n=20_k=10.mat').BER;
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
title('n=20 k=10');
grid on