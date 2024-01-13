FROM erlang:21-alpine

RUN mkdir /buildroot
WORKDIR /buildroot
RUN apk add --no-cache openssl git make

COPY webRtp webRtp

WORKDIR webRtp
RUN DEBUG=1 rebar3 get-deps
RUN DEBUG=1 rebar3 as prod release

FROM alpine:3.15

RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs && \
    apk add --no-cache libstdc++ && \
    apk add --no-cache make && \
    apk add --no-cache gcc && \
    apk add --no-cache ortp-dev && \
    apk add --no-cache libc-dev && \
    apk add --no-cache bctoolbox-dev 

COPY --from=0 /buildroot/webRtp/_build/prod/rel/webRtp /webRtp
COPY --from=0 /buildroot/webRtp/apps/webRtp/priv /webRtp/priv
COPY --from=0 /buildroot/webRtp/apps/webRtp/c_src /webRtp/c_src


EXPOSE 8080
EXPOSE 8443

RUN make -C webRtp/c_src
CMD [ "/webRtp/bin/webRtp", "foreground" ]
