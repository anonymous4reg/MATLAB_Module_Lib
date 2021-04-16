import RtlabApi

def Execute(*args):
    errCode = 0
    errMsg  = ''
    rtlabInfo = args[0]
    
    RtlabApi.SetConnHandle(rtlabInfo['modelConnHandle'])
    RtlabApi.GetSystemControl()
    RtlabApi.GetSignalControl()

    RtlabApi.Execute()

    refVal = 40.0
    RtlabApi.SetSignalsByName('rtdemo1/sc_user_interface/port1',refVal)
    signalValue = RtlabApi.GetSignalsByName('rtdemo1/sm_computation/port1')
    if( signalValue != refVal ):
        errCode = -1
        errMsg = 'Verification of reference value has failed'

    return errCode, errMsg, rtlabInfo
        