<h1  align="center">SSH Login 🔐</h1>

## 📝 Sobre o Script
O script de SSH Login tem a função de iniciar uma sessão no terminal com sua chave SSH do GitHub configurada. Caso você não possua uma chave, o script possui um sistema de criação automatizado.

### 🧐 O que é SSH?

SSH (Secure Shell) é um protocolo de comunicação de rede, assim como o HTTP, IMAP ou FTP. O diferencial do SSH é que ele fornece um canal seguro sobre uma rede insegura, conectando uma aplicação cliente SSH com um servidor SSH.

O SSH normalmente utiliza um sistema de par de chaves. Ao gerar um par de chaves SSH, o usuário recebe uma chave privada e uma chave pública, ambas criptografadas. Desse modo, o usuário coloca sua chave pública no servidor que deseja acessar e, uma vez que a autenticação é baseada na chave privada, a chave em si nunca é transferida por meio da rede durante a autenticação. O SSH apenas verifica se a mesma pessoa que oferece a chave pública também possui a chave privada correspondente.

### 🤔 Por que eu preciso disso?

O GitHub está aos poucos removendo a integração direta com o protocolo HTTPS. Isso é ótimo! Do ponto de vista da segurança, utilizar seu email e senha para verificar o usuário que está querendo se comunicar com o servidor não é uma boa prática. Se você utiliza a mesma senha em outros lugares ou se o seu email é conhecido, você pode ficar vunerável.

Um par de chaves SSH é uma forma de autenticação muito mais segura. Utilizando o protocolo SSH, você ganha a segurança de ter uma chave SSH privada encriptada com um número enorme de caracteres (e com senha, caso deseje uma camada a mais de segurança). 

O cliente SSH da sua máquina em nenhum momento comunica aos servidores a sua chave privada. Todo o gerenciamento acontece em torno da sua chave pública, que você adiciona aos servidores! Desse modo, para saber que *você* é *você* o agente SSH compara se a chave SSH pública da operação é equivalente a sua chave privada. Se for o caso, ele permite a comunicação!

**Utilizando chaves SSH ninguém consegue se passar por você ou ter acesso ao que você tem, desde que você mantenha a sua chave privada em segredo.** 🔒

## 🛠️ Tecnologias Utilizadas

O script é inteiramente escrito em [Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html).

## 🔍 Pré-requisitos

Para executar esse script, você precisa de:

* Um terminal com [Bash](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
* [Git](https://git-scm.com/downloads)
* Um gerenciador de [SSH](https://www.openssh.com/)

> OBS.: Se você está em um sistema operacional de uso comum, **é provável que sua máquina já possua um terminal com Bash e um gerenciador de SSH**. Mas não se preocupe, se o seu sistema estiver com alguma dependência faltando, o script dará um aviso.

## ⚙️ Como executar o projeto

Para executar o script, 

```bash
# Clone o repositório na sua máquina
$ git clone git@github.com:d3estudio/d3-lib.git

# Entre no diretório recém clonado
$ cd d3-lib

# Inicie o script do SSH Login
$ bash d3shell.sh
```

E é isto! O script irá te guiar no passo a passo para a configuração da sua chave caso você não possua uma. Caso você já possua uma chave configurada no GitHub, o script irá utiliza-la para fazer o login na sessão do terminal. Dessa forma, enquanto a sessão durar, você pode acessar seu git sem problemas!