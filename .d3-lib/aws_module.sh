#!/bin/bash

#função de checagem da imagem na amazon
checkEcrImage(){
    #recebe o nome do repositório ECR
    ecr_repo_name=$1;
    #recebe o nome da imagem
    repoHash=$2;
    RESPONSE_AWS=;
    #através do CLI da amazon faz um requisição ao ECR com o nome do repositório e nome da imagem
    resp=$(aws ecr describe-images --repository-name $ecr_repo_name --image-ids imageTag=$repoHash --output text)
    #se a resposta a variavel resp contiver o nome da imagem na resposta, quer dizer que existe na amazon e return essa resposta
    if [[ $resp == *$repoHash* ]];then
        RESPONSE_AWS="true";
    else
        RESPONSE_AWS="false";
    fi
}

#função resposanvel por fazer o envio da imagem para a amazon caso ele não exista
pushImagesEcr(){
    #recebe o link geral da ECR
    repository_ecr=$1
    #esse array DEPLOY_IMAGES já foi declarado no ambiente por outra função
    for repository in "${!DEPLOY_IMAGES[@]}"
    do
        #criação de um array vazio
        REPO_CONFIG=();
        for repoConfig in ${DEPLOY_IMAGES[repository]}
        do
            #pegamos os elementos do array e fatiamos para um segundo array
            REPO_CONFIG+=( "${repoConfig%%" "*}" );
        done
        # declara a variavel DOCKER_IMAGE como variavel de ambiente para ser acessada pelo script de deploy no rancher logo abaixo
        DOCKER_IMAGE=$repository_ecr/${REPO_CONFIG[0]}:${REPO_CONFIG[1]}
        docker images
        #verifica se o terceiro elemento do DEPLOY_IMAGES é false
        if [ "${REPO_CONFIG[2]}" == "false" ];then
            #Cria um docker tag passando todas as informações do array concatenadas com repository_ecr
            docker tag ${REPO_CONFIG[0]} $DOCKER_IMAGE
            docker images
            #faz o push da imagem para a amazon utilizando a tag criada
            docker push $DOCKER_IMAGE
            #executa o deploy no rancher
            deployRancher "$DOCKER_IMAGE"
        else
            deployRancher "$DOCKER_IMAGE"
        fi
    done
}


