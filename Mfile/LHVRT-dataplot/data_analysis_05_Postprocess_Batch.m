clear;clc
RootDir = "D:\GoldWind\03-MatFile-DLL\GW4.2MW\";


% Idle case processing
PrefixCell = {'VRT'};
PhaseCell = {'3ph', '2ph'};
% DipCell = {'u120', 'u125'};
DipCell = {'u20', 'u35', 'u50', 'u75', 'u90', 'u120', 'u125', 'u130'};
% DipCell = {'u20', 'u35', 'u50', 'u75', 'u90'};
% PostfixCell = {'Idle'};
PostfixCell = {'p4.2', 'p0.84'};
SubFolderCell = FolderSeqGen(PrefixCell, PhaseCell, DipCell, PostfixCell, '_');


tic
for each_folder=1:length(SubFolderCell)
	disp(strcat('[', num2str(each_folder), '/', num2str(length(SubFolderCell)) , ']-', ...
		'Working on :', SubFolderCell{each_folder}))
	sub_folder_dir = strcat(RootDir, '\', SubFolderCell{each_folder}, '\');
	sub_folder_file_list = dir(strcat(sub_folder_dir, '\myfile*') );
	if length(sub_folder_dir) > 1
		disp(strcat('Multiple MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	elseif length(sub_folder_dir) == 1
		clearvars -except RootDir PrefixCell PhaseCell DipCell PostfixCell SubFolderCell each_folder ...
						sub_folder_dir sub_folder_file_list
		

		
		
		load(strcat(sub_folder_dir, '\', 'myfile.mat'))
		
		% file_input
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
		disp('Simulation running...')
		sim('RTLAB_Sim_HVandLV_2015B',20);
		
		
		Unom = 690;  % Volt
		Sn = 4.2e6;  % VA
		
		
		t1 = Pe1lv.time;
		pe1 = Pe1lv.signals.values;
		qe1 = Qe1lv.signals.values;
		pe1 = pe1./Sn;%阳光
		qe1 = qe1./Sn;
		v1 =Vabct1lv.signals.values;
		v1 =v1./Unom/sqrt(2);
		
		
		ip1=Ip1lv.signals.values;
		ip1=ip1./(Sn/Unom/sqrt(3));
		iq1=Iq1lv.signals.values;
		iq1=iq1./(Sn/Unom/sqrt(3));
		
		
		
		figure
		plot(t1,v1,'r','LineWidth',3)
		grid on;
		legend('U1+');
		set(gca,'FontSize',18,'FontWeight','bold');
		xlabel('t/s','fontsize',20);
		ylabel('U/Un','fontsize',20);
		axis_backup_1=axis;
		axis([0 20 axis_backup_1(3:4)]);
		saveas( gca, strcat(sub_folder_dir, '\', 'U1+.fig') )
		saveas( gca, strcat(sub_folder_dir, '\', 'U1+.emf') )
		saveas( gca, strcat(sub_folder_dir, '\', 'U1+.png') )
		
		figure
		plot(t1,pe1,'b',t1,qe1,'r','LineWidth',3)
		grid on;
		legend('P1+','Q1+');
		set(gca,'FontSize',18,'FontWeight','bold');
		xlabel('t/s','fontsize',20);
		ylabel('P/Pn,Q/Qn','fontsize',20);
		axis_backup_1=axis;
		axis([0 20 axis_backup_1(3:4)]);
		saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.fig') )
		saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.emf') )
		saveas( gca, strcat(sub_folder_dir, '\', 'PQ+.png') )
		
		figure
		plot(t1,ip1,'b',t1,iq1,'r','LineWidth',3)
		grid on;
		legend('Ip1+','Iq1+');
		set(gca,'FontSize',18,'FontWeight','bold');
		xlabel('t/s','fontsize',20);
		ylabel('I/In','fontsize',20);
		axis_backup_1=axis;
		axis([0 20 axis_backup_1(3:4)]);
		saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.fig') )
		saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.emf') )
		saveas( gca, strcat(sub_folder_dir, '\', 'IpIq+.png') )
		
		save(strcat(sub_folder_dir, '\', 'data_t'), 't1');
		save(strcat(sub_folder_dir, '\', 'data_u'), 'v1');
		save(strcat(sub_folder_dir, '\', 'data_P'), 'pe1');
		save(strcat(sub_folder_dir, '\', 'data_Q'), 'qe1');
		save(strcat(sub_folder_dir, '\', 'data_Ip'), 'ip1');
		save(strcat(sub_folder_dir, '\', 'data_Iq'), 'iq1');
		
		close all
						
						
		
	else
		disp(strcat('No MAT-File in this path: ', sub_folder_dir))
		disp('Pass...')
	end
% 	break  % debug only
	
end
disp('Done')
toc
