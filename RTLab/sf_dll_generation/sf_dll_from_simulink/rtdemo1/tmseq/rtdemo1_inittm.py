import RtlabApi
import time

def Execute(*args):
    errCode = 0
    errMsg  = ''
    rtlabInfo = args[0]
    
    RtlabApi.SetConnHandle(rtlabInfo['modelConnHandle'])
    RtlabApi.GetSystemControl()
    RtlabApi.GetParameterControl()

    RtlabApi.Execute()

    refVal = 41.0
    RtlabApi.SetParametersByName('rtdemo1_init/SM_Master/adjust reference/Slider Gain/Gain',refVal)

    t1 = time.clock()
    retries = 0;
    maxRetries = 20;
    numericTolerance = 1e-6;
    while retries < maxRetries:
        signalValue = RtlabApi.GetSignalsByName('rtdemo1_init/SM_Master/adjust reference/Slider Gain/port1')
        if( abs(signalValue - refVal) < numericTolerance ):
            break;       # Allow some time and before another reading because the acquisition does not react immediatelly 
        retries += 1
    t2 = time.clock()
    
    if( retries >= maxRetries ):
        errCode = -1
        errMsg = 'Verification of reference value has failed. Acquisitionned %f instead of %f after %f seconds and %d retries.' % (signalValue,refVal,t2-t1,retries)

    return errCode, errMsg, rtlabInfo
        