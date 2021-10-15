touch .env
for each in ${env_vars[@]}; do
    echo "$each"
done