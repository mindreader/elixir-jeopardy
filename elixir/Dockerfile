FROM erlang:21 as elixir

ARG ELIXIR_VERSION
ARG ELIXIR_DOWNLOAD_SHA256

# elixir expects utf8.
ENV LANG=C.UTF-8

RUN set -xe \
  && ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION#*@}.tar.gz" \
  && curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
  && echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
  && mkdir -p /usr/local/src/elixir \
  && tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
  && rm elixir-src.tar.gz \
  && cd /usr/local/src/elixir \
  && make install clean

FROM elixir as jeopardy-release

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
RUN find /app
RUN mix release --no-tar --verbose

FROM erlang:21 as jeopardy-prod

RUN mkdir /app  && chown -R nobody: /app
WORKDIR /app
USER nobody
ENV HOME=/app

COPY --from=jeopardy-release /app/_build/prod/rel/jeopardy ./

## EXPOSE $HTTP_PORT $BEAM_PORT $ERL_EPMD_PORT

FROM elixir as jeopardy-dev
ENV HOME=/code
WORKDIR /code/jeopardy

FROM jeopardy-prod
