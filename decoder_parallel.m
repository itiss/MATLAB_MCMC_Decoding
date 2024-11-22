function b_final=decoder_parallel(config,llr,y,sigma2,G,pcmatrix)
    if config.decoding_type=="BP"
        cfgLDPCDec = ldpcDecoderConfig(pcmatrix);
        b_final = ldpcDecode(llr,cfgLDPCDec,config.BP_iter);
    elseif config.decoding_type=="Gibbs"
        b_final=gibbs_decoder(config,llr,y,G,sigma2);
        b_final=b_final(:);%变成列向量
        b_final=cast(b_final,'int8');
    elseif config.decoding_type=="Gibbs_s"
        b_final=gibbs_s_parallel(config,llr,y,G,sigma2);
        b_final=cast(b_final,'int8');
    elseif config.decoding_type=="Gibbs_l"
        b_final=gibbs_l(config,y,G);
        b_final=b_final(:);%变成列向量
        b_final=cast(b_final,'int8');
    elseif config.decoding_type=="hard" % 不利用LDPC 纯硬判决
        hard_bits=hard_decision(llr); 
        b_hat=hard_bits(1:config.k);
        b_final=b_hat(:);%变成列向量
        b_final=cast(b_final,'int8');
    end