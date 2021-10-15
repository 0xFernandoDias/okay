#!/bin/bash

checkHash() {
  #faz a verificação se o hash que foi passado no .config é igual ao captura pelo repositório
  if [[ "$repoHash" == "$hashConfig" ]];
    then
        echo "commit clone OK"
        #executado a função de verificar se a imagem já existe na amazon ECR
        checkEcrImage $ecr_repo_name $hashConfig
        #volta ao endereço que estava antes de entrar no diretório do environment
        
        #recebe a resposta da amazon e faz uma verificação
        if [ "$RESPONSE_AWS" == "true" ];
            then
                echo "existing image OK"
                #só adiciona as informações ao array como imagens que já existe , por tanto não precisa buildar
                DEPLOY_IMAGES+=( "$ecr_repo_name $hashConfig $RESPONSE_AWS $repoBranch");
            else
                echo "Image not found in ECR $ecr_repo_name --> $hashConfig"
                #faz o build da imagem de maneira individual
                docker-compose build $ecr_repo_name || true
                #adiciona a as informações no array de imagens para deploy
                DEPLOY_IMAGES+=( "$ecr_repo_name $hashConfig $RESPONSE_AWS $repoBranch");
        fi
    else
        #caso o commit solicitado não seja igual ao que foi clonado , será retornado esse erro
        echo "hash of .config: $repoHash | hash repo: $hashConfig"
        echo "error check: commits not equals or commit not set in .config"
    fi

    cd $LAST_PATH
}

checkoutHashAndAmazon(){
    #recepção dos parametros que estão sendo enviando na função configRead dentro do clone.sh
    #recebe o nome do repositório através do link
    ecr_repo_name=$(basename $1 .git);
    #recebe a branch do repo
    repoBranch=$2;
    #recebe o hash do arquivo .config se for informado
    hashConfig=$3;
    #recebe o caminho do repositorio em sua maquina
    repoPath=$4;
    echo "checking repository integrity!"
    LAST_PATH=$(pwd)
    #entra na paste do repositŕório
    cd $repoPath
    #atribui a variavel repoHash o hash do reposittório
    repoHash=$(git rev-parse HEAD)
    #verifica se foi passado um hashCommit pelo arquivo .config
    if [ $hashConfig == "LATEST" ];
        #se estiver vazio, ele vai pegar o hash do repositório
        then hashConfig=$(git rev-parse HEAD)
    fi
    checkHash
}

