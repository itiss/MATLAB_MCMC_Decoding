function b_final=decoder(config,llr,y,sigma2,G,pcmatrix)
    if config.decoding_type=="BP"
        cfgLDPCDec = ldpcDecoderConfig(pcmatrix);
        b_final = ldpcDecode(llr,cfgLDPCDec,config.BP_iter);
    elseif config.decoding_type=="Gibbs"
        b_final=gibbs_decoder(config,llr,y,G,sigma2);
        b_final=b_final(:);%变成列向量
        b_final=cast(b_final,'int8');
    elseif config.decoding_type=="Gibbs_s"
        b_final=gibbs_s(config,llr,y,G);
        b_final=b_final(:);%变成列向量
        b_final=cast(b_final,'int8');
    end