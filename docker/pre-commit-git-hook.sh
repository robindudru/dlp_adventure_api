#!/bin/bash
# 
# Lance des vérifications sur les fichiers avant le commit 
# scripts à enregister dans le fichier .git/hooks/pre-commit# 
# ex: ln -sf $PWD/docker/pre-commit-git-hook.sh ./.git/hooks/pre-commit

CURRENT_DIRECTORY=`pwd`
GIT_HOOKS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJECT_DIRECTORY="$GIT_HOOKS_DIR/.."

function run_or_exit(){
        CONTAINERNAME=$1
        CONTAINERCMD=$2
        CMD="docker-compose exec -u `echo $UID` -T $CONTAINERNAME $CONTAINERCMD"
        HELP=$3
        echo -e "\n### execute [$CMD]"
        $CMD
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]
        then
                echo -e "### command successfull [$CMD] \n"
        else
                echo -e "### !!!! command FAILED  with exit code [$EXIT_CODE] !!!  !!! \n [$CMD] ###"
                echo -e "###       $HELP \n ###"
                echo -e "##################### !!!!! COMMIT STOPPED !!!!! #####################\n"
                exit 10
        fi
}

cd $PROJECT_DIRECTORY;

echo -e "\n##################### ANALYSE PROJET [$PROJECT_DIRECTORY] AVANT COMMIT #####################"

git diff --name-only --cached

if [[ `git diff --name-only --cached` ]];then
        echo -e "\n### files to commit:"
        git diff --name-only --cached
        echo ""
else
        echo -e "### pas de modifications à commiter !!! \n  ##################### !!!!! COMMIT STOPPED !!!!! #####################"
        exit 1000
fi

run_or_exit php "bin/console --version" # genere le cache symfony et évite que phpstan échoue


if [[ `git diff --name-only --cached | grep twig` ]]; then

        echo -e "\n### MODIFICATION DETECTEE SUR DES FICHIERS TWIG"

        run_or_exit php "bin/console lint:twig templates -e prod --no-ansi"
fi

if [[ `git diff --name-only --cached | grep 'src\|config'` ]]; then

        echo -e "\n### MODIFICATION DETECTEE SUR DES FICHIERS PHP"

        run_or_exit php "bin/console lint:container -e prod"

        run_or_exit php "vendor/bin/php-cs-fixer fix --dry-run --show-progress=none"
       
        run_or_exit php "vendor/bin/phpstan analyse --no-progress"
fi

cd $CURRENT_DIRECTORY;

echo "##################### ANALYSE  OK ##########################################"

if [[ `git diff --name-only` ]]; then
        echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! Des fichiers sous gestion de version ont été modifié, mais ces modifications ne seront pas commitées"
        echo "!!! Peut-être avez vous oubliez de les ajouter avec ces commandes?"
        git diff --name-only | sed 's/^\(.*\)$/git add \1/'
fi

if [[ `git status --porcelain | grep '^??'` ]]; then
        echo -e "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!! De nouveau fichiers ont été détectés"
        echo "!!! Peut-être avez vous oubliez de les ajouter avec ces commandes?"
        git status --porcelain | grep '^??' | cut -c 4- | sed 's/^\(.*\)$/git add \1/'
fi

echo -e "\n ##################### FIN DU SCRIPT bin/git_hooks/pre_commit ##################### \n"
