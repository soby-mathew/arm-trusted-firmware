/*
 * Copyright (c) 2013-2017, ARM Limited and Contributors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * Neither the name of ARM nor the names of its contributors may be used
 * to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <bakery_lock.h>
#include <mmio.h>
#include <plat_arm.h>
#include <platform.h>
#include "../../fvp_def.h"
#include "../../fvp_private.h"
#include "fvp_pwrc.h"

/*
 * Global variable to store the virtual address for accessing the power
 * controller registers.
 */
uintptr_t virt_pwrc_base;

/*
 * TODO: Someday there will be a generic power controller api. At the moment
 * each platform has its own pwrc so just exporting functions is fine.
 */
ARM_INSTANTIATE_LOCK

unsigned int fvp_pwrc_get_cpu_wkr(u_register_t mpidr)
{
	return PSYSR_WK(fvp_pwrc_read_psysr(mpidr));
}

unsigned int fvp_pwrc_read_psysr(u_register_t mpidr)
{
	unsigned int rc;
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PSYSR_OFF, (unsigned int) mpidr);
	rc = mmio_read_32(virt_pwrc_base + PSYSR_OFF);
	arm_lock_release();
	return rc;
}

void fvp_pwrc_write_pponr(u_register_t mpidr)
{
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PPONR_OFF, (unsigned int) mpidr);
	arm_lock_release();
}

void fvp_pwrc_write_ppoffr(u_register_t mpidr)
{
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PPOFFR_OFF, (unsigned int) mpidr);
	arm_lock_release();
}

void fvp_pwrc_set_wen(u_register_t mpidr)
{
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PWKUPR_OFF,
		      (unsigned int) (PWKUPR_WEN | mpidr));
	arm_lock_release();
}

void fvp_pwrc_clr_wen(u_register_t mpidr)
{
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PWKUPR_OFF,
		      (unsigned int) mpidr);
	arm_lock_release();
}

void fvp_pwrc_write_pcoffr(u_register_t mpidr)
{
	arm_lock_get();
	mmio_write_32(virt_pwrc_base + PCOFFR_OFF, (unsigned int) mpidr);
	arm_lock_release();
}

/*
 * Initialize the lock and resolve the virtual address of the power
 * controller register base.
 */
void plat_arm_pwrc_setup(void)
{
	arm_lock_init();
	virt_pwrc_base = plat_phys_to_virt(PWRC_BASE);

	/*
	 * Flush the `virt_pwrc_base` variable to enable the secondaries to see
	 * the update on power up.
	 */
	flush_dcache_range((uintptr_t)&virt_pwrc_base, sizeof(virt_pwrc_base));
}



