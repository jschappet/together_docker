# Together Project

This repository contains the setup and configuration for the Together project, including Docker support for running the application locally.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/install/) (if needed)

## Building the Docker Image

To build the Docker image, run the following command in the root of the repository (where the `Dockerfile` is located):

```bash
docker build -t together:latest .