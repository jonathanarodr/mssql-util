# mssql-util
Conjunto de script's em SQL Server utilizados para agilizar a elaboração de novos processos e análise no SQL.

## Functions

#### fn_FormatarCPF
Função utilizada para formatação de CPF no formato `000.000.000-00`

```
SELECT dbo.fn_FormatarCPF('00000000000')
```

#### fn_FormatarCNPJ
Função utilizada para formatação de CNPJ no formato `00.000.000/0000-00`

```
SELECT dbo.fn_FormatarCNPJ('00000000000000')
```

#### fn_RemoveCaracterEspecial
Função utilizada para remoção de caracteres especiais de uma string

```
SELECT dbo.fn_RemoveCaracterEspecial('Executando função para remoção de cadasteres especiais')
```

## Procedures
#### pr_ConsumoMemoriaDB
Procedure para análise de consumo de memória por database.
```
EXEC pr_ConsumoMemoriaDB
```

## Views
#### vw_ProcessosSQL
Está view é utilizada para visualização de todos os processos em execução presentes no database ativo.
```
SELECT * FROM vw_ProcessosSQL
```
## Jobs
#### job_Kill_HeadBlocker
Job utilizado para finalização de processos que originam lock no database, por **_default_** o processo esta calibrado para encerrar processos bloqueados que estão em execução à **5 minutos**, mas esta configuração pode ser alterada posteriormente conforme a sua necessidade.

> Para utilização deste Job é necessário executar a criação da tabela **`TempProcessoSQL`** para que seja armazenado o histórico de processos encerrados pelo Job:
```
CREATE TABLE TempProcessoSQL 
            (nCdIDProcesso      int
            ,cNmDatabase        varchar(100)
            ,cNmLogin           varchar(100)
            ,dDtLogin           datetime
            ,cNmComputador      varchar(100)
            ,dDtInicioExec      datetime
            ,cStatusExec        varchar(50)
            ,cFlgTransacaoAtiva int
            ,dDtCadastro        datetime
            ,cComandoSQL        varchar(MAX))
GO
```

Ao abrir o script **`job_Kill_HeadBlocker`** é necessário configurar o nome do database no qual o Job será executado, substitua a variável **`$NomeDatabase`** pelo nova do database e execute o script para sua criação.

Após a execução do script, o Job verifica minuto a minuto se existe um lock em seu database, caso exista ele verifica se o tempo de execução do script atingiu o tempo calibrado no Job, caso tenha atingido ele armazena as informações do processo na **`TempProcessoSQL`** e finaliza o processo através do comando <a href="https://msdn.microsoft.com/pt-br/library/ms173730.aspx">KILL {session id}</a>.

