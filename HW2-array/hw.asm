; Разработать программу, которая вводит одномерный массив A[N], формирует из элементов массива A новый массив B по правилам, 
; указанным в таблице, и выводит его. Память под массивы может выделяться как статически, так и динамически по выбору разработчика.

; Разбить решение задачи на функции следующим образом:
; - Ввод и вывод массивов оформить как подпрограммы
; - Выполнение задания по варианту оформить как процедуру
; - Организовать вывод как исходного, так и сформированного массивов

; Указанные процедуры могут использовать данные напрямую (имитация процедур без параметров). 
; Имитация работы с параметрами также допустима.

; Вариант 1: Массив В из положительных элементов А

format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable     ; Секция данных
        ru db 'Russian', 0

        strVecSize     db 'Введите размер массива: ', 0
        strIncorSize   db 'Неверный размер массива = %d', 10, 0
        strVecElemI    db 'Введите [%d] элемент массива: ', 0          ; Тексты для вывода в консоль
        strScanInt     db '%d', 0
        strResult      db 10,'Массив положительных чисел:', 10, 0
        strVecElemOut  db '[%d] = %d', 10, 0

        i            dd ?
        j            dd 0
        tmp          dd ?              ; Итераторы и временные переменные
        tmpStack     dd ?

        vec          rd 100            ; Исходный вектор
        vec_size     dd 0

        vecRes       rd 100            ; Вектор-результат
        vecRes_size  dd 0

;--------------------------------------------------------------------------
section '.code' code readable executable   ; Секция исполняемого кода

start:
        cinvoke setlocale, 0, ru       ; Устанавливаем русскую локаль

        call VectorInput               ; Считываем вектор
        call FilterVector              ; Фильтруем массив
        call VectorOut                 ; Выводим резултат

finish:
        call [getch]

        push 0                        ; Завершение программы
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]                 ; Просим ввести длину массива
        add esp, 4

        push vec_size
        push strScanInt               ; Считываем длину массива
        call [scanf]
        add esp, 8

        mov eax, [vec_size]           ; Проверяем корректность длины массива
        cmp eax, 0                    ; Если положительное число, считываем элементы
        jg  getVector

        push vec_size
        push strIncorSize
        call [printf]                 ; Если <=0, выводим сообщение и завершаем программу
        push 0
        call [ExitProcess]

getVector:
        xor ecx, ecx             ; ecx = 0        Обнуляем регистр-итератор
        mov ebx, vec             ; ebx = &vec     Кладем ссылку на массив в регистр

getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size]
        jge endInputVector       ; Завершаем ввод, если индекс вышел за пределы

        mov [i], ecx
        push ecx
        push strVecElemI         ; Просим ввести итый элемент
        call [printf]
        add esp, 8

        push ebx
        push strScanInt          ; Считываем итый элемент
        call [scanf]
        add esp, 8

        mov ecx, [i]             ; Увеличиваем значение итератора
        inc ecx
        mov ebx, [tmp]           ; Кладем значение в cтек
        add ebx, 4               ; Перемещаем указатель стека
        jmp getVecLoop           ; Идем в начало цикла

endInputVector:
        ret                      ; Выходим из цикла
;--------------------------------------------------------------------------
FilterVector:
        xor ecx, ecx            ; ecx = 0         Обнуляем регистр-итератор для исходного массива
        mov ebx, vec            ; ebx = &vec      Кладем ссылку на исходный массив в регистр

        mov edx, vecRes         ; edx = &vecRes   Кладем ссылку на результирующий массив в регистр

        mov [i], ecx
FilterVecLoop:
        mov ecx, [i]
        cmp ecx, [vec_size]
        je endFilterVector      ; Если дошли до конца исходного массива - завершаем цикл

        cmp dword [ebx], 0      ; Сравниваем элемент с нулем
        jg  addToRes            ; Если элемент положительный, добавляем в новый массив

        inc [i]                 ; Увеличиваем итератор
        add ebx, 4
        jmp FilterVecLoop       ; Возвращаемся в начало цикла

addToRes:
        mov eax, [ebx]          ; Кладем значение в результирующий массив
        mov [edx], eax

        add edx, 4              ; Перемещаем указатели на элемент массиыв
        add ebx, 4

        inc [i]                 ; Увеличиваем итераторы
        inc [j]

        jmp FilterVecLoop       ; Возвращаемся в начало цикла

endFilterVector:
        mov eax, [j]            ; Запоминаем размер
        mov [vecRes_size], eax
        ret                     ; Выходим из процедуры
;--------------------------------------------------------------------------
VectorOut:
        push strResult
        call [printf]           ; Выводим заголовок
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0          Обнуляем регистр-итератор для результирующего массива
        mov ebx, vecRes         ; ebx = &vecRes    Перемещаем указатель на результирующий массив в регистр
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [vecRes_size]  ; Выходим мз цикла, когда дошли до конца массива
        je endOutputVector

        mov [i], ecx

        push dword [ebx]
        push ecx
        push strVecElemOut      ; Выводим элемент
        call [printf]

        mov ecx, [i]            ; Увеличиваем значение итератора
        inc ecx
        mov ebx, [tmp]          ; Двигаем указатель на элемент массива
        add ebx, 4
        jmp putVecLoop          ; Переходим в начало цикла

endOutputVector:
        mov esp, [tmpStack]
        ret                     ; Выходим из процедуры
;--------------------------------------------------------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\                               ; Подключение нужных библиотек
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           setlocale, 'setlocale',\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'
