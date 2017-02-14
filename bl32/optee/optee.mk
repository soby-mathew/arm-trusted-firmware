#
# Copyright (c) 2017, ARM Limited and Contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

ifneq (${ARCH}, aarch32)
	$(error OP-TEE as secure monitor is only supported on AArch32 platforms)
endif

# Additional CFLAGS required to be compatible with OP-TEE build system
TF_CFLAGS_aarch32 += -fno-common -fno-short-enums -mno-apcs-float -mfloat-abi=soft

USE_COHERENT_MEM	:=	0
PLAT_BL32_COMMON_SOURCES	+=	plat/common/plat_psci_common.c

include lib/psci/psci_lib.mk

BL32_SOURCES		+=	bl32/optee/optee_common.c			\
				bl32/optee/optee_psci_helpers.S

ifeq (${ENABLE_PMF}, 1)
BL32_SOURCES		+=	lib/pmf/pmf_main.c
endif

BUILD_BL32_LIB		:=	1

EXPORT_FILES		:=	bl32/optee/psci_optee_lib.h			\
				include/common/ep_info.h			\
				include/common/param_header.h			\
				include/lib/bakery_lock.h			\
				include/lib/cassert.h				\
				include/lib/el3_runtime/aarch32/context.h	\
				include/lib/el3_runtime/context_mgmt.h		\
				include/lib/psci/psci_lib.h			\
				include/lib/smcc.h

OPTEE_PLAT_MAKEFILE := $(wildcard bl32/optee/${PLAT}/optee-${PLAT}.mk)
ifeq (,${OPTEE_PLAT_MAKEFILE})
  $(error Building the PSCI OP-TEE library is not supported on platform ${PLAT})
endif

include ${OPTEE_PLAT_MAKEFILE}
