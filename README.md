# SIIU_Oracle_Docker

This package allows you to deploy Oracle express 18.4 in a docker container, so you can work with the SIIU's database.
You can deploy your own instance of oracle, import the database from the dump provided by the SIIU and extract relevant data.

## Install Docker

1. `sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`
2. `sudo chmod +x /usr/local/bin/docker-compose`
3. For additional configuration follow the steps in [https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user]

## Executing docker-compose

1. Edit the config.env file, then use `source config.env`
2. Execute `docker-compose up -d`
3. Optional: you can see the progress with `docker-compose logs`

## Some errors

- `[ORA-12954]`: This error gets triggered when the DB is greater than 12GB, you can add to the import comamnd:
`tables="TABLE_SPACE_NAME.TABLE_NAME","TABLE_SPACE_NAME.TABLE_NAME"`, this includes those tables only or
you can exclude tables that occupy too much space with `exclude=table:\"IN \'TABLE_NAME\'\"`,
if you use either, then you must also include `data_options=skip_constraint_errors`
