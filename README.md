# Haystack:
## extra stuff...run commands using sudo. These three files need to be in the same directory as the .env file.
## May need to run the command
## docker build -t haystack .
## dont forget the dot at the end

## Build and run you app

Copy the provided files to the root directory of you application:

-   Dockerfile
-   docker-compose.yml
-   vhost.conf

## Update .env File:

In the .env file, we have to change this line DB_HOST=127.0.0.1 to DB_HOST=mysql. Because in the docker-compose.yml file, we named our database service as mysql.

## Build and run you app

Navigate to the root directory of your Laravel application and run this command to build your app’s docker image and run it as a container:

```
docker-compose up -d
```

This command will run containers described in the docker-compose file (see below ).

The first time, it may take a few minutes. Because docker will pull all dependencies in your system.

After creating the image, run this command to see our app’s containers:

```
docker ps
```

You will see two running containers `haystack_web` and `mysql`.

## Create database:

After running the previous command, now it is time to create database schema:

```
docker exec -i mysql mysql -uroot haystack < prototype.sql
```

the previous command will execute mysql cli in your mysql database container and will execute the `prototype.sql` in order to create database schama and add data to it.

## Show the app

after the build and the start of you application please visit http://localhost:8100/ to see your application.
