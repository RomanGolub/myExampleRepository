.386
.model flat,stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\fpu.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\fpu.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib	
includelib \masm32\lib\msvcrt.lib

.data
	a1 dd 3.14, -8.5, 5.86, 12.9, 8.22
	b1 dd 0.5, 9.77, 4.47, 15.23, 10.14
	c1 dd 24.5, 31.28, 48.13, 100.13, 9.35
	d1 dd 2.1, 3.33, 2.99, 7.94, 9.01
	firhalfchislbuff dd ?
	sechalfchislbuff dd ?
	znambuff dq ?
	a1buff dd ?
	b1buff dd ?
	rez1 dq ?, ?, ?, ?, ?
	rezbuff db 15 dup(?)
	rezhead db "Результат:",0
	con_53 dd 53
	con_2 dd 2
	con_4 dd 4
	buffdd dd ?
	buffdq dq ?
	public a1buff, b1buff, con_4
	ZNAM proto
	;(53 - sin(a/d) - 2c)/(a/4 - b)
	.const
	NULL equ 0
	
	count MACRO a1, b1, c1, d1, firhalfchislchisl, sechalfchislchisl, znam, rez1, numb
	; counting first half of chisl:***********************************
	mov eax, con_53
	mov ebx, con_2
	mov ecx, c1[4*numb]
	finit
	call firHalfCHISL
	mov firhalfchislbuff, edx
	;*****************************************************************
	
	
	; counting second half of chisl:$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	push a1[4*numb]
	push d1[4*numb]
	call secHalfCHISL
	mov sechalfchislbuff, edx
	;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	
	
	;counting znam:##################################################
	mov eax, a1[4*numb]
	mov ebx, b1[4*numb]
	mov a1buff, eax
	mov b1buff, ebx
	call ZNAM
	fstp znambuff
	;#################################################################
	
	
	;counting result:!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	fld sechalfchislbuff; st(0) = sechalfchisl[8*numb]
	fld firhalfchislbuff; st(0) = firhalfchisl[8*numb], st(1) = sechalfchisl[8*numb]
	fsub st(0), st(1); st(0) = firhalfchisl[8*numb] - sechalfchisl[8*numb], st(1) = sechalfchisl[8*numb]
	fld znambuff; st(0) = znam, st(1) = firhalfchisl[8*numb] - sechalfchisl[8*numb], st(2) = sechalfchisl[8*numb]
	fdiv st(1), st(0); st(0) = znam, st(1) = result, st(2) = sechalfchisl[8*numb]
	fstp buffdd; st(0) = result, st(1) = sechalfchisl[8*numb]
	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

		INVOKE FpuFLtoA,NULL, 10, offset rezbuff, SRC1_FPU or SRC2_DIMM
		INVOKE MessageBox, NULL, offset rezbuff, offset rezhead, NULL 
	
	ENDM
	
		
	zikl MACRO
	
	counting:
	count  a1, b1, c1, d1, firhalfchislchisl, sechalfchislchisl, znam, rez1, edi
	inc edi
	cmp edi, 5
	jne counting
	
	ENDM
	.code 
	main:
	mov edi, 0
	
	zikl
	invoke ExitProcess, 0
firHalfCHISL proc
	local con53, con2, c_1
	mov con53, eax
	mov con2, ebx
	mov c_1, ecx
	fild con53; st(0)=53
	fild con2; st(0)=2 ; st(1)=53
	fld c_1; st(0)=c1 ; st(1)=2 ; st(2)=53
	fmul st(1), st(0); st(0)=c1 ; st(1)=2*c1 ; st(2)=2 ; st(3)=53
	fstp buffdd; st(0)=2*c1 ; st(2)=53
	fsub st(1), st(0); st(0)=2*c1 ; st(1)=53-2*c1
	fstp buffdd; st(0)=53-2*c1
	fstp c_1
	mov edx, c_1
	ret
firHalfCHISL endp


secHalfCHISL proc
	push ebp
	mov ebp, esp 
	mov eax, [ebp+12]
	mov ebx, [ebp+8]
	pop ebp
	mov buffdd, eax
	fld buffdd; st(0)=a1	
	mov buffdd, ebx
	fld buffdd; st(0)=d1 ; st(1)=a1
	fdiv st(1), st(0); st(0)=d1 ; st(1)=a1/d1
	fstp buffdd; st(0)=a1/d1
	fsin; st(0)=sin(a1/d1)
	fstp buffdd
	mov edx, buffdd
	ret 8
secHalfCHISL endp
	end main	
