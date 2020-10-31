; Разработать программу вычисления даты
; православной Пасхалии для заданного года
; Абу Аль Лабан Н. БПИ 198
format PE console            ; Формат выходного файла - консоль
entry start                  ; Точка входа

include 'win32ax.inc'        ; Подключаемые модули

section '.data' data readable writable       ; Секция данных
        ru db 'Russian', 0

        strYear        db 'Введите год после 1900: ', 13, 10, 0
        strIncorrect   db 'Пожалуйста, введите число большее, чем 1900.',13, 10, 0
        strApril       db 'Пасха празднуется %d апреля', 13, 10, 0                   ; Тексты для вывода в консоль
        strMay         db 'Пасха празднуется %d мая'', 13, 10, 0

        string  db '%d', 0         ; Формат ввода

        year    dw ?               ; Введенный в консоль год

        coefA   dw ?
        coefB   dw ?               ; Коэффициенты для расчета даты
        coefC   dw ?

        result    db 256 dup(?)
        path      db 256 dup("?")
        opsymbol  dw ?

; ---------------------------------------------------------------------
section '.code' code readable executable      ; Секция кода
        start:
                cinvoke setlocale, 0, ru      ; Устанавливаем русскую локаль

                push strYear
                call [printf]                 ; Запрашиваем ввод года

                push year
                push string                   ; Считываем год
                call [scanf]

                call pashalia

; ---------------------------------------------------------------------
        proc pashalia
                mov ax, word[year]

                cmp ax, 1900
                jl incorrect                  ; Проверяем корректность ввода

                mov bl, 19
                div bl
                mov al, ah
                mov bl, 19
                mul bl
                                              ; Считаем коэффициент A
                add ax, 15                    ; A = (19 * (Y mod 19) + 15) mod 30
                mov bl, 30
                div bl
                mov al, ah
                cbw

                mov word[coefA], ax

                mov ax, word[year]
                mov dx, 0
                mov bx, 4
                div bx                        ; Считаем коэффициент B
                                              ; B = 2 * (Y mod 4)
                mov ax, dx
                mov bx, 2
                mul bx

                mov word[coefB], ax

                mov ax, word[year]
                mov dx, 0
                mov bx, 7
                div bx
                                              ; Считаем коэффициент C
                mov ax, dx                    ; C = 4 * (Y mod 7)
                mov bx, 4
                mul bx
                mov word[coefC], ax

                mov ax, word[coefA]
                mov bl, 6                     ; Кладем А в регистр и умножаем на 6
                mul bl

                add ax, 6
                add ax, word[coefB]           ; Прибавляем 6, B и C
                add ax, word[coefC]

                mov bl, 7
                div bl                        ; Берем остаток от деления на 7

                mov al, ah
                cbw

                add ax, word[coefA]           ; Прибавляем A
                cwde                          ; Получается A + ((B + C + 6A + 6) mod 7)

                cmp eax, 26
                jg may                        ; В зависимости от значения переходим
                jmp april                     ; В нужную метку

; ---------------------------------------------------------------------
        april:
                add eax, 4                    ; Прибавляем 4 и получаем дату в апреле
                push eax
                push strApril                 ; Выводим ответ
                call [printf]
                add esp,8

                jmp finish

; ---------------------------------------------------------------------
        may:
                sub eax, 26                   ; Отнимаем 26 и получаем дату в мае
                push eax
                push strMay                   ; Выводим ответ
                call [printf]
                add esp,8

                jmp finish

; ---------------------------------------------------------------------
        incorrect:
                push strIncorrect
                call [printf]
                add esp,4                     ; Выводим сообщение об ошибке

                push 0
                call [getch]
                call [ExitProcess]

; ---------------------------------------------------------------------
        finish:
                push 0                        ; Завершение программы
                call [getch]

                call [ExitProcess]

        ret
        endp

; ---------------------------------------------------------------------
section '.idata' data readable import          ; Секция импортируемых данных
        library kernel, 'kernel32.dll', \
                msvcrt,   'msvcrt.dll'
        import kernel,\
               ExitProcess, 'ExitProcess'
        import msvcrt,\
               setlocale, 'setlocale',\
               printf, 'printf',\
               getch,'_getch',\
               scanf, 'scanf'
