# ./Dockerfile

# Extend from the official Elixir image.
FROM elixir:latest
EXPOSE 4000

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
RUN apt-get update && \
    # for listening to the file system for live-reload:
    apt-get install -y inotify-tools && \
    # Install Hex package manager.
    # By using `--force`, we don’t need to type “Y” to confirm the installation.
    mix local.hex --force && \
    mix local.rebar --force

# mix phx.new hello --> create new project called hello

COPY . /app
WORKDIR /app

# Compile the project.
RUN mix deps.get && mix do compile

# CMD [ "/app/entrypoint.sh" ]