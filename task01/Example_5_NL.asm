format PE console

entry start

include 'win32a.inc'

section '.code' code executable
    start:
        cinvoke setlocale, 0, ru
        ; mov ecx, 110b
        ; shl ecx, 1
         push A
         push space
         call [scanf]

         mov ecx, [A]
         shl ecx, 1
         push ecx
         push resStr
         call [printf]

         mov ebx, [A]
         rcr ebx, 1
         push ebx
         push resStr
         call [printf]
         push infoStr
         call [printf]
         push B
         push space
         call [scanf]
         push newStr
         call [printf]
       mov eax, [A]
        and eax, [B]
        push eax
         push resStr
         call [printf]



         call [getch]
         push NULL
         call [ExitProcess]

section '.data' data readable writable
    resStr db 'Result: %d',13,10, 0
    infoStr db '¬ведите новое число :',13,10,0
      newStr db '–езультат A and B: ',13,10,0
   ru db 'Russian', 0
    space db ' %d', 0
    A dd ?
    B dd ?
    NULL = 0

section '.idata' import data readable
    library kernel, 'kernel32.dll', \
             msvcrt,   'msvcrt.dll'
    import kernel,\
           ExitProcess, 'ExitProcess'
    import msvcrt,\
           printf, 'printf',\
           getch,'_getch',\
           scanf, 'scanf',\
           setlocale, 'setlocale'