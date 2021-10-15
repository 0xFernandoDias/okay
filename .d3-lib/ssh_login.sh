# !/bin/bash

# git@github.com:d3estudio/d3-dummy-repo.git

### Variáveis ###

operational_system=""
root_directory=""
dummy_repo="git@github.com:d3estudio/d3-lib.git"
repo_name=$(basename $dummy_repo .git)
github_keys_url="https://github.com/settings/keys"

### Funções ###

# Função para clonar o repositório Dummy
clone_dummy(){
    status=1
    echo "Iniciando teste de acesso com DummyRepo..."
    echo " "
    (git clone -q $dummy_repo && rm -fr $repo_name) > /dev/null 2>&1 && status=0
    
    if [ $status == 0 ]; then
    echo "Sua chave SSH e permissões de repositório estão configuradas com sucesso!" && return 0
    else echo "Não foi possível acessar o repositório dummy." && return 1
    fi  
}

# Função para identificar o sistema operacional
system_check(){
    if [[ $OSTYPE == "linux"* ]]; then
        operational_system="Linux"
    elif [[ $OSTYPE == "darwin"* ]]; then
        operational_system="OSX"
    elif [[ $OSTYPE == "msys"* ]]; then
        operational_system="Windows"
    else
        operational_system=$OSTYPE
    fi
}

# Função para identificar as dependências
dependencies_check(){
    status=0
    echo " "
    if [[ "$operational_system" == "Windows" ]];
    then
        if [[ $(where.exe ssh) == "" ]]; then echo "Dependência ausente: ssh"; status=1; fi
        if [[ $(where.exe git) == "" ]]; then echo "Dependência ausente: git"; status=1; fi
        if [[ $status == 1 ]]; then
            echo "------------------------------------------------------------------"
            echo " Uma ou mais dependências não foram encontradas no seu sistema."
            echo " Por favor, instale-as e execute o script novamente."
            echo "------------------------------------------------------------------"
            echo " "
            return 1
        else return 0
        fi
    else
        if [[ $(which ssh) == "" ]]; then echo "Dependência ausente: ssh"; status=1; fi
        if [[ $(which git) == "" ]]; then echo "Dependência ausente: git"; status=1; fi
        if [[ $status == 1 ]]; then
            echo "------------------------------------------------------------------"
            echo " Uma ou mais dependências não foram encontradas no seu sistema."
            echo " Por favor, instale-as e execute o script novamente."
            echo "------------------------------------------------------------------"
            echo " "
            return 1
        else return 0
        fi
    fi
}

# Função para verificar se existe agente SSH
agent_check(){
    ssh-add -l &>/dev/null
    if [ "$?" == 2 ]; then eval "$(ssh-agent)" &> /dev/null; fi
}

# Função que inicia a sessão do terminal com o agente SSH logado
bash_session(){
    sleep 1

	bash --rcfile $ABSOLUTE_PROJECT_PATH/.d3-lib/shell/rcfile
    echo "Sessão D3 Shell finalizada."
}

# Função para gerar um par de chaves SSH
ssh_generator(){
    clear
    echo "Sistema Operacional: $operational_system"
    echo " "
    read -p "Por favor, digite seu email do GitHub: " email
    echo " "
    clear
    echo "Em qual caminho você deseja salvar o par de chaves?"
    echo "(Deixe em branco caso queira optar pelo path padrão)"
    read -p "Caminho: " key_path
    if [[ "$key_path" == "" ]]; then key_path=".ssh"; fi
    if [[ "${key_path:0:1}" == "/" ]]; then key_path="${key_path:1}"; fi
    mkdir -p $root_directory/$key_path
    clear
    echo "Qual nome você deseja dar ao par de chaves?"
    echo "(Deixe em branco caso queira optar pelo nome padrão)"
    read -p "Nome: " key_name
    if [[ "$key_name" == "" ]]; then key_name="id_ed25519"; fi
    clear
    echo "Qual passphrase você deseja adicionar à chave?"
    echo "------------------------------Atenção------------------------------"
    echo " Se optar por utilizar uma passphrase, o sistema irá pedir por ela"
    echo " quando a chave for utilizada. Portanto, MEMORIZE-A! Caso deseje " 
    echo " optar por NÃO utilizar uma passphrase, basta deixar em branco."
    echo "-------------------------------------------------------------------"
    read -s -p "Passphrase: " passphrase
    echo  " "
    clear

    key_full_path="$root_directory/$key_path/$key_name"
    sub_str="//"
    replace_str="/"
    key_full_path=${key_full_path//$sub_str/$replace_str}

    ssh-keygen -t ed25519 -N "$passphrase" -f $key_full_path -C "$email" || ssh-keygen -t rsa -N "$passphrase" -f $key_full_path -b 4096 -C "$email"
    sleep 2
    clear

    if [[ "$operational_system" == "OSX" ]]; then
        if [ $(find ~/.ssh -maxdepth 1 -type f -name config | wc -l) == 0 ]; then touch ~/.ssh/config; fi
        touch aux.txt
        echo "HOST *" >> aux.txt
        echo "  IgnoreUnknown UseKeychain" >> aux.txt
        echo "  AddKeysToAgent yes" >> aux.txt
        if [[ "$passphrase" != "" ]]; then echo "  UseKeychain yes" >>i aux.txt; fi
        echo "  IdentityFile $key_full_path" >> aux.txt
        cat aux.txt >> ~/.ssh/config
        rm -f aux.txt

        if [[ "$passphrase" != "" ]]; then ssh-add -K $key_full_path; else ssh-add $key_full_path; fi

        echo " "
        pbcopy < $key_full_path.pub
        echo "Sua chave pública está na área de transferência. Adicione-a ao GitHub."
        echo "Caso não esteja, copie o conteúdo a seguir e adicione-o ao GitHub através do endereço $github_keys_url: "
        echo " "
        echo "Conteúdo da chave: "
        cat $key_full_path.pub
        echo " "
        sleep 2
        open $github_keys_url > /dev/null 2>&1

    elif [[ "$operational_system" == "Linux" ]]; then
        if [ $(find ~/.ssh -maxdepth 1 -type f -name config | wc -l) == 0 ]; then touch ~/.ssh/config; fi
        touch aux.txt
        echo "HOST *" >> aux.txt
        echo "  IgnoreUnknown UseKeychain" >> aux.txt
        echo "  AddKeysToAgent yes" >> aux.txt
        if [[ "$passphrase" != "" ]]; then echo "  UseKeychain yes" >> aux.txt; fi
        echo "  IdentityFile $key_full_path" >> aux.txt
        cat aux.txt >> ~/.ssh/config
        rm -f aux.txt

        ssh-add $key_full_path
        echo " "
        echo "Por favor, copie o conteúdo da sua chave pública para o GitHub através do endereço $github_keys_url."
        echo " "
        echo "Conteúdo da chave: "
        cat $key_full_path.pub
        echo " "
        sleep 2
        xdg-open $github_keys_url > /dev/null 2>&1


    elif [[ "$operational_system" == "Windows" ]]; then
        ssh-add $key_full_path
        echo " "
        clip < $key_full_path.pub
        echo "Sua chave pública está na área de transferência. Adicione-a ao github."
        echo "Caso não esteja, copie o conteúdo a seguir e adicione-o ao GitHub através do endereço $github_keys_url: "
        echo " "
        cat $key_full_path.pub
        echo " "
        sleep 2
        explorer $github_keys_url > /dev/null 2>&1
    
    else
        ssh-add $key_full_path
        echo "Seu sistema operacional não foi reconhecido."
        echo "Por favor, copie manualmente a sua chave pública para o GitHub através do endereço $github_keys_url: "
        echo " "
        echo "Chave: "
        cat $key_full_path.pub
        echo " "
    fi

    while true; do
        sleep 5
        read -p "Já adicionou sua chave pública no GitHub? (S/N): " sn
        case $sn in
            [YysSs]* ) break;;
            * ) echo "Aguardando...";;
        esac
    done

    clone_dummy
    if [[ $? == 0 ]]; then bash_session; fi
}

# Função que apresenta um menu de opções para o Usuário
prompt(){
    echo "Você possui uma chave pública SSH configurada no GitHub?"
    select response1 in "Sim" "Não" "Não sei"; do
        case $response1 in
            "Sim" )
                clear
                echo "Em qual caminho está sua chave privada?"
                echo "Atenção! Descreva o caminho completo. Ex: /Users/myuser/secretfolder/secretkey"
                read -p "Caminho: " key_address
                echo " "

                ssh-add "$key_address" &> /dev/null
                if [[ $? == 1 ]]; then
                    echo "-------------------------------------------------------------------"
                    echo " Não foi possível adicionar essa identidade privada ao agente."
                    echo " Tem certeza que a chave está nesse endereço? Se sim, verifique a" 
                    echo " integridade da sua chave ou peça ajuda ao Tech Leader."
                    echo "-------------------------------------------------------------------"
                else
                    echo "Gostaria de salvar esta identidade para ser utilizada posteriormente?";
                    select response2 in  "Sim" "Não"; do
                        case $response2 in
                            "Sim" )
                                if [ $(find ~/.ssh -maxdepth 1 -type f -name config | wc -l) == 0 ]; then touch ~/.ssh/config; fi
                                touch aux.txt
                                echo "HOST *" >> aux.txt
                                echo "  AddKeysToAgent yes" >> aux.txt
                                echo "  IdentityFile $key_address" >> aux.txt
                                cat aux.txt >> ~/.ssh/config
                                rm -f aux.txt
                                ;;
                            * ) echo "Ok, não registrarei o endereço da sua chave no agente.";;
                        esac
                        break;
                    done

                    clone_dummy
                    if [[ $? == 0 ]]; 
                    then bash_session
                    else
                        echo "---------------------------------------------------------------------"
                        echo " Se a sua chave pública já está no GitHub mas o script não clona"
                        echo " com sucesso, você pode estar sem permissões no repositório." 
                        echo " Peça ajuda ao Tech Leader para receber permissão de acesso."
                        echo "---------------------------------------------------------------------"
                    fi
                fi
                ;;
            "Não" ) 
                echo "Gostaria de gerar um novo par de chaves?";
                select response2 in  "Sim" "Não"; do
                    case $response2 in
                        "Sim" ) ssh_generator;;
                        "Não" ) 
                            echo "---------------------------------------------------------------"
                            echo " Por razões de segurança, um par de chaves SSH é necessário."
                            echo " Se você possui dúvidas sobre o tema, consulte o Tech Leader"
                            echo " para obter mais informações. "
                            echo "---------------------------------------------------------------"
                            ;;
                        * ) echo "Resposta inválida"; prompt;;
                    esac
                    break;
                done;;
            "Não sei" ) echo "Verifique se sua chave está configurada em: $github_keys_url";
                echo "---------------------------------------------------------------------"
                echo " Se a sua chave pública já está no GitHub mas o script não clona"
                echo " com sucesso, você pode estar sem permissões no repositório. " 
                echo " Peça ajuda ao Tech Leader para receber permissão de acesso."
                echo "---------------------------------------------------------------------"
                ;;
            * ) echo "Resposta inválida"; prompt;;
        esac
        break;
    done
}

### Execução ###
if [[ -z "$1" ]]; then
    ABSOLUTE_PROJECT_PATH=$(pwd) > /dev/null
    export ABSOLUTE_PROJECT_PATH
    cd
    root_directory=$(pwd) > /dev/null
    cd -

    system_check
    dependencies_check
    if [[ $? == 1 ]]; then exit 1; fi

    agent_check

    clone_dummy
    if [[ $? != 0 ]]; then prompt; else bash_session; fi
else
    . ./.env
    ssh-add - <<< "$BOT_KEY"
    touch ~/.ssh/known_hosts
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
fi
