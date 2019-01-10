FROM elixir:1.7.4 as jeopardy_dev
RUN useradd jeopardy

RUN apt-get update && apt-get install -y inotify-tools

ENV HOME=/code
WORKDIR /code/jeopardy/backend
RUN chown jeopardy: /code

USER jeopardy

EXPOSE 4000

FROM elixir:1.7.4 as jeopardy_release

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config ./config

RUN mix deps.get
RUN mix deps.compile

# You should place a production config here
# and it will be copied into the release build
COPY config/config.exs rel/config/config.exs
COPY config/prod.exs rel/config/prod.exs

RUN mix release.init
RUN mix release --no-tar --verbose

FROM erlang:21 as jeopardy_prod

RUN mkdir /app  && chown -R nobody: /app
WORKDIR /app
USER nobody
ENV HOME=/app

COPY --from=jeopardy_release /app/_build/prod/rel/jeopardy ./

## EXPOSE $HTTP_PORT $BEAM_PORT $ERL_EPMD_PORT

FROM jeopardy_prod
