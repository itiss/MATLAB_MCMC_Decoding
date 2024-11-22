% 根据校验矩阵获取对应的生成矩阵，已经验证过正确性
% H 校验矩阵 维度n-k*n
% G 返回的生成矩阵，维度k*n
function G = parity2gen(H)
    shape=size(H);
    n=shape(2);
    k=shape(2)-shape(1);
    A1=H(1:n-k,1:k)';
    A2=H(1:n-k,k+1:n)';
    G=[eye(k), A1*inv(A2)];
    G=mod(G,2);