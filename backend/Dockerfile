FROM elixir:1.7.4 as dev
RUN useradd jeopardy

RUN apt-get update && apt-get install -y inotify-tools

ENV HOME=/code
WORKDIR /code/jeopardy/backend
RUN chown jeopardy: /code

USER jeopardy

EXPOSE 4000

FROM elixir:1.7.4 as release

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config ./config

RUN mix deps.get
RUN mix deps.compile

COPY rel rel/
COPY lib lib/
COPY priv priv/
COPY config/config.exs rel/etc/config.exs
COPY config/prod.exs rel/etc/prod.exs

RUN mix release --no-tar --verbose --env=prod

FROM elixir:1.7.4 as prod

# RUN mkdir /app  && chown -R nobody: /app
WORKDIR /app
# USER nobody
ENV HOME=/app

COPY --from=release /app/_build/prod/rel/jeopardy ./

EXPOSE 80
