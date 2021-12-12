.PHONY : all, build, web, test, jltest, mypy, pytest, clean

DOCKER_IMAGE=jldev_poetryjl

all: build

build:
	-rm -f Manifest.toml docs/Manifest.toml 
	-rm -rf .venv .venv.zip
	docker build -t ${DOCKER_IMAGE} .
	docker-compose build
	docker run --name ${DOCKER_IMAGE}-tmp ${DOCKER_IMAGE}
	docker cp ${DOCKER_IMAGE}-tmp:/workspace/jldev_poetry/.venv.zip .venv.zip
	unzip -q .venv.zip && rm .venv.zip
	docker stop ${DOCKER_IMAGE}-tmp && docker rm ${DOCKER_IMAGE}-tmp
	docker-compose run --rm shell julia --project=@. -e 'using Pkg; Pkg.instantiate()'
	docker-compose run --rm shell julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

# Excecute in docker container
web: docs
	julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate(); \
		include("docs/make.jl"); \
		using LiveServer; servedocs(host="0.0.0.0"); \
		'

test: jltest mypy pytest

jltest:
	docker-compose run --rm shell julia -e 'using Pkg; Pkg.activate("."); Pkg.test()'
mypy:
	docker-compose run --rm shell poe mypy
pytest:
	docker-compose run --rm shell poe test

clean:
	docker-compose down
	-rm -rf .venv .pytest_cache .mypy_cache .venv.zip
	-find $(CURDIR) -name "*.ipynb" -type f -delete
	-find $(CURDIR) -name "*.html" -type f -delete
	-find $(CURDIR) -name "*.gif" -type f -delete
	-find $(CURDIR) -name "*.ipynb_checkpoints" -type d -exec rm -rf "{}" +
	-find $(CURDIR) -name "__pycache__" -type d -exec rm -rf "{}" +
	-rm -f  Manifest.toml docs/Manifest.toml
	-rm -rf docs/build
