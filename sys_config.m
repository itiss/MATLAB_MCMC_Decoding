%% 需要手动设置的参数
config.encoding_type="LDPC"; % 编码类型
config.decoding_type="Gibbs_s"; % 译码算法 'BP''Gibbs''Gibbs_s'
config.n=20;
config.coderate=0.5;
config.M=2; % 星座图中元素数量，等于2^(mu)
config.BP_iter=10;
config.Gibbs_iter=10;

config.snr_dbs=2:1:6;
config.max_iter=1e5;
config.target_err_bits=1e2;

config.saveAsFile=true;
% 相关的参数
config.k=config.n*config.coderate;

