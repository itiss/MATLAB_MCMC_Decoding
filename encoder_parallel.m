%并行生成编码比特 10比特为1个batch，此处一次性生成多个batch
function [infoBits,c,G,pcmatrix] = encoder_parallel(config)
    if config.encoding_type=="ldpc"
        if config.n==20 && config.coderate==0.5
            blockSize=5;
            p=[0 -1 1 2; 2 1 -1 0];
            %p=[ -1,  1,  2, -1;3, -1,  0,  4];
        elseif config.n==32 && config.coderate==0.5
            blockSize=8;
            p=[0 -1 1 2; 2 1 -1 0];
        end
        pcmatrix = ldpcQuasiCyclicMatrix(blockSize, p);
        checkmatrix=cast(full(pcmatrix),'double'); %将sparse logical转为矩阵
        G=parity2gen(checkmatrix); % 获取生成矩阵
        cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);

        infoBits = rand(cfgLDPCEnc.NumInformationBits,config.batch) < 0.5;
        c = ldpcEncode(infoBits, cfgLDPCEnc);%LDPC编码
    end