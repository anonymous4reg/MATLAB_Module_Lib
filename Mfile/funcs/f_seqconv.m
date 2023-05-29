function [ans_mat] = f_seqconv(sig)
%UNTITLED Summary of this function goes here
%   Input should be this: [Frequency, MagA, PhaseA, MagB, PhaseB, MagC, PhaseC]
    sig_dim = size(sig);
    assert(sig_dim(1) == 3, 'sigal is not a (3 by x) matrix!')
    seq_mat = [exp(1i*0), exp(1i*(2*pi/3)), exp(1i*(-2*pi/3)); ...
		           exp(1i*0), exp(1i*(-2*pi/3)), exp(1i*(2*pi/3)); ...
		           1, 1, 1]./3;
    tmp_ans_mat = zeros(3, sig_dim(2));
    for idx=1:sig_dim(2)
        p_element = sum(seq_mat(1,:)' .* sig(:, idx));
        n_element = sum(seq_mat(2,:)' .* sig(:, idx));
        zero_element = sum(seq_mat(3,:)' .* sig(:, idx));
        tmp_ans_mat(:, idx) = [p_element; n_element; zero_element];
    end
    ans_mat = tmp_ans_mat;
end
