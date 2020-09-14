% User input para here!!!
Vrms_ph_hv = 37e3;  % 没啥p用，可以乱填，但不可以不�?
Vrms_ph_lv = 690;  % 没啥p用，可以乱填，但不可以不�?
Ts = 20e-6;


% Don't change below if you don't know what it is.
t=opvar(1,:);
t=t-t(1);
t=t';



% High voltage side
vahv=opvar(2,:)';
vbhv=opvar(3,:)';
vchv=opvar(4,:)';

iahv=-opvar(5,:)';
ibhv=-opvar(6,:)';
ichv=-opvar(7,:)';

vabhv = vahv - vbhv;
vbchv = vbhv - vchv;
vcahv = vchv - vahv;


% Low voltage side
valv=opvar(8,:)';
vblv=opvar(9,:)';
vclv=opvar(10,:)';

ialv=-opvar(11,:)';
iblv=-opvar(12,:)';
iclv=-opvar(13,:)';

vablv = valv - vblv;
vbclv = vblv - vclv;
vcalv = vclv - valv;


warning('off', 'all')
% Sim and plot
sim('RTLAB_Sim_HVandLV_2015B',20);
