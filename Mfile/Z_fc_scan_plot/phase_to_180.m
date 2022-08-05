function dst_phase_vector = phase_to_180(inputArg)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
src_phase_vector = inputArg;

sel1 = src_phase_vector > 180;
nsel1 = ~sel1;
sel2 = src_phase_vector < -180;
nsel2 = ~sel2;

dst_phase_vector = zeros(size(src_phase_vector));
dst_phase_vector = (src_phase_vector - 360) .* sel1  + ...
    (src_phase_vector + 360).* sel2 + ...
    (src_phase_vector .* nsel1 .* nsel2);
end

