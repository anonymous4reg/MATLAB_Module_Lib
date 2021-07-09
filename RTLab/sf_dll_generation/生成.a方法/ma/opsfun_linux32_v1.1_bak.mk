# --------------------------------
# USER-DEFINED PARAMETERS
# --------------------------------
# Name of static library to be generated. Do not write file extension.
LIB_NAME = LibPCSController
# Source files. Do not forget to write all of them. Ex: SRC = source1.c source2.c
SRC = PCS_Controller_sf.c	PCS_Controller_sf_data.c

# Matlab version. Ex: For R2011b, MATLAB_VERSION = v7.13
MATLAB_VERSION = v8.7
# For intel compiler, RTLAB_INTEL_COMPILER = 1. For gcc compiler, RTLAB_INTEL_COMPILER = 0	
RTLAB_INTEL_COMPILER = 0
# --------------------------------

OBJS = $(SRC:.c=.o)

MATLAB_INCLUDES = -I/usr/matlab/$(MATLAB_VERSION)/simulink/include -I/usr/matlab/$(MATLAB_VERSION)/extern/include -I/usr/matlab/$(MATLAB_VERSION)/rtw/c/src -I/usr/matlab/$(MATLAB_VERSION)/rtw/c/src/matrixmath -I/usr/matlab/$(MATLAB_VERSION)/rtw/c/libsrc  -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/drive -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/mech -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/foundation -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/network_engine -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/ne_sli -I/usr/matlab/$(MATLAB_VERSION)/toolbox/dspblks/include -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/compiler/core/c -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/engine/sli/c -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/engine/core/c -I/usr/matlab/$(MATLAB_VERSION)/toolbox/simscape/include/utils
INCLUDES = -I. $(MATLAB_INCLUDES)
LIBS = 
LIBPATHS = 
DEFINES = -DUSE_RTMODEL -DRT=RT -DTID01EQ=1 -DMULTITASKING=0

ifeq ($(RTLAB_INTEL_COMPILER),1)
	CC = opicc
	LD = opxiar
	CC_OPTS = -c -O2 -xHost -falign-functions=2 -diag-disable remark,warn,cpu-dispatch
	LD_OPTS =
else
	CC = gcc
	LD = ar
	CC_OPTS = -c -O2 -ffast-math -mtune=i686 -march=i686 -falign-loops=2 -falign-jumps=2 -falign-functions=2
	LD_OPTS =
endif

CFLAGS  = $(CC_OPTS) $(DEFINES) $(INCLUDES)
LDFLAGS = $(LD_OPTS) $(LIBPATHS) $(LIBS)

$(LIB_NAME).a: $(OBJS)
	$(LD) rc $@ $^ $(LDFLAGS)
	@ranlib -v $@
	
%.o: %.c
	$(CC) -o $@ $(CFLAGS) $<
	
clean:
	@rm -f $(OBJS)
	@rm -f $(LIB_NAME).a
