# Script de Validação e Organização de Extratos Bancários em PowerShell

# Este código é uma função em PowerShell chamada "Move-ApprovedFile". 
# A função tem três parâmetros obrigatórios: "PathOrigem", "PathDestino" e "BankInformation". 
# A função serve para mover arquivos específicos de um diretório de origem para um diretório de destino, 
# baseado em informações específicas sobre bancos contidas na hashtable "BankInformation". 
# A função começa verificando se há arquivos no diretório de origem, 
# então usa comandos como "Get-ChildItem" e "Select-String" para verificar se cada arquivo 
# contém as informações específicas do banco. Se o arquivo for aprovado, ele é movido para o diretório de destino e 
# renomeado com base nas informações da hashtable.

function Move-ApprovedFile {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [String]$PathOrigem, # é uma string que representa o caminho de origem para localizar os arquivos que devem ser movidos.

        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [String]$PathDestino, # é uma string que representa o caminho de destino para onde os arquivos serão movidos.

        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [Hashtable]$BankInformation # é uma hashtable que contém informações sobre bancos (nome, número da conta, número da agência e nome de renomeamento).
    )

    Begin {
	  # Obtém a data de ontem e cria strings para representar o dia, mês e ano.
        $Today = Get-Date
        $Yesterday = $Today.AddDays(-1)
        $Day = $Yesterday.ToString("dd")
        $Month = $Yesterday.ToString("MM")
        $Year = $Yesterday.ToString("yyyy")
       
	  # Cria uma string $CheckDate usando a data obtida e duas strings fixas.
        $CheckDate = 'DFH0000010000000ERGT' + $Day + $Month + $Year + '0SDFV0000000012ERSSB'

	  # Define a variável $CheckFiles como a combinação de $PathOrigem com o padrão de arquivos "*.*"
        $CheckFiles = Join-Path $PathOrigem "*.*"

	  # Complementa o parâmetro $PathDestino com subdiretórios referente a data do arquivo.
	  $PathDestino = $PathDestino + $Year + '\' + $Month + '-' + $Year + '\' + $Day + '-' + $Month + '-' + $Year + '\'
    }
      
    Process { 
        # Verifica se há arquivos no caminho $CheckFiles usando o comando Test-Path.
        if(Test-Path $CheckFiles -PathType Leaf) {

	      # Se houver arquivos, o comando Get-ChildItem é usado para obter uma lista de todos os arquivos no caminho $PathOrigem.
            Get-ChildItem -Path $PathOrigem | ForEach-Object {

		    # Para cada arquivo na lista, o comando ForEach-Object é usado para iterar sobre cada entrada na hashtable $BankInformation.
                Foreach ($Entry in $BankInformation.GetEnumerator()) {
                    $Banco_Name = $Entry.Value.'banco_name'
                    $Banco_Conta = $Entry.Value.'banco_conta'
                    $Banco_Agencia = $Entry.Value.'banco_agencia'
                    $Banco_Rename = $Entry.Value.'banco_rename'
                    $GetFile = Join-Path $PathOrigem ($_.BaseName + '.*')

			  # Para cada entrada, o comando Select-String é usado para verificar se o arquivo contém 
			  # as informações específicas do banco (nome, número da conta, número da agência e a data).
                    $FindDate = Select-String -Path $GetFile -Pattern $CheckDate
                    $FindName = Select-String -Path $GetFile -Pattern $Banco_Name
                    $FindConta = Select-String -Path $GetFile -Pattern $Banco_Conta
                    $FindAgencia = Select-String -Path $GetFile -Pattern $Banco_Agencia

                    # Se o arquivo contiver todas as informações do banco, ele é movido para o caminho de destino, 
                    # usando o comando Move-Item. O nome do arquivo é renomeado usando o nome definido na hashtable.
		        # Se não houver arquivos, a função não faz nada.
                    if ($FindDate -And $FindName -And $FindConta -And $FindAgencia) {		
                        $FileFrom = Join-Path $PathOrigem ($_.Name)
                        $FileTo = Join-Path $PathDestino ($Banco_Rename + $Day + '-' + $Month + '-' + $Year + '.txt')
                        if (!(Test-Path $FileTo)) {
                            New-Item -ItemType Directory -Force -Path $PathDestino
                            Move-Item $FileFrom $FileTo
                        }
                    }
                }
            }
        }
    }
}


# Registre as informações bancárias no dicionário '$contasBancarias'.

$contasBancarias = [ordered]@{
    "extrato_1" = [PSCustomObject]@{
        "banco_name" = "TZY0000010000000000bancoFoda000000000001245TGB0";
        "banco_conta" = "FGY00000100000000009999900000000000124HASB0";
        "banco_agencia" = "SKY000001000000000011110000000000012QWSSB0";
	  "banco_rename" = "bancoFoda_99999_"
    }
    "extrato_2" = [PSCustomObject]@{
        "banco_name" = "TZY0000010000000000bancoFoda000000000001245TGB0";
        "banco_conta" = "FGY00000100000000009999800000000000124HASB0";
        "banco_agencia" = "SKY000001000000000011120000000000012QWSSB0";
	  "banco_rename" = "bancoFoda_99998_"
    }
    "extrato_3" = [PSCustomObject]@{
        "banco_name" = "TZY0000010000000000bancoFoda000000000001245TGB0";
        "banco_conta" = "FGY00000100000000009999500000000000124HASB0";
        "banco_agencia" = "SKY000001000000000011150000000000012QWSSB0";
	  "banco_rename" = "bancoFoda_99995_"
    }
    "extrato_4" = [PSCustomObject]@{
        "banco_name" = "TZY0000010000000000bancoTop000000000001245TGB0";
        "banco_conta" = "FGY00000100000000009999300000000000124HASB0";
        "banco_agencia" = "SKY000001000000000022250000000000012QWSSB0";
	  "banco_rename" = "bancoTop_99993_"
    }
    "extrato_5" = [PSCustomObject]@{
        "banco_name" = "TZY0000010000000000bancoTop000000000001245TGB0";
        "banco_conta" = "FGY00000100000000008777300000000000124HASB0";
        "banco_agencia" = "SKY000001000000000033350000000000012QWSSB0";
	  "banco_rename" = "bancoTop_87773_"
    }
}


# Chame a função 'Move-ApprovedFile' informando os parâmetros de '-PathOrigem', '-PathDestino' e '-BankInformation'.

Move-ApprovedFile -PathOrigem "C:\Users\jeanB\OneDrive\Área de Trabalho\extratos-bancarios\input\" -PathDestino "C:\Users\jeanB\OneDrive\Área de Trabalho\extratos-bancarios\output\" -BankInformation $contasBancarias

