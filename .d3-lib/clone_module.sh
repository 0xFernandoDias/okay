#!/bin/bash

#função após ser executada declara um array com todo o conteudo .config em todo o ambiente shell de execução
arraySetUp() {
    source .config
    repo=$REPOS
    delimiter="
"
    # aux variable
    s=$repo$delimiter
    # echo $s
    FORMATED_REPOS=()
    while [[ $s ]]; do
        FORMATED_REPOS+=("${s%%"$delimiter"*}")
        s=${s#*"$delimiter"}
    done
    # declaring array
    ARRAY_REPOS=()
    for repo in "${!FORMATED_REPOS[@]}"; do
        [[ "${FORMATED_REPOS[repo]}" ]] && ARRAY_REPOS+=("${FORMATED_REPOS[repo]}")
    done
    declare -p ARRAY_REPOS >/dev/null
}

cloningRepo() {
    #recebe o link do respositório
    repoUrl=$1
    #recebe a branch do rep ou hash
    repoBranch=$2
    #recebe o hash do .config se existir
    configHash=$3
    #caminho de clone
    clonePath=$4

    echo "Creating directory"
    echo "Cloning $repoUrl"

    LAST_PATH=$(pwd)
    if git clone $repoUrl $clonePath; then
        echo "Clone Sucessfull!"
    else
        echo "$ERROR_LOG"
        exit
    fi
    cd $clonePath
    checkout "$repoUrl" "$configHash" "$repoBranch"
    cd "$LAST_PATH"
}

checkout() {
    #link do repositório
    repoUrl=$1
    #recebe o hash do .config
    repoHash=$2
    #recebe como parametro a branch do .config
    branch=$3
    if [[ $(git status --porcelain) ]]; then
        read -s -p "Changes detected! Want to delete changes?  S/N " response
        if [[ $response == "n" || $response == "N" ]]; then
            echo "Finished Process, cloning aborted!"
            exit 0
        else
            echo "Stashing changes: "
            git stash
        fi
    else
        echo "not changes detected in branch: $branch"
    fi

    #verifica se existe hash .config foi informado
    if [ $repoHash == 'LATEST' ]; then #se o hash do .config estiver vazio ele faz o checkout pra branch
        git checkout $branch
    #se tiver hashConfig ele faz o checkout no hash especifico
    else
        git checkout $repoHash
    fi
    echo "git pull: $branch"
    git pull

    # changeEnvironmentDeveloper "$(basename $repoUrl .git)" $branch

    #chamando a função clone recursivamente através de um script do repositorio filho
    bash clone.sh
    echo '------------------------------------------------------------------------------------------------'
}

#realiza a troca do importmap quando a pipeline for executado para o ambiente dev
changeEnvironmentDeveloper() {
    #recebe o nome do repositório
    repoName=$1
    #recebe a branch
    branch=$2
    #faz comparações , caso todas sejam verdadeiras ele faz o troca do importmap no repositorio root
    if [[ "$repoName" == "d3-lib-mfe-root" && ! -z $FLAG_PIPELINE && "$branch" == "dev" ]]; then #se todas essas condições forem verdadeiras ele trocar o import map para o import map com os endereços o Dev Env
        cd public && rm -r importmap.production.json && cd ..
        cp ../../submit_files/importmap.production.json ./public/
        echo "change import map for development environment!"
    else
        echo "import map not trade"
    fi
}

configRead() {
    arraySetUp
    FUNCTION_RUN=$1
    [[ -z $FUNCTION_RUN ]] && FUNCTION_RUN="cloningRepo"
    for repo in "${!ARRAY_REPOS[@]}"; do
        REPOITEMS=()
        for repoItem in ${ARRAY_REPOS[repo]}; do
            [[ !$repoItem && "$repoItem" != "," ]] && REPOITEMS+=("${repoItem} ")
        done
        repoUrl=${REPOITEMS[0]}
        repoBranch=${REPOITEMS[1]}
        repoHash=${REPOITEMS[2]}
        repoPath=${REPOITEMS[3]}
        echo "Repo URL " $repoUrl
        echo "Repo Branch " $repoBranch
        echo "Repo Hash " $repoHash
        echo "Repo Path " $repoPath

        if [ -z "$repoUrl" ]; then
            echo "Empty repoUrl"
        else
            "$FUNCTION_RUN" "$repoUrl" "$repoBranch" "$repoHash" "$repoPath"
        fi
    done
}

ERROR_LOG="
--------------------------------------------------------------------
|    !error during repository cloning ! recurring reasons:         |
|                                                                  |
| 1 - check if there is not already a repository with the          |
| path being passed in the .config                                 |
|                                                                  |
| 2 - make sure the repository name is correct.                    |
|                                                                  |
| 3 - check the path you are trying to clone,                      |
| if the path already exists, the clone will be stopped.           |
|                                                                  |
| 4 - if you can not solve it , contact your tech leader.         |
|                                                                  |
--------------------------------------------------------------------
"
