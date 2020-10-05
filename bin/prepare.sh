#!/bin/sh
STACK_NAME="PublicServices1"

MINIO_ENV_PATH="./ENVs/Minio.env"

# Minio Stacks
MINIO1_DATA_VOLUME="minio1Data"
MINIO2_DATA_VOLUME="minio2Data"
MINIO3_DATA_VOLUME="minio3Data"
MINIO4_DATA_VOLUME="minio4Data"



createPassword() {
	sleep 1
	echo "$(date +%s%N | openssl sha256 | awk '{print $2}' | head -c 12)"
}

printf "Preparing ${STACK_NAME} stack\n\n"

printf "Creating Minio Secrets"

mkdir -p ./ENVs

MINIO_ACCESS_KEY="$(createPassword)"
MINIO_SECRET_KEY="$(createPassword)"

ENV_FILE_CONTENT="MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}\nMINIO_SECRET_KEY=${MINIO_SECRET_KEY}"


printf "${ENV_FILE_CONTENT}" > ${MINIO_ENV_PATH}

printf "Setting up Minio shared Storage\n"

printf "Creating the Minio volumes and touching the files"

docker service create --mode global --restart-condition=none -d --name toucher1 --mount source=${MINIO1_DATA_VOLUME},destination=/tmp/data alpine touch /tmp/data/helloWorld
docker service create --mode global --restart-condition=none -d --name toucher2 --mount source=${MINIO2_DATA_VOLUME},destination=/tmp/data alpine touch /tmp/data/helloWorld
docker service create --mode global --restart-condition=none -d --name toucher3 --mount source=${MINIO3_DATA_VOLUME},destination=/tmp/data alpine touch /tmp/data/helloWorld
docker service create --mode global --restart-condition=none -d --name toucher4 --mount source=${MINIO4_DATA_VOLUME},destination=/tmp/data alpine touch /tmp/data/helloWorld


printf "Toucher tasks created. Waiting 15 seconds to ensure tasks have run on all nodes\n\n"
sleep 15
printf "Removing toucher\n"

docker service rm toucher1 toucher2 toucher3 toucher4

printf "Chowning the Minio data volumes\n\n"

docker service create --mode global --restart-condition=none -d --name chowner1 --mount source=${MINIO1_DATA_VOLUME},destination=/tmp/data alpine chown -R 1000:1000 /tmp
docker service create --mode global --restart-condition=none -d --name chowner2 --mount source=${MINIO2_DATA_VOLUME},destination=/tmp/data alpine chown -R 1000:1000 /tmp
docker service create --mode global --restart-condition=none -d --name chowner3 --mount source=${MINIO3_DATA_VOLUME},destination=/tmp/data alpine chown -R 1000:1000 /tmp
docker service create --mode global --restart-condition=none -d --name chowner4 --mount source=${MINIO4_DATA_VOLUME},destination=/tmp/data alpine chown -R 1000:1000 /tmp

printf "\nChowner tasks created. Waiting 15 seconds to ensure tasks have run on all nodes\n\n"
sleep 15
printf "Removing chowner task containers\n"

docker service rm chowner1 chowner2 chowner3 chowner4

printf "\n\n${STACK_NAME} stack prepared."

printf "Minio Access Key: ${MINIO_ACCESS_KEY}\nMinio Secret Key: ${MINIO_SECRET_KEY}"