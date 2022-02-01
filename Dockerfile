ARG MIX_ENV="prod"

FROM hexpm/elixir:1.13.2-erlang-23.3.4.11-alpine-3.15.0 AS build

RUN apk add --no-cache build-base git python3 curl

WORKDIR /bookkeepr_api

RUN mix local.hex --force && \
    mix local.rebar --force

ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV

RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/

RUN mix deps.compile

COPY priv priv
COPY lib lib

RUN mix compile

COPY config/runtime.exs config/
RUN mix release

FROM alpine:3.15.0 AS app
ARG MIX_ENV

RUN apk add --no-cache libstdc++ openssl ncurses-libs
ENV USER="elixir"

WORKDIR "/home/${USER}/bookkeepr_api"

RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"

USER "${USER}"

COPY --from=build --chown="${USER}":"${USER}" /bookkeepr_api/_build/"${MIX_ENV}"/rel/bookkeepr ./
COPY entrypoint.sh .

CMD ["bash", "entyrpoint.sh"]
