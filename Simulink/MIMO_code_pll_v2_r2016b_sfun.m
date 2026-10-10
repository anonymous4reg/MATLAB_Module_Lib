function [OutUa, OutUb, OutUc, ...
    OutClock, OutDisturbFlag, OutRecFlag, OutRestFlag, ...
    OutFreqIndex, OutFreqNowScan, OutStatus, OutPosOrNegFlag] = ...
    fcn(InStartFlag, PhaseLockSig, FreqSeq, InjectAmp, InjectMode, ...
    t_disturb, t_rec, t_rest, SampleTimeInput)
% InjectMode = 1, Positive sequence
% InjectMode = 2, Negative sequence
% InjectMode = 3, Positive et Negative simutaneously

global hStepCounter;
global hFreqIndex; 
global hStartFlagMem;
global hPhaseLockFlag;
global hRisingEdgeGot; % record a rising-edge get event, cleared untile all frequency are scanned.

this_freq = 0; %% only used for output
FreqSeqLength = length(FreqSeq);

SAMPLE_TIME = SampleTimeInput;
SAMPLE_FREQ = 1/SAMPLE_TIME;

T_DISTURB	= t_disturb * SAMPLE_FREQ;
T_REC 		= t_rec * SAMPLE_FREQ;
T_REST 		= t_rest * SAMPLE_FREQ;

clock_t		= 0;
start_flag	= 0;
status_code	= 0;
ua			= 0; 
ub			= 0; 
uc			= 0;
omega		= 0;
disturb_flag = 0;
rec_flag    = 0;
rest_flag   = 0;

if hPhaseLockFlag == 0 && PhaseLockSig == 1  % Phase-lock event catch, reset by every scan step
    hPhaseLockFlag = 1;
end


start_flag = InStartFlag;
if (start_flag >= 1 && hStartFlagMem == 0) % rising-edge event catch
	hRisingEdgeGot = 1;
	hFreqIndex = 1;
end

if (start_flag >= 1 && hRisingEdgeGot == 1) % once triggerd, loop untill all frequences are scanned
	if (hFreqIndex >=1 && hFreqIndex <= FreqSeqLength && hPhaseLockFlag == 1)
		status_code = 1;
		if (hStepCounter <= (T_DISTURB - T_REC))
			disturb_flag = 1;
			rec_flag = 0;
			rest_flag = 0;
			hStepCounter = hStepCounter + 1;
        elseif ((hStepCounter > (T_DISTURB - T_REC)) && (hStepCounter <= T_DISTURB) && hPhaseLockFlag == 1)
			disturb_flag = 1;
			rec_flag = 1;
			rest_flag = 0;
			hStepCounter = hStepCounter + 1;
        elseif ((hStepCounter > T_DISTURB) && hStepCounter <= (T_DISTURB + T_REST) && hPhaseLockFlag == 1)
			disturb_flag = 0;
			rec_flag = 0;
			rest_flag = 1;
			hStepCounter = hStepCounter + 1;
        else
			hStepCounter = int32(0);
			hFreqIndex = hFreqIndex + 1;
			ua = 0; ub = 0; uc = 0;
            hPhaseLockFlag = 0;
        end

		if (disturb_flag == 1) 
            this_freq = FreqSeq(hFreqIndex); % only used for output port 
			clock_t = double(hStepCounter) * SAMPLE_TIME;
			omega = 2.0 * FreqSeq(hFreqIndex) * pi;
            
			if (InjectMode == 1)
				ua = InjectAmp * sin(omega * clock_t);
				ub = InjectAmp * sin(omega * clock_t - 2.0*pi/3.0);
				uc = InjectAmp * sin(omega * clock_t + 2.0*pi/3.0);
			
            elseif (InjectMode == 2)
				ua = InjectAmp * sin(omega * clock_t);
				ub = InjectAmp * sin(omega * clock_t + 2.0*pi/3.0);
				uc = InjectAmp * sin(omega * clock_t - 2.0*pi/3.0);
                
            elseif (InjectMode == 3)
                ua = InjectAmp * sin(omega * clock_t);
				ub = 0.5 * InjectAmp * sin(omega * clock_t + 2.0*pi/3.0) + ...
                     0.5 * InjectAmp * sin(omega * clock_t - 2.0*pi/3.0);
				uc = ub;
            else
                % other InjectMode to be write here.
            end
        end
	elseif hFreqIndex > FreqSeqLength
		status_code = 2;
		hRisingEdgeGot = 0;
		ua = 0; ub = 0; uc = 0;
	else
		ua = 0; ub = 0; uc = 0;
		status_code = 3;
	end

else % start_flag == 0 || hRisingEdgeGot == 0

	hFreqIndex = 1;

	status_code = 0;
	disturb_flag = 0;
	rec_flag = 0;
	rest_flag = 0;
	hStepCounter = int32(0);
	clock_t = double(hStepCounter) * SAMPLE_TIME;
	ua = 0; ub = 0; uc = 0;
end
	hStartFlagMem = int32(start_flag);  % record start_flag
	OutUa = ua;
	OutUb = ub;
	OutUc = uc;

	OutStatus = status_code;
	OutFreqIndex = hFreqIndex;
	OutFreqNowScan = this_freq;
	OutClock = clock_t;
	OutDisturbFlag = disturb_flag;
	OutRecFlag = rec_flag;
	OutRestFlag = rest_flag;
    OutPosOrNegFlag = InjectMode;
end
