/*
 * Copyright (c) 2017, ARM Limited and Contributors. All rights reserved.
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

#include <asm_macros.S>

/* Override PSCI helpers for OP-TEE */

/* ------------------------------------------------------
 * void do_unused_stack_invalidate(uinptptr_t stack_base)
 * Invalidate the remainder of unused stack as the stack
 * could have been deeper previously and dirty line
 * evictions from there could corrupt the stack later on.
 * ------------------------------------------------------
 */
	.globl	do_unused_stack_invalidate
func do_unused_stack_invalidate
	/* ---------------------------------------------
	 * Calculate and store the size of the unused
	 * stack memory in r1. Calculate and store the
	 * stack top address in r0.
	 * ---------------------------------------------
	 */
	ldr	r1, =stack_tmp_stride
	ldr	r4, [r1]
	sub	r0, r0, r4
	sub	r1, sp, r0
	b	inv_dcache_range
endfunc do_unused_stack_invalidate


/* -----------------------------------------------------
 * uintptr_t plat_get_my_stack (u_register_t mpidr)
 *
 * For a given CPU, this function returns the stack
 * pointer for a stack allocated.
 *
 * This function is invoked by PSCI library with OP-TEE
 * TMP stack initialized. So it is safe to use the
 * stack. The OP-TEE stack_tmp layout is as shown below:
 *
 *
 *                    ^  +----------+ stack_tmp
 *                    |  |          |
 *                    |  |          |
 *                    |  |          |
 *  stack_tmp_stride  |  |          |
 *                    |  +----------+ CPU 0 stack base
 *                    |  | TMP_OFFS |
 *                    v  +----------+
 *                       |          |
 *                       :          :
 *
 * We need to do stack maintenance on the full stack
 * including TMP_OFFS. Else Bad things will happen.
 * -----------------------------------------------------
 */
	.globl	plat_get_my_stack
func plat_get_my_stack
	push	{lr}
	bl	get_core_pos
	add	r0, r0, #1
	ldr	r2, =stack_tmp_stride
	ldr	r1, [r2]
	mul	r2, r0, r1
	ldr	r0, =stack_tmp
	add	r0, r0, r2
	pop	{pc}
endfunc plat_get_my_stack

/* -----------------------------------------------------
 * unsigned int plat_my_core_pos(void)
 * Invoke the OP-TEE `get_core_pos` function.
 * -----------------------------------------------------
 */
	.globl	plat_my_core_pos
func plat_my_core_pos
	b	get_core_pos
endfunc plat_my_core_pos

/* -----------------------------------------------------
 *  unsigned int plat_arm_calc_core_pos(uint64_t mpidr)
 *  Invoke the OP-TEE `get_core_pos_by_mpidr` function.
 * -----------------------------------------------------
 */
	.globl	plat_arm_calc_core_pos
func plat_arm_calc_core_pos
	b	get_core_pos_by_mpidr
endfunc plat_arm_calc_core_pos


/* ------------------------------------------------------
 * The crash console initialization routine for OP-TEE
 * Nothing to be done here as we report via OP-TEE
 * console driver during crash and its initialization
 * is taken care of by OP-TEE.
 * ------------------------------------------------------
 */
	.globl plat_crash_console_init
func plat_crash_console_init
	bx	lr
endfunc plat_crash_console_init

/* ------------------------------------------------------
 * int plat_crash_console_putc(int c)
 * Since this functon will only be invoked after the
 * C environment has been initialized when integrated
 * with OP-TEE, we call into the OP-TEE C console driver.
 * The caller of this function does not follow AAPCS and
 * hence the registers r3 and lr are saved and restored.
 * Clobber list : r0 - r2
 * ------------------------------------------------------
 */
	.globl plat_crash_console_putc
func plat_crash_console_putc
	push	{r3, lr}
	bl	console_putc
	pop	{r3, pc}
endfunc plat_crash_console_putc
