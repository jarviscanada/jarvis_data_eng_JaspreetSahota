#!/bin/sh

# Capture CLI arguments
cmd=$1
db_username=$2
db_password=$3

# Start Docker if not running
sudo systemctl status docker --no-pager > /dev/null 2>&1 || sudo systemctl start docker

# Check container status
docker container inspect jrvs-psql > /dev/null 2>&1
container_status=$?

# Handle create|start|stop commands
case $cmd in
  create)
    # Check if container already exists
    if [ $container_status -eq 0 ]; then
      echo "Container 'jrvs-psql' already exists"
      exit 1
    fi

    # Require username and password
    if [ $# -ne 3 ]; then
      echo "Create requires username and password: ./psql_docker.sh create username password"
      exit 1
    fi

    # Create volume if not exists
    sudo docker volume create pgdata

    # Run the container
    sudo docker run \
      --name jrvs-psql \
      -e POSTGRES_USER=$db_username \
      -e POSTGRES_PASSWORD=$db_password \
      -d \
      -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 \
      postgres:9.6-alpine

    exit $?
    ;;

  start|stop)
    # Check if container exists
    if [ $container_status -ne 0 ]; then
      echo "Container 'jrvs-psql' has not been created yet"
      exit 1
    fi

    # Start or stop the container
    sudo docker container $cmd jrvs-psql
    exit $?
    ;;

  *)
    echo "Illegal command"
    echo "Usage: ./psql_docker.sh create|start|stop username password"
    exit 1
    ;;
esac