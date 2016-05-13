# Neymar
Trabalho 1 de Redes II 2016/1 - Atilharia UDP

## Descrição do Trabalho

1. Você vai implementar um sistema cliente-servidor UDP, com o objetivo de fazer múltiplos clientes bombardearem o servidor com datagramas. Cada cliente identifica seus datagramas sequencialmente, isto é, cada datagrama leva seu número de sequência inteiro (1, 2, 3, ...).
2. O servidor deve contabilizar qual a porcentagem dos pacotes (a) se perdeu (b) chegou fora de ordem. Aumente o número de clientes bombardeando até conseguir identificar perda. O servidor deve contabilizar perdas e desordenações para cada cliente, mas dá o resultado geral. Se for um novo cliente o fluxo começa do datagrama 1 e o servidor deve verificar perdas e desordenações cuidadosamente.
3. Faça um número significativo de testes, para reportar uma conclusão estatisticamente significativa no seu relatório; incluindo a média e o desvio padrão.
4. O relatório deve apresentar uma comparação numérica, clara e objetiva: para $N$ clientes, qual a porcentagem de pacotes UDP que se perdeu? Qual a porcentagem de pacotes que chegaram fora de ordem?
5. Os logs devem obrigatorimente mostrar clientes e servidores executando em múltiplos hosts.

Para o trabalho ter resultados realmente significativos é importante a turma se organizar para as duplas implementarem em diferentes linguagens, incluindo C, Java e Python.