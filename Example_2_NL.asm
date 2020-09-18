format PE CONSOLE
include 'win32ax.inc'

SEEK_SET equ 0
SEEK_CUR equ 1
SEEK_END equ 2
NULL     equ 0
EOF      equ -1

section '.data' data readable writeable

argc    dd ?
argv    dd ?
env     dd ?
fp      dd ?
flength dd ?
fbuf    dd ?
msg     db  '%s %s%s',0
errmsg  db "Error! File was not specified.",0

section '.code' code readable executable

entry start

start:

 cinvoke __getmainargs,argc,argv,env,0
 cmp [argc],2
 jne .err
 mov esi,[argv]

 cinvoke fopen,dword [esi+4],'rb'
 test eax,eax
 jz .err
 mov [fp],eax

 cinvoke fseek,[fp],0,SEEK_END
 .if eax <> 0
  jmp .err
 .endif

 cinvoke ftell,[fp]
 test eax,eax
 jz .err
 mov [flength],eax

 inc eax
 cinvoke malloc,eax
 test eax,eax
 jz .err
 mov [fbuf],eax

 cinvoke fseek,[fp],0,SEEK_SET
 test eax,eax
 jnz .err

 cinvoke fread,[fbuf],1,[flength],[fp]
 cmp eax,[flength]
 jne .err

 mov eax,[fbuf]
 add eax,[flength]
 mov byte [eax],0

 cinvoke puts,[fbuf]
 cinvoke printf,'File length = %u%s',[flength],<13,10,0>

 cinvoke fclose,[fp]
 test eax,eax
 jnz .err

 cinvoke free,[fbuf]

.finish:
 cinvoke puts,'Press any key...'
 cinvoke _getch
 invoke ExitProcess,0

.err:
 cinvoke puts,errmsg
 jmp .finish

section '.idata' import data readable writeable

library kernel,'kernel32.dll',\
msvcrt,'msvcrt.dll',\
user32,'user32.dll'

import kernel,\
ExitProcess,'ExitProcess',\
GetCommandLineA,'GetCommandLineA',\
AllocConsole,'AllocConsole',\
FreeConsole,'FreeConsole',\
SetConsoleOutputCP,'SetConsoleOutputCP',\
SetConsoleCP,'SetConsoleCP'

import msvcrt,\
__getmainargs,'__getmainargs',\
fopen,'fopen',\
fseek,'fseek',\
ftell,'ftell',\
malloc,'malloc',\
free,'free',\
fread,'fread',\
fclose,'fclose',\
printf,'printf',\
_getch,'_getch',\
puts,'puts'

import user32,\
CharToOemA,'CharToOemA'