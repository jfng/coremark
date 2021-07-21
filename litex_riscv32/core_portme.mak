# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original Author: Shay Gal-on

#File : core_portme.mak

PORT_DIR = litex_riscv32

OPATH = $(BUILD_DIR)
MKDIR = mkdir -p
SEPARATE_COMPILE = 1

TRIPLE   = riscv64-unknown-elf
CC       = $(TRIPLE)-gcc
CPP      = $(TRIPLE)-cpp
AS       = $(CC)
LD       = $(CC)
OBJCOPY  = $(TRIPLE)-objcopy

MARCH = rv32i
ifeq ($(MULDIV),yes)
MARCH := $(MARCH)m
endif
ifeq ($(COMPRESSED),yes)
MARCH := $(MARCH)ac
endif

PORT_CFLAGS = -O3
LFLAGS_END  =
FLAGS_STR   = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"

CPPFLAGS = -I$(PORT_DIR) -I. -I$(LITEX_GEN_DIR) -I$(LITEX_CPU_DIR) -I$(LITEX_INC_DIR) \
	   -DFLAGS_STR=\"$(FLAGS_STR)\" \
	   -DHAS_FLOAT=0 -DCORE_DEBUG=0
ASFLAGS  = -march=$(MARCH) -mabi=ilp32
CFLAGS   = $(PORT_CFLAGS) $(XCFLAGS) -march=$(MARCH) -mabi=ilp32 \
	   -ffreestanding
LFLAGS   = -march=$(MARCH) -mabi=ilp32 -nostartfiles \
	   -Wl,-Bstatic,-T,$(OPATH)link.ld,-Map,coremark.map,--print-memory-usage

PORT_SRCS = $(PORT_DIR)/start.S \
	    $(PORT_DIR)/core_portme.c \
	    $(PORT_DIR)/ee_printf.c \

PORT_OBJS := $(PORT_SRCS:.c=.o)
PORT_OBJS := $(PORT_OBJS:.S=.o)

LOAD = echo "Please set LOAD to the process of loading the executable to the flash"
RUN  = echo "Please set RUN to the process of running the executable (e.g. via jtag, or board reset)"

OFLAG = -o
OEXT  = .o
EXE   = .elf

$(OPATH)%.o : %.S
	$(COMPILE.S) $< -o $@

$(OPATH)%.o : %.c
	$(COMPILE.c) $< -o $@

$(OPATH)%.o : %.c
	$(COMPILE.c) $< -o $@

$(OPATH)link.ld : $(PORT_DIR)/link.ld.S
	$(CPP) $(CPPFLAGS) -P -o $@ $<

link: $(OPATH)link.ld

$(OPATH)coremark.bin: link
	$(OBJCOPY) -O binary $(OPATH)coremark.elf $@

.PHONY : port_prebuild port_postbuild port_prerun port_postrun port_preload port_postload
port_pre% port_post%:

port_postbuild: $(OPATH)coremark.bin

PORT_CLEAN = $(OBJS) $(OPATH)coremark.bin $(OPATH)link.ld
