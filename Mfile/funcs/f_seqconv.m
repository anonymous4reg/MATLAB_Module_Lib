function [ans_mat] = f_seqconv(sig)
% verion 2: 
%   2024/4/17 - Change to matrix multiplication. Caution, if you transpose your signal to 
%               shape 3 by x before feeding in  __sig__, make sure it is transpose, not the
%               conjugate transpose!!!
%   Input should be this: [Frequency, MagA, PhaseA, MagB, PhaseB, MagC, PhaseC]
    sig_dim = size(sig);
    assert(sig_dim(1) == 3, 'sigal is not a (3 by x) matrix!')
    seq_mat = [1, exp(1i*(2*pi/3)), exp(1i*(-2*pi/3)); ...
               1, exp(1i*(-2*pi/3)), exp(1i*(2*pi/3)); ...
               1,          1,               1]./3;
                          
    tmp_ans_mat = zeros(3, sig_dim(2));
    ans_mat = seq_mat * sig;
end
