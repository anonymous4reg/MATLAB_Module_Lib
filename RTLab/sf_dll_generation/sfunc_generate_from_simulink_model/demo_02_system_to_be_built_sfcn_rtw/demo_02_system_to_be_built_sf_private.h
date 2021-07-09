/*
 * demo_02_system_to_be_built_sf_private.h
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

#ifndef RTW_HEADER_demo_02_system_to_be_built_sf_private_h_
#define RTW_HEADER_demo_02_system_to_be_built_sf_private_h_
#include "rtwtypes.h"
#include "multiword_types.h"
#if !defined(ss_VALIDATE_MEMORY)
#define ss_VALIDATE_MEMORY(S, ptr)     if(!(ptr)) {\
 ssSetErrorStatus(S, RT_MEMORY_ALLOCATION_ERROR);\
 }
#endif

#if !defined(rt_FREE)
#if !defined(_WIN32)
#define rt_FREE(ptr)                   if((ptr) != (NULL)) {\
 free((ptr));\
 (ptr) = (NULL);\
 }
#else

/* Visual and other windows compilers declare free without const */
#define rt_FREE(ptr)                   if((ptr) != (NULL)) {\
 free((void *)(ptr));\
 (ptr) = (NULL);\
 }
#endif
#endif
#endif                 /* RTW_HEADER_demo_02_system_to_be_built_sf_private_h_ */
