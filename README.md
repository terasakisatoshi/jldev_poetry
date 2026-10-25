# jldev_poetry

Enhance your JOps (= Julia + Python/Poetry + VSCode + JupyterLab + Docker + Pluto)

# How to use

## Prerequisite

- Please install Git, GNU Make, Docker and Docker Compose.

## Setup environment

```console
$ git clone https://github.com/terasakisatoshi/jldev_poetry.git
$ cd jldev_poetry
$ make
```

After that go to the next chapter.

# How to run

## Initialize JupyterLab

```console
$ docker-compose up lab
```

## Dive into the Docker container

```console
$ docker-compose run --rm shell bash
jovyan@e74b3f5d0d5e:/workspace/jldev_poetry.jl$ # do something awesome e.g. julia or python
```

## Test

```console
$ make test
```

## Docs

```console
$ docker-compose up web
```

Then, go to localhost:8000

## Format file

```console
docker-compose run --rm shell poe format
```

## Update packages

- Julia

```console
$ docker-compose run --rm shell julia -e 'using Pkg; Pkg.add("Example")'
$ make # rebuild Docker image
```

- Python

```console
$ docker-compose run --rm shell poetry add "numpy"
$ make # rebuild Docker image
```

## VSCode

- Install VSCode in advance

```console
$ cd /path/to/this/repository
$ code . # Open VSCode
```

Then dive into Remote Container.

## Clean up

```console
$ make clean
```

## Supported runtime and security migration

Julia 1.10 and the latest stable Julia 1.x release are tested. Python 3.11 is the supported notebook interpreter, with Pillow 13, JupyterLab 4 and Notebook 7. The Docker image tracks the Julia 1.10 Bookworm line; Compose mounts the same `/workspace/jldev_poetry` path used by the image.

Legacy Lab 3 topbar/system-monitor, WebIO frontend, Sublime keybindings and Monokai++ theme are removed. Lab 4 uses its default theme; compatible topbar text, code formatter, widgets, Jupytext and Pluto proxy remain. WebIO-specific interactive displays need a future compatible replacement. Python and Julia notebook kernels remain available.

CI tests notebook execution/export, scientific plotting, authenticated Lab startup and the full Docker image. These are smoke checks, not exhaustive browser-extension or scientific equivalence tests.
