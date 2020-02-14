# README #

Projeto legado, criado em Delphi 7 para a migração/conversão de dados em Paradox para Interbase ou Firebird (<= 2.5)

- Também será útil se você quer importados de outro sistema para o seu.
Você pode converter primeiro para Firebird/Interbase e depois gerar scripts de SQL para Insert e Update com ferramentas como IBExpert, FlamminRobin, DBeaver, entre outros.

## Atualizações

- By Maicon Saraiva:
Incremet changes: new features, bug's fixes and improvements;

## Projeto original ##
This is a datapump for interbase, I use it for pump data from
foxpro and paradox files.

I want K2Pump to be an open source project so
your comments, suggestions and changes to the code are welcome.

If you don´t want to contribute with the project, feel free to do
whatever you want with the code.

Christian
k2pump@sig2k.com.ar
http://sig2k.com.ar

Enjoy It.

**Note:**
I took the idea (and some lines of code) from a datapump for postgree from]
Sergio Kessler
Email : sergio@perio.unlp.edu.ar
www   : http://perio.unlp.edu.ar/~sergio (broken link)

## Como utilizar? (binário compilado) ##

#### Requisitos
* Interbase 6>, ou Firebird <= 2.5;
* BDE (Borland Database Engine) v5.01>, com o BDE Administrador;
* DLL gds32.dll (deve existir ao EXE ou na System32/SysWOW64);

#### Instruções de Uso

A pasta /bin deste repositório tem o arquivo "k2pump.exe" já compilado, e também a dll gds32.dll (pode substituir se desejar) e um arquivo do banco de dados Firebird 2.1 em branco (pronto para receber a migração).
Baixe esses arquivos e coloque-os em uma pasta.

01. Instale o BDE Administrator 5.01
Você precisa instalar o BDE (Borland Database Engine), com o BDE
Administrador versão v5.01 (preferencialmente).
Após a instalação, abra o Administrador do BDE e crie um nova conexão odbc do tipo STANTARD, e sete o banco para Paradox.
Informe o local onde estão seus arquivos Paradox;

![Busca do BDE no menu Iniciar](/static/img/tela_bde_1.JPG "Busca do BDE no menu Iniciar")

![Criando uma nova conexão ODBC](/static/img/tela_bde_2.JPG "Criando uma nova conexão ODBC")

![Selecionado o tipo da conexão ODBC para o Paradox](/static/img/tela_bde_3.JPG "Selecionado o tipo da conexão ODBC para o Paradox")

![Configurando o local dos arquivos](/static/img/tela_bde_4.JPG "Configurando o local dos arquivos")

02. Selecione as opções desejadas, e inicie a migração
    * Ao abrir a tela, selecione a conexão ODBC que você criou;
    * Marque as opções desejadas (as mais usadas vem marcadas por padrão);
    * Obs: A recomendação é que você faça a migração para um banco de dados novo (vazio). Para ajudá-lo, na pasta /bin, existe um arquivo de nome "DB_NOTABLES.FDB", ao abrir o sistema, será criada uma cópia automática desse arquivo com o nome "DB_NOTABLES_NEW.FDB", use-o, se desejar;
![Tela do Sistema](/static/img/tela_sistema.JPG)

03. Se você tiver problemas com a PRIMARY KEY no
conversão, você pode fazer isso:
03.01 Após a criação da tabela no novo banco de dados,
acessá-lo com um administrador SGDB (como IBExpert,
FlamminRobin, etc.) e remova o problema
chave primária da tabela.
03.02 Desmarque "Criar instruções da tabela" e, em seguida,
Verifica
a tabela na lista de tabelas e inicie a conversão novamente;

## Como utilizar? (Edição do Código Fonte) ##

#### Requisitos
* Inclui os requisitos para o modo de utilziação já compilado mais;
* Delphi 7;
* Componentes Interbase (já vem instalados na versão Enterprise do D7):
	* TIBDatabase
	* TIBTransaction
	* TIBQuery
	* TTable

Obs: Ao compilar, o EXE será gerado na pasta "/bin".

### Suporte

Por ser uma ferramenta open-source e com código fonte disponibilizado, NÃO HÁ SUPORT!
Você é livre para baixar e tentar resolver qualquer problema que surgir.
Porém, se tiver alguma dúvida, e desejar, envie para o facebook que verei o que posso fazer:
https://www.facebook.com/MaiconSaraiva