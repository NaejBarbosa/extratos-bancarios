# Script de Validação e Organização de Extratos Bancários em PowerShell
Esse script em PowerShell é usado para mover arquivos aprovados para um destino específico, renomeando-os de acordo com informações fornecidas em uma hashtable.

## Parâmetros
* PathOrigem: é uma string que representa o caminho de origem para localizar os arquivos que devem ser movidos.
* PathDestino: é uma string que representa o caminho de destino para onde os arquivos serão movidos.
* BankInformation: é uma hashtable que contém informações sobre bancos (nome, número da conta, número da agência e nome de renomeamento).
## Funcionamento
1. O script começa obtendo a data de ontem e criando strings para representar o dia, mês e ano.
2. Em seguida, a variável CheckDate é criada usando a data obtida e duas strings fixas.
3. A variável CheckFiles é definida como a combinação de PathOrigem com o padrão de arquivos ".".
4. O parâmetro PathDestino é complementado com subdiretórios referentes à data do arquivo.
5. O script verifica se há arquivos no caminho CheckFiles usando o comando Test-Path.
6. Se houver arquivos, o comando Get-ChildItem é usado para obter uma lista de todos os arquivos no caminho PathOrigem.
7. Para cada arquivo na lista, o comando ForEach-Object é usado para iterar sobre cada entrada na hashtable BankInformation.
8. Para cada entrada, o comando Select-String é usado para verificar se o arquivo contém as informações específicas do banco (nome, número da conta, número da agência e a data).
9. Se o arquivo contiver todas as informações do banco, ele é movido para o caminho de destino, usando o comando Move-Item. O nome do arquivo é renomeado usando o nome definido na hashtable. Se não houver arquivos, a função não faz nada.