/*
 * demo_02_system_to_be_built_sf.h
 *
 * Code generation for model "demo_02_system_to_be_built_sf".
 *
 * Model version              : 9.3
 * Simulink Coder version : 9.4 (R2020b) 29-Jul-2020
 * C source code generated on : Thu Jul  1 15:26:28 2021
 *
 * Target selection: rtwsfcn.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_demo_02_system_to_be_built_sf_h_
#define RTW_HEADER_demo_02_system_to_be_built_sf_h_
#include <string.h>
#include <stddef.h>
#ifndef demo_02_system_to_be_built_sf_COMMON_INCLUDES_
#define demo_02_system_to_be_built_sf_COMMON_INCLUDES_
#include <stdlib.h>
#define S_FUNCTION_NAME                demo_02_system_to_be_built_sf
#define S_FUNCTION_LEVEL               2
#define RTW_GENERATED_S_FUNCTION
#include "rtwtypes.h"
#include "simstruc.h"
#include "fixedpoint.h"
#if !defined(MATLAB_MEX_FILE)
#include "rt_matrx.h"
#endif

#if !defined(RTW_SFUNCTION_DEFINES)
#define RTW_SFUNCTION_DEFINES

typedef struct {
  void *blockIO;
  void *defaultParam;
  void *nonContDerivSig;
} LocalS;

#define ssSetLocalBlockIO(S, io)       ((LocalS *)ssGetUserData(S))->blockIO = ((void *)(io))
#define ssGetLocalBlockIO(S)           ((LocalS *)ssGetUserData(S))->blockIO
#define ssSetLocalDefaultParam(S, paramVector) ((LocalS *)ssGetUserData(S))->defaultParam = (paramVector)
#define ssGetLocalDefaultParam(S)      ((LocalS *)ssGetUserData(S))->defaultParam
#define ssSetLocalNonContDerivSig(S, pSig) ((LocalS *)ssGetUserData(S))->nonContDerivSig = (pSig)
#define ssGetLocalNonContDerivSig(S)   ((LocalS *)ssGetUserData(S))->nonContDerivSig
#endif
#endif                      /* demo_02_system_to_be_built_sf_COMMON_INCLUDES_ */

#include "demo_02_system_to_be_built_sf_types.h"

/* Shared type includes */
#include "multiword_types.h"
#include "rtGetNaN.h"
#include "rt_nonfinite.h"
#include "rt_defines.h"

/* External inputs (root inport signals with default storage) */
typedef struct {
  real_T *In1;                         /* '<Root>/In1' */
  real_T *In2;                         /* '<Root>/In2' */
} ExternalUPtrs_demo_02_system_to_be_built_T;

/* External outputs (root outports fed by signals with default storage) */
typedef struct {
  real_T *Out1;                        /* '<Root>/Out1' */
} ExtY_demo_02_system_to_be_built_T;

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'demo_02_system_to_be_built_sf'
 */
#endif                         /* RTW_HEADER_demo_02_system_to_be_built_sf_h_ */
