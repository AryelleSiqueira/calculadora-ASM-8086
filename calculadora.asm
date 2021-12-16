; Calculadora que realiza as operações básicas: soma, subtração, multiplicação e divisão

; Autores: Aryelle Gomes Siqueira e Luiz Gabriel Bandeira e Ribeiro

segment code
..start:
    mov     ax, dados
    mov     ds, ax
    mov     ax, stack
    mov     ss, ax
    mov     sp, stacktop

; ##################### CÓDIGO #####################

    ; imprime mensagem de inicio
    mov     dx, msg_ini
    mov     ah, 9
    int     21h

    ; loop de leitura
    leitura:
        ; chama função que lê operador
        call    le_operador

        ; verifica se foi inserido 'q' (quit) para sair
        mov     bx, operador
        cmp     byte [bx], 'q'
        je      quit
        
        ; lê operandos (N1 e N2)
        call    le_N1
        call    le_N2

        ; caso op = '+'
        case_1:
            cmp     byte [bx], '+'
            jne     case_2
            call    soma
            jmp     leitura
        
        ; caso op = '-'
        case_2:
            cmp     byte [bx], '-'
            jne     case_3
            call    subtracao
            jmp     leitura

        ; caso op = '*'
        case_3:
            cmp     byte [bx], '*'
            jne     case_4
            call    multiplicao
            jmp     leitura

        ; caso op = 'd'
        case_4:
            cmp     byte [bx], 'd'
            jne     case_err
            call    divisao
            jmp     leitura

        ; caso op inválido
        case_err:
            mov     dx, msg_erro
            mov     ah, 9
            int     21h
            jmp     leitura

    quit:
    ; imprime mensagem de fim
    mov     dx, msg_fim
    mov     ah, 9
    int     21h

    ; termina execução do programa
    mov     ah, 4CH 
    int     21h


;##################### FUNÇÕES #####################
le_operador:
    ; salva contexto
    push    ax
    push    bx
    push    dx

    ; imprime mensagem
    mov     dx, msg_op
    mov     ah, 9
    int     21h

    ; le caractere
    mov     ah, 1
    int     21h

    ; salva na memória
    mov     bx, operador
    mov     [bx], al

    ; restaura contexto e retorna
    pop     dx
    pop     bx
    pop     ax
    ret


le_N1:
    ; salva contexto
    push    ax
    push    bx
    push    dx
    
    ; imprime mensagem
    mov     dx,msg_N1
    mov     ah,9
    int     21h
    
    ; lê entrada e converte 
    call    le_entrada
    call    ascii_2_decimal ; converte e salva na variável 'acumulador'

    ; lê da memoria o valor lido/convertido e salva em 'N1'
    mov     bx, [acumulador]
    mov     [N1], bx

    ; restaura contexto e retorna
    pop     dx
    pop     bx
    pop     ax
    ret


le_N2:
    ; salva contexto
    push    ax
    push    bx
    push    dx

    ; imprime mensagem
    mov     dx, msg_N2
    mov     ah,9
    int     21h
    
    ; lê entrada e converte 
    call    le_entrada
    call    ascii_2_decimal ; converte e salva na variável 'acumulador'

    ; lê da memoria o valor lido/convertido e salva em 'N2'
    mov     bx, [acumulador]
    mov     [N2], bx

    ; restaura contexto
    pop     dx
    pop     bx
    pop     ax
    ret


le_entrada:
    ; salva contexto
    push    ax
    push    dx

    ; lê N caracteres da entrada, onde N máximo é definido em [entrada]
    ; salva qtd de caracteres lidos em [entrada + 1] e string em [entrada + 2]
    mov     dx, entrada 
    mov     ah, 0ah
    int     21h

    ; restaura contexto
    pop     dx
    pop     ax
    ret


ascii_2_decimal:
    ; salva contexto
    pushf
    pusha

    ; inicia acumulador com 0
    mov     word [acumulador], 0 

    ; faz bx apontar para primeira posição de num_ascii e inicia registrador CX com qtd digitos
    mov     bx, num_ascii 
    and     cx, 0
    mov     cl, [n_caracteres] 
   
    mov     di, cx
    dec     di      ; faz di = cx-1 (qtd de caracteres digitados menos 1)
    
    mov     si, 1   ; inicializa multiplicador com 1
    
    ; verifica se número é negativo (1° char == '-')
    and     ax, 0
    mov     al, [bx] 
    cmp     al, '-' 
    jne     loop_converte   ; pula para o loop no caso de ser >= 0
    dec     cx              ; decrementa qtd de caracteres se 1° char = '-' 

    ; loop que pega digito a digito (em ascii), converte e acumula (sem considerar sinal)
    loop_converte:
        and     ax, 0
        mov     al, [bx + di]       ; pega caracteres de num_ascii de trás pra frente
        sub     al, 30h             ; converte para valor correspondente entre 0-9
        mul     si                  ; multiplica por si (10x maior a cada iteração)
        add     [acumulador], ax    ; acumula resultado (na memória)
       
        ; faz multiplicador si = si * 10 
        mov     ax, si
        mov     si, 10
        mul     si
        mov     si, ax

        ; decrementa di para acessar posição anterior de num_ascii na próxima iteração
        dec     di      ; di = di - 1
        loop    loop_converte

    ; finaliza função se a entrada foi um valor positivo, caso contrário faz número ser negativo
    jne     retorna
    neg     word [acumulador]

    ; restaura contexto e retorna
    retorna:
    popa
    popf
    ret


soma:
    ; salva contexto
    push    ax
    push    dx

    ; realiza soma (N1 + N2)
    mov     ax, [N1]
    add     ax, [N2]
    mov     [resultado], ax

    ; imprime string 'Resultado = '
    mov 	dx, msg_resultado
    mov 	ah, 9h
    int 	21h

    ; imprime resultado da soma
    call    imprime_resultado

    ; restaura contexto e retorna
    pop     dx
    pop     ax
    ret


subtracao:
    ; salva contexto
    push    ax
    push    dx

    ; realiza subtração (N1 - N2)
    mov     ax, [N1]
    sub     ax, [N2]
    mov     [resultado], ax

    ; imprime string 'Resultado = '
    mov 	dx, msg_resultado
    mov 	ah, 9h
    int 	21h

    ; imprime resultado da subtração (= N1 - N2)
    call    imprime_resultado

    ; restaura contexto e retorna
    pop     dx
    pop     ax
    ret


multiplicao:
    ; salva contexto
    pushf
    push    ax
    push    cx
    push    dx

    mov     ax, 1           ; inicia sinal do resultado como positivo
    
    ; lê operandos e, caso sejam negativos, troca por seus respectivos módulos
    n1:
    cmp     word [N1], 0    ; verifica se N1 é negativo
    jg      n2              ; caso N1 positivo, parte para a leitura de N2 
    neg     word [N1]       ; nega, caso negativo (torna positivo)
    neg     ax              ; inverte "sinal" do resultado
    
    n2:
    mov     dx, [N2]        ; lê N2 da memória
    cmp     dx, 0           ; verifica se N2 é negativo
    jg      multi           ; parte para a multiplicação, caso N2 positivo
    neg     dx              ; nega, caso negativo (torna positivo)
    neg     ax              ; inverte "sinal" do resultado

    ; realiza multiplicação dos módulos de N1 e N2
    multi:
    mov     cx, ax          ; salva sinal do resultado em cx
    mov     ax, [N1]        ; lê N1 da memória
    imul    dx              ; multiplica ax por dx (= |N1| * |N2|)

    ; verifica se resultado extrapola a word (16 bits)
    cmp     dx, 0           ; se (dx != 0) => resultado não coube em ax 
    jne     imprime_erro
    
    ; multiplica (módulo do) resultado salvo ax por sinal e salva na memória
    imul    cx         
    mov     [resultado], ax

    ; imprime string 'Resultado = '
    mov 	dx, msg_resultado
    mov 	ah, 9h
    int 	21h

    ; imprime o resultado da multiplicação
    call    imprime_resultado
    jmp     termina_mult

    ; imprime mensagem de erro caso resultado extrapole os 16 bits
    imprime_erro:
    mov 	dx, msg_overflow
    mov 	ah, 9h
    int 	21h

    ; recupera contexto e retorna
    termina_mult: 
    pop     dx
    pop     cx
    pop     ax
    popf
    ret
    

divisao:
    ; salva contexto
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    
    ; lê operandos na memória
    mov     ax, [N1]
    mov     bx, [N2]

    ; verifica se N2 é diferente de zero
    cmp     bx, 0
    je      div_zero

    ; verifica se N1 é negativo e modifica dx de acordo
    cmp     ax, 0
    jl      N1_neg
    and     dx, 0               ; caso N1 positivo, faz dx=0
    jmp     divide
    N1_neg: 
    or      dx, 0xFFFF          ; caso N1 negativo, faz dx=0xFFFF

    ; realiza divisão (N1 / N2)
    divide:
    idiv    bx                  ; divide (dx ax) por bx
    mov     [resultado], ax     ; salva resultado na memória
    mov     cx, dx              ; salva resto da divisão em cx

    ; imprime string 'Resultado = '
    mov 	dx, msg_resultado
    mov 	ah, 9h
    int 	21h

    ; imprime o resultado da divisão
    call    imprime_resultado

    ; imprime string 'Resto = '
    mov 	dx, msg_resto
    mov 	ah, 9h
    int 	21h

    ; imprime o resto da divisão
    mov     [resultado], cx
    call    imprime_resultado
    
    jmp     fim_fdiv

    ; imprime mensagem de erro se N2 = 0 (divisão por 0)
    div_zero:
    mov     dx, msg_div_zero
    mov 	ah, 9h
    int 	21h

    ; recupera contexto e retorna
    fim_fdiv:
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
    ret


; Funções responsáveis por converter resultado calculado e imprimi-lo
imprime_resultado:
    ; Salva contexto
    pushf
    pusha
    
    ; confere se valor a ser convertido (resultado) é negativo
    cmp     word [resultado], 0
    jl      negativo
    jmp     converte_result

    ; caso [resultado] < 0, troca por seu módulo na memória e imprime sinal negativo
    negativo:
    neg     word [resultado]    ; nega resultado tornando-o positivo 
    mov 	dx, sinal_negativo  ; imprime sinal negativo
    mov 	ah, 9h
    int 	21h

    converte_result:
    mov     di, saida
    mov     ax, [resultado]
    call    bin_2_ascii         ; converte valor em ax, salvando no offset apontado por di

    ; imprime resultado após conversão p/ ascii
    mov 	dx, saida
    mov 	ah, 9h
    int 	21h
		
    ; recupera contexto
    popa
    popf
    ret


bin_2_ascii:
    cmp     ax, 10  ; valor salvo em ax sempre deve ser >= 0
    jb      Uni
    cmp     ax, 100
    jb      Dez
    cmp     ax, 1000
    jb      Cen
    cmp     ax, 10000
    jb      Mil
    jmp     Dezmil

    Dezmil:
		and     dx, 0
		mov		bx, 10000
		div		bx
		add		al, 0x30
		mov 	byte [di], al
		mov		ax, dx
        inc     di

    Mil:
        and     dx, 0
        mov     bx, 1000
        div     bx
        add     al, 0x30
        mov     byte [di], al
        mov     ax, dx
        inc     di

    Cen:        
        mov     bl, 100
        div     bl
        add     al, 0x30
        mov     byte [di], al
        mov     al, ah
        and     ax, 0x00FF
        inc     di

    Dez:
        mov     bl, 10
        div     bl
        add     al, 0x30
        mov     byte [di], al
        mov     al, ah
        and     ax, 0x00FF
        inc     di
    
    Uni:
        add     al, 0x30
        mov     byte [di], al
        mov     byte [di + 1], '$'  ; marca fim da string / valor convertido
        ret


; ################# SEGMENTO DE DADOS ##################
segment dados
    ; Símbolos  
    TAB     EQU     09
    CR 		EQU		13
    LF 		EQU		10

    ; Mensagens
    msg_ini:        db  LF, 'Calculadora Inicializada... ', CR, LF, '$'
    msg_op:         db  LF, '--------------------------------------------'
                    db  LF, '>> Escolha a sua operacao (+, -, * ou d):', CR, LF, '$'
    msg_N1:         db  LF, '>> Digite o primeiro operando: ', CR, LF, '$'
    msg_N2:         db  LF, '>> Digite o segundo operando: ', CR, LF, '$'
    msg_fim:        db  LF, '>> Terminando a execucao do programa...', CR, '$'
    msg_erro:       db  LF, '>> [ERRO] Operador nao reconhecido! $'
    msg_overflow:   db  LF, '>> [ERRO] O resultado excede o limite de 16 bits! $'
    msg_div_zero:   db  LF, '>> [ERRO] O divisor deve ser um valor diferente de zero! $'
    msg_resultado:  db  LF, '>> Resultado = $'
    msg_resto:      db  TAB, 'Resto = $'

    sinal_negativo: db  '-', '$'
    
    ; Variáveis
    operador:       resb    1   ; guarda char do operador (+, -, * ou d)
    N1:             dw      0   ; guarda operando 1 (valor em bin)
    N2:             dw      0   ; guarda operando 2 (valor em bin)
    resultado: 	    resw    1   ; guarda resultado calculado (valor em bin)
    acumulador:     dw      0   ; guarda valor acumulado durante conversão ascii>bin

    entrada:        db      6   ; limite da entrada (buffer size)
    n_caracteres:   resb    1   ; guarda número de characteres lidos da entrada
    num_ascii:      resb    5   ; characteres lidos da entrada (operando)
    
    saida:          resb    6   ; guarda resultado da operação convertido em ascii


; PILHA 
segment stack stack
    resb 256
stacktop:

