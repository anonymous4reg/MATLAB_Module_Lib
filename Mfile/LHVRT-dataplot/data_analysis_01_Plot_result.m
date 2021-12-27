% user setting here
close all
Ts=2e-5;  % set this value same as your model
VarNamePrefix = "opvar";
t_range = 15;
T_LHVRT_Iq_Test = 2.45;
sub_folder_dir = '.';
setFontSize = 10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Don't change here if you don't know what it is.   %%%%%%
var_name_found = who;
var_name_found = var_name_found(~cellfun(@isempty, regexpi(var_name_found, strcat(VarNamePrefix, '.*'))));
if length(var_name_found) == 1
    data_1 = eval(var_name_found{1});
else
    raise
end
%%%%%%%%%%%%%%%%%%%%%%%% Some handy funcs  %%%%%%%%%%%%%%%%%%%%%%
% standard test funcs for LHVRT
hf = @(x) 1.5*(x-1.1);
lf = @(x) 1.5*(0.9-x);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



t=data_1(1,:);
t=t-t(1);
t=t';

Vabc_690V =                                 data_1(2:4,:)';
Iabc_690V =                                 data_1(5:7,:)';

V_pu_690V =                                 data_1(8,:)';
P_pu_690V =                                 data_1(9,:)';
Q_pu_690V =                                 data_1(10,:)';
Ip_pu_690V =                                data_1(11,:)';
Iq_pu_690V =                                data_1(12,:)';

% RMS_pu_690V =                               data_1(13:15,:)';
% Module_mag_pu_690V =                        data_1(16,:)';
% Module_phase_pu_690V =                      data_1(17,:)';

% VRT_trig =                                  data_1(18,:)';
% Record_trig =                               data_1(19,:)';
% Vabc_35kV =                                 data_1(20:22,:)';
% Vabc_stator =                               data_1(23:25, :)';
% Iabc_stator =                               data_1(26:28, :)';
% Iabc_grid =                                 data_1(29:31, :)';
% Iabc_rotor =                                data_1(32:34, :)';
% Vabc_stator_fpga =                          data_1(35:37, :)';
% Vabc_rotor_fpga =                           data_1(38:40, :)';
% Iabc_crowbar =                              data_1(41:43, :)';
% I_chopper =                                 data_1(44, :)';

% Vdc =                                       data_1(45, :)';

% DI_bit1_main_connector =                    data_1(46, :)';
% DI_bit2_soft_connector =                    data_1(47, :)';
% DI_bit3_grid_connector_lost =               data_1(48, :)';
% DI_bit4_grid_breaker_ON =                   data_1(49, :)';
% DI_bit5_grid_breaker_OFF =                  data_1(50, :)';
% DI_bit6_stator_connector_MCC =              data_1(51, :)';
% DO_feedback_bit1_grid_breaker_OFF =         data_1(52, :)';
% DO_feedback_bit2_grid_breaker_ON =          data_1(53, :)';
% DO_feedback_bit3_stator_connector_MCC_NOT = data_1(54, :)';
% DO_feedback_bit4_main_connector =           data_1(55, :)';
% DO_feedback_bit5_soft_connector =           data_1(56, :)';
% DO_feedback_bit6_stator_connector_MCC =     data_1(57, :)';
% PWM_grid_AUAD_BUBD_CUCD =                   data_1(58:63, :)';
% PWM_rotor_AUAD_BUBD_CUCD =                  data_1(64:69, :)';
% Crowbar_drive =                             data_1(70, :)';
% Chopper_drive =                             data_1(71, :)';
% FPGA_Iabc_stator =                          data_1(72:74, :)';
% FPGA_Iabc_rotor =                           data_1(75:77, :)';
% FPGA_Idq_stator =                           data_1(78:79, :)';
% FPGA_Idq_rotor =                            data_1(80:81, :)';
% FPGA_phidq_stator =                         data_1(82:83, :)';
% FPGA_phidq_rotor =                          data_1(84:85, :)';
% FPGA_vdq_stator =                           data_1(86:87, :)';
% FPGA_vdq_rotor =                            data_1(88:89, :)';
% FPGA_theta_elec =                           data_1(90, :)';
% FPGA_theta_mec =                            data_1(91, :)';
% FPGA_Te =                                   data_1(92, :)';
% FPGA_spare1 =                               data_1(93, :)';
% FPGA_spare2 =                               data_1(94, :)';
% FPGA_Rs =                                   data_1(95, :)';
% FPGA_Rr =                                   data_1(96, :)';
% FPGA_Lls =                                  data_1(97, :)';
% FPGA_Llr =                                  data_1(98, :)';
% FPGA_Lm =                                   data_1(99, :)';
% FPGA_speed_mec_rpm =                        data_1(100, :)';
% FPGA_we =                                   data_1(101, :)';


T_LHVRT_Iq_Test_idx = int64(T_LHVRT_Iq_Test/Ts);
t_LHVRT_Iq_Test = t(T_LHVRT_Iq_Test_idx);
val_LHVRT_Iq_Test = V_pu_690V(T_LHVRT_Iq_Test_idx);
val_LHVRT_Iq_Test_lim = 0;
if val_LHVRT_Iq_Test <= 1
    % LVRT
    val_LHVRT_Iq_Test_lim = lf(val_LHVRT_Iq_Test);
else 
    val_LHVRT_Iq_Test_lim = -hf(val_LHVRT_Iq_Test);
end
val_LHVRT_Iq_Test_lim_vec = val_LHVRT_Iq_Test_lim * ones(length(t), 1);


%% Unified plot
figure
[ha, pos] = tight_subplot(3, 2, [0.04, 0.06], [0.03, 0.03], [0.06, 0.01]);
set(gcf,'unit','centimeters','position',[0.5, 1, 30, 20])

for hidx = 1:6
    axes(ha(hidx))
    switch hidx
        case 1
            fh1 = plot(t,V_pu_690V,'r','LineWidth', 1.2);
            grid on;
            legend('U+');
            ylabel('U/Un');
            title('\fontname{Times new roman} U+')
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
            datatip(fh1, t_LHVRT_Iq_Test, val_LHVRT_Iq_Test);
        case 2
            plot(t, P_pu_690V,'r','LineWidth', 1.2)
            grid on;
            legend('P+');
            ylabel('P/Pn');
            title('\fontname{Times new roman} P+')
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
        
        case 3
            plot(t, Q_pu_690V,'r','LineWidth', 1.2)
            grid on;
            legend('Q+');
            ylabel('Q/Pn');
            title('\fontname{Times new roman} Q+')
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
        case 4
            plot(t, Ip_pu_690V,'r','LineWidth', 1.2)
            grid on;
            legend('Ip+');
            ylabel('Ip/In');
            title('\fontname{Times new roman} Ip+')
            set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
        case 5
            plot(t, Iq_pu_690V,'r','LineWidth', 1.2)
            grid on;
            hold on 
            plot(t, val_LHVRT_Iq_Test_lim_vec, 'k', 'LineWidth', 1)
            legend({'Iq+', 'Iq std limit'});
            ylabel('Iq/In');
            title('\fontname{Times new roman} Iq+')
            axis_backup_1=axis;
            axis([0 t_range axis_backup_1(3:4)]);
            set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
        case 6
            %% You can plot anything you want here.
            % plot(t, Crowbar_drive, 'LineWidth', 1.2)
            % hold on
            % grid on
            % plot(t, Chopper_drive, 'LineWidth', 1.2)
            % legend({'CrowbarDrive', 'ChopperDrive'})
            % title('\fontname{Times new roman} Crowbar & Chopper Drive')
            % axis_backup_1=axis;
            % axis([0 t_range -0.5, 1.5]);
            % set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
        otherwise
            disp('wrong')
    end

end



% figure
% [ha, pos] = tight_subplot(5, 3, [0.04, 0.06], [0.03, 0.03], [0.06, 0.01]);
% set(gcf,'unit','centimeters','position',[0.5, 1, 45, 25])

% for hidx = 1:15
%     axes(ha(hidx))
%     switch hidx
%         case 1
%             fh1 = plot(t,V_pu_690V,'r','LineWidth', 1.2);
%             grid on;
%             legend('U+');
%             ylabel('U/Un');
%             title('\fontname{Times new roman} U+')
%             axis_backup_1=axis;
%             axis([0 t_range axis_backup_1(3:4)]);
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             datatip(fh1, t_LHVRT_Iq_Test, val_LHVRT_Iq_Test);
%         case 2
%             plot(t, P_pu_690V,'r','LineWidth', 1.2)
%             grid on;
%             legend('P+');
%             ylabel('P/Pn');
%             title('\fontname{Times new roman} P+')
%             axis_backup_1=axis;
%             axis([0 t_range axis_backup_1(3:4)]);
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
        
%         case 3
%             plot(t, Q_pu_690V,'r','LineWidth', 1.2)
%             grid on;
%             legend('Q+');
%             ylabel('Q/Pn');
%             title('\fontname{Times new roman} Q+')
%             axis_backup_1=axis;
%             axis([0 t_range axis_backup_1(3:4)]);
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%         case 4
%             plot(t, Ip_pu_690V,'r','LineWidth', 1.2)
%             grid on;
%             legend('Ip+');
%             ylabel('Ip/In');
%             title('\fontname{Times new roman} Ip+')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%         case 5
%             plot(t, Iq_pu_690V,'r','LineWidth', 1.2)
%             grid on;
%             hold on 
%             plot(t, val_LHVRT_Iq_Test_lim_vec, 'k', 'LineWidth', 1)
%             legend({'Iq+', 'Iq std limit'});
%             ylabel('Iq/In');
%             title('\fontname{Times new roman} Iq+')
%             axis_backup_1=axis;
%             axis([0 t_range axis_backup_1(3:4)]);
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%         case 6
%             plot(t, Crowbar_drive, 'LineWidth', 1.2)
%             hold on
%             grid on
%             plot(t, Chopper_drive, 'LineWidth', 1.2)
%             legend({'CrowbarDrive', 'ChopperDrive'})
%             title('\fontname{Times new roman} Crowbar & Chopper Drive')
%             axis_backup_1=axis;
%             axis([0 t_range -0.5, 1.5]);
%             set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
%         case 7
%             plot(t, Vdc, 'LineWidth', 1.2)
%             ylabel('Udc');
%             title('\fontname{Times new roman} Udc')
%             grid on 
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%         case 8
%             plot(t, Vabc_690V, 'LineWidth', 1.2)
%             grid on 
%             ylabel('Uabc (690V)');
%             title('\fontname{Times new roman} Uabc (690V)')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'Ua', 'Ub', 'Uc'})
%         case 9
%             plot(t, Iabc_690V, 'LineWidth', 1.2)
%             grid on 
%             ylabel('Iabc (690V)');
%             title('\fontname{Times new roman} Iabc (690V)')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'Ia', 'Ib', 'Ic'})
%         case 10
%             plot(t, Iabc_grid, 'LineWidth', 1.2)
%             grid on 
%             ylabel('Iabc grid (+dir -> grid)')
%             title('\fontname{Times new roman} Iabc grid (+dir -> grid)')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'Ia', 'Ib', 'Ic'})
%         case 11
%             plot(t, Iabc_stator, 'LineWidth', 1.2)
%             grid on 
%             ylabel('Iabc stator (+dir -> motor)')
%             title('\fontname{Times new roman} Iabc stator (+dir -> motor)')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'Ia', 'Ib', 'Ic'})
%         case 12
%             plot(t, Iabc_rotor)
%             grid on 
%             ylabel('Iabc rotor (+dir -> motor)')
%             title('\fontname{Times new roman} Iabc rotor (+dir -> motor)')
%             set(gca, 'xlim', [0, t_range], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'Ia', 'Ib', 'Ic'})
%         case 13
%             plot(t, PWM_grid_AUAD_BUBD_CUCD)
%             grid on 
%             ylabel('PWM grid side conv 6 pulses')
%             title('\fontname{Times new roman}PWM grid side conv 6 pulses')
%             set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'AU', 'AD', 'BU', 'BD', 'CU', 'CD'})
%         case 14
%             plot(t, PWM_rotor_AUAD_BUBD_CUCD)
%             grid on 
%             ylabel('PWM rotor side conv 6 pulses')
%             title('\fontname{Times new roman}PWM rotor side conv 6 pulses')
%             set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'AU', 'AD', 'BU', 'BD', 'CU', 'CD'})
%         case 15
%             plot(t, RMS_pu_690V)
%             grid on 
%             hold on 
%             plot(t, Module_mag_pu_690V)
%             ylabel('RMS and Module mag')
%             title('\fontname{Times new roman}RMS and Module mag')
%             set(gca, 'xlim', [0, t_range], 'ylim', [-0.5, 1.5], 'fontname', 'times new roman', 'fontsize', setFontSize)
%             legend({'RMS Ua', 'RMS Ub', 'RMS Uc', 'Module mag'})
%         otherwise
%             disp('wrong')
%     end

% end




% save(strcat(sub_folder_dir, '\', 'data_t'), 't');
% save(strcat(sub_folder_dir, '\', 'data_u35'), 'V35');
% save(strcat(sub_folder_dir, '\', 'data_Q35'), 'Q35');
% save(strcat(sub_folder_dir, '\', 'data_Iq35'), 'Iq35');
% save(strcat(sub_folder_dir, '\', 'data_u230'), 'V230');
% save(strcat(sub_folder_dir, '\', 'data_Q230'), 'Q230');
% save(strcat(sub_folder_dir, '\', 'data_Iq230'), 'Iq230');

% clear;clc