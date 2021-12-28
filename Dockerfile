FROM julia:1.7.1

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    python3 \
    python3-dev \
    python3-distutils \
    python3-venv \
    python3-pip \
    curl \
    ca-certificates \
    git \
    zip \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Dependencies for development
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    htop \
    nano \
    openssh-server \
    tig \
    tree \
    && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

# Install NodeJS to build extensions of JupyterLab
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* # clean up

ENV PATH=${HOME}/.local/bin:${PATH}
RUN curl -sSL https://install.python-poetry.org | python3 -

WORKDIR /workspace/jldev_poetry
COPY pyproject.toml poetry.toml poetry.lock /workspace/jldev_poetry/
RUN poetry install --no-root && echo Done
RUN pip3 install poethepoet

SHELL ["poetry", "run", "/bin/bash", "-c"]

# Install/enable extension for JupyterLab users
RUN jupyter labextension install @z-m-k/jupyterlab_sublime --no-build && \
    #jupyter labextension install @ryantam626/jupyterlab_code_formatter --no-build && \
    #jupyter serverextension enable --py jupyterlab_code_formatter && \
    jupyter labextension install @hokyjack/jupyterlab-monokai-plus --no-build && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf ~/.cache/yarn && \
    rm -rf ~/.node-gyp && \
    echo Done

RUN mkdir -p ${HOME}/.local ${HOME}/.jupyter
# Set color theme Monokai++ by default
RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension && \
    echo '{"theme": "Monokai++"}' >> \
    ${HOME}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension && \
    echo '{"codeCellConfig": {"lineNumbers": true}}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings

RUN mkdir -p ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension && \
    echo '{"shortcuts": [{"command": "runmenu:restart-and-run-all", "keys": ["Alt R"], "selector": "[data-jp-code-runner]"}]}' \
    >> ${HOME}/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/shortcuts.jupyterlab-settings

RUN julia -e 'using Pkg; Pkg.add(["Revise", "OhMyREPL", "Documenter", "LiveServer", "Pluto", "PlutoUI"])'
RUN julia -e '\
              using Pkg; \
              Pkg.add("IJulia"); \
              using IJulia; \
              installkernel("Julia");\
              ' && \
    echo "Done"

ENV JULIA_PROJECT "@."
WORKDIR /workspace/jldev_poetry

COPY ./playground/notebook /workspace/jldev_poetry
COPY ./playground/pluto /workspace/jldev_poetry
COPY ./docs/Project.toml /workspace/jldev_poetry/docs
COPY ./src /workspace/jldev_poetry/src
COPY ./Project.toml /workspace/jldev_poetry

ENV PATH=${PATH}:${HOME}/.local/bin

USER root
RUN chown -R ${NB_UID} ${HOME}
RUN chown -R ${NB_UID} /workspace/
USER ${USER}

RUN poetry install && zip -r .venv.zip .venv

RUN rm -f Manifest.toml && julia --project=/workspace/jldev_poetry -e '\
    using InteractiveUtils; \
    ENV["PYTHON"] = "/workspace/jldev_poetry/.venv/bin/python3"; \
    ENV["JUPYTER"] = "/workspace/jldev_poetry/.venv/bin/jupyter"; \
    using Pkg; \
    Pkg.instantiate(); \
    Pkg.precompile(); \
    versioninfo(); \
    ' && \
    echo Done

USER ${USER}
EXPOSE 8000
EXPOSE 8888
EXPOSE 1234

RUN echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc

CMD ["julia"]
