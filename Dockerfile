FROM erlang:20-alpine

RUN mkdir /buildroot
WORKDIR /buildroot
RUN apk add --no-cache openssl
RUN apk add git

COPY webRtp webRtp

WORKDIR webRtp
RUN rebar3 as prod release

FROM alpine:3.17

RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++

COPY --from=0 /buildroot/webRtp/_build/prod/rel/webRtp /webRtp

EXPOSE 8080
EXPOSE 8443

CMD [ "/webRtp/bin/webRtp", "foreground" ]
