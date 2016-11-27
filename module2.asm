.386 
.model flat, stdcall 
public ZNAM 
extern a1buff:DWORD, b1buff:DWORD, con_4:DWORD 
.code 
ZNAM proc 
fld a1buff; st(0)=a1 
fild con_4; st(0)=con_4 ; st(1)=a1 
fdiv st(1), st(0); st(0)=con_4 ; st(1)=a1/4 
fstp a1buff; st(0)=a1/4 
fld b1buff; st(0)=b1 ; st(1)=a1/4 
fsub st(1), st(0); st(0)=b1 ; st(1)=a1/4 - b1 
fstp a1buff; st(0)=a1/4 - b1
ret 
ZNAM endp 
end