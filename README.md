# OpenIoT Docker Image

## Introduction

OpenIoT is an open source middleware for getting information from sensor clouds, without having to worry about what exact sensors are used. It uses efficient ways to discover and manage cloud environments for IoT “entities” and resources (such as sensors, actuators and smart devices) and offering utility-based (i.e. pay-as-you-go) IoT services.

This docker image intend to make it easyer to deploy OpenIoT in both development and production stages.

## Pulling this image

This docker image is available via Docker Hub public hosting service, and you can
pull using `docker pull jefersonla/openiot:latest`, or `docker pull jefersonla/openiot:dev` if you wanna try the dev branch.

Branchs available:

```sh
## latest -- The default stable branch.
## dev    -- Development unstable branch.
```

## Usage

### Previous Note

**Lazy Deploy**: To test the latest image redirecting ports to localhost use this
command:

```sh
docker run -it --rm --name open1 -p 8080:8080 -p 8443:8443 -p 1111:1111 -p 8890:8890 jefersonla/openiot:latest
```

Remember that this image will be removed if you close the terminal or stop the
instance with `CTRL-C`, to a more detailed instruction about deploy use the guide
bellow.

---

This image is at a development stage, so I tottaly recommend that you use only Lazy
deploy. If you wanna use this image as a demon remove the `--rm` and add `-d` to the
run command.

### Run in Daemon Mode -- Persistent

```sh
docker run -itd --name <container_name> -p 8080:8080 -p 8443:8443 -p 1111:1111 -p 8890:8890 jefersonla/openiot:latest
```

### Run in Start Terminal Log Execution Mode -- Non Persistent

If you stop the terminal the container will be stoped but it won't be removed like
lazy deploy.

```sh
docker run -it --name <container_name> -p 8080:8080 -p 8443:8443 -p 1111:1111 -p 8890:8890 jefersonla/openiot:latest
```

## Support & Development

Docker image created by Jeferson Lima <@jefersonla> at WiserUFBA Research Group
