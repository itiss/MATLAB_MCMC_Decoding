%%
%%
clc
clear
rng(1);
blockSize = 3;
n=12;
k=6;
p = [0 -1 1 2; 2 1 -1 0];
pcmatrix = ldpcQuasiCyclicMatrix(blockSize, p);
checkmatrix=cast(full(pcmatrix),'single'); % 将sparse logical转为单精度的矩阵
G=gen2par(mod(rref(checkmatrix),2)); % rref标准化后由校验矩阵得到生成矩阵
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
b = rand(cfgLDPCEnc.NumInformationBits,1) < 0.5;
c = ldpcEncode(b, cfgLDPCEnc);

b=cast(b,'double');
H=cast(full(pcmatrix),'double');
c=cast(c,'double');
G=cast(G,'double');
%验证H的正确性
mod(c'*H',2)

%产生G
% A1=H(1:n-k,1:k)';
% A2=H(1:n-k,k+1:n)';
% G=[eye(k), A1*inv(A2)]; 
G=parity2gen(H);
%验证G的正确性
mod(b'*G,2)
c'
%%
clc
clear
P = [16 17 22 24  9  3 14 -1  4  2  7 -1 26 -1  2 -1 21 -1  1  0 -1 -1 -1 -1
     25 12 12  3  3 26  6 21 -1 15 22 -1 15 -1  4 -1 -1 16 -1  0  0 -1 -1 -1
     25 18 26 16 22 23  9 -1  0 -1  4 -1  4 -1  8 23 11 -1 -1 -1  0  0 -1 -1
      9  7  0  1 17 -1 -1  7  3 -1  3 23 -1 16 -1 -1 21 -1  0 -1 -1  0  0 -1
     24  5 26  7  1 -1 -1 15 24 15 -1  8 -1 13 -1 13 -1 11 -1 -1 -1 -1  0  0
      2  2 19 14 24  1 15 19 -1 21 -1  2 -1 24 -1  3 -1  2  1 -1 -1 -1 -1  0
    ];
blockSize = 27;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize,P);
cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
infoBits = rand(cfgLDPCEnc.NumInformationBits,1) < 0.5;
codeword = ldpcEncode(infoBits, cfgLDPCEnc);
%%
clc
clear
P = [
    16 17 22 24  9  3 14 -1  4  2  7 -1 26 -1  2 -1 21 -1  1  0 -1 -1 -1 -1
    25 12 12  3  3 26  6 21 -1 15 22 -1 15 -1  4 -1 -1 16 -1  0  0 -1 -1 -1
    25 18 26 16 22 23  9 -1  0 -1  4 -1  4 -1  8 23 11 -1 -1 -1  0  0 -1 -1
     9  7  0  1 17 -1 -1  7  3 -1  3 23 -1 16 -1 -1 21 -1  0 -1 -1  0  0 -1
    24  5 26  7  1 -1 -1 15 24 15 -1  8 -1 13 -1 13 -1 11 -1 -1 -1 -1  0  0
     2  2 19 14 24  1 15 19 -1 21 -1  2 -1 24 -1  3 -1  2  1 -1 -1 -1 -1  0
    ];
blockSize = 27;
pcmatrix = ldpcQuasiCyclicMatrix(blockSize,P);

cfgLDPCEnc = ldpcEncoderConfig(pcmatrix);
cfgLDPCDec = ldpcDecoderConfig(pcmatrix);
M = 4;
maxnumiter = 10;
snr = [3 6 20];
numframes = 1000;

ber = comm.ErrorRate;
ber2 = comm.ErrorRate;

for ii = 1:length(snr)
    for counter = 1:numframes
        data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
        % Transmit and receive with LDPC coding
        encodedData = ldpcEncode(data,cfgLDPCEnc);
        modSignal = pskmod(encodedData,M,InputType='bit');
        [rxsig, noisevar] = awgn(modSignal,snr(ii));
        demodSignal = pskdemod(rxsig,M, ...
            OutputType='approxllr', ...
            NoiseVariance=noisevar);
        rxbits = ldpcDecode(demodSignal,cfgLDPCDec,maxnumiter);
        errStats = ber(data,rxbits);    
        % Transmit and receive with no LDPC coding
        noCoding = pskmod(data,M,InputType='bit');
        rxNoCoding = awgn(noCoding,snr(ii));
        rxBitsNoCoding = pskdemod(rxNoCoding,M,OutputType='bit');
        errStatsNoCoding = ber2(data,int8(rxBitsNoCoding));
    end
    fprintf(['SNR = %2d\n   Coded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        snr(ii),errStats(1),errStats(2))
    fprintf(['Noncoded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        errStatsNoCoding(1),errStatsNoCoding(2))
    reset(ber);
    reset(ber2);
end