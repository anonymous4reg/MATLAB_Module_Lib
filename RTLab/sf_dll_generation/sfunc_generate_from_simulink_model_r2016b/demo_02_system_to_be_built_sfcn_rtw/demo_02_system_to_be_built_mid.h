/*
 * demo_02_system_to_be_built_mid.h
 *
 * Code generation for model "demo_02_system_to_be_built_sf".
 *
 * Model version              : 1.3
 * Simulink Coder version : 8.11 (R2016b) 25-Aug-2016
 * C source code generated on : Sun Jul 04 12:17:33 2021
 *
 * Target selection: rtwsfcn.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 *
 * SOURCES: demo_02_system_to_be_built_sf.c
 */

#include "simstruc.h"
#include "demo_02_system_to_be_built_sf.h"
#if defined(MATLAB_MEX_FILE) || defined(RT_MALLOC)

static int_T RegNumInputPorts(SimStruct *S, int_T nInputPorts)
{
  _ssSetNumInputPorts(S,nInputPorts);
  return true;
}

static int_T RegNumOutputPorts(SimStruct *S, int_T nOutputPorts)
{
  _ssSetNumOutputPorts(S,nOutputPorts);
  return true;
}

static int_T FcnSetErrorStatus(const SimStruct *S, DTypeId arg2)
{
  static char msg[256];
  if (strlen(ssGetModelName(S)) < 128) {
    sprintf(msg,
            "S-function %s does not have a tlc file. It cannot use macros that access regDataType field in simstruct.",
            ssGetModelName(S));
  } else {
    sprintf(msg,
            "A S-function does not have a tlc file. It cannot use macros that access regDataType field in simstruct.");
  }

  ssSetErrorStatus(S, msg);
  UNUSED_PARAMETER(arg2);
  return 0;
}

#endif

/* Instance data for model: demo_02_system_to_be_built */
void *demo_02_system_to_be_built_malloc(SimStruct *rts)
{
  /* Local SimStruct for the generated S-Function */
  LocalS *lS = (LocalS *) malloc(sizeof(LocalS));
  ss_VALIDATE_MEMORY(rts,lS);
  (void) memset((char *) lS, 0,
                sizeof(LocalS));
  ssSetUserData(rts, lS);

  /* model checksums */
  ssSetChecksumVal(rts, 0, 2932662615U);
  ssSetChecksumVal(rts, 1, 4171847028U);
  ssSetChecksumVal(rts, 2, 5570269U);
  ssSetChecksumVal(rts, 3, 2123304423U);
  return (NULL);
}
