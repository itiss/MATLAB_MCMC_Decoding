%% 需要手动设置的参数
config.encoding_type="ldpc"; % 编码类型
config.decoding_type="Gibbs_s"; % 译码算法 'hard' 'BP' 'Gibbs' 'Gibbs_s' 'Gibbs_l'
config.n=20;
config.coderate=0.5;
config.M=2; % 星座图中元素数量，等于2^(mu)
config.BP_iter=10;
config.Gibbs_iter=500;
config.hard_init=0;
config.np=32;%Gibbs parallel samplers
config.batch=10000; %并行执行的batch数量

config.snr_dbs=2:1:6;%低信噪比下（如2） y-Gx的结果并非是在原始比特下取得最小值，sigma2更新过程中是否收敛到min sigma2无法用于参考
%高信噪比下（如5），一般是在原始比特下y-Gx取得最小值，如果sigma2更新过程中没有收敛到min sigma2就会有误比特
config.max_iter=1e5;
config.target_err_bits=1e2;


config.saveAsFile=true;
% 相关的参数
config.k=config.n*config.coderate;

