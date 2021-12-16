# calculadora-ASM-8086

Esse programa consiste no primeiro trabalho da disciplina de Sistemas Embarcados I do curso de Engenharia de Computação, oferecido pela Universidade Federal do Espírito Santo.

Neste trabalho, foi construáda em ASM 8086, uma calculadora, capaz de realizar as operações básicas como: adição, subtração, multiplicação e divisão.

O programa consiste em um loop, onde cada iteração corresponde a uma operação entre dois operandos digitados pelo usuário. As operações a serem selecionadas são: soma (+),  subtração (-), multiplicação (*), divisão (d) e quit (q). Qualquer outro símbolo selecionado resultará em um erro e o loop é reiniciado.

O tamanho máximo dos operandos é limitado em 5 dígitos para números positivos (digitados sem sinal) e 4 dígitos para números negativos. Já o resultado é limitado em 16 bits e, portanto, deve estar na faixa [-32768 e 32767].
