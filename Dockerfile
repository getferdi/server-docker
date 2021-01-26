FROM node:lts-alpine as build

ARG FERDI_RELEASE=master

WORKDIR /code

RUN ["apk", "add", "--no-cache", "wget", "tar", "python", "make", "gcc", "g++", "libc-dev", "sqlite-dev"]

RUN set -e; \
    wget -q "https://github.com/getferdi/server/archive/${FERDI_RELEASE}.tar.gz" -O /tmp/ferdi-server.tar.gz; \
    tar --strip-components=1 -xzf /tmp/ferdi-server.tar.gz; \
    rm /tmp/ferdi-server.tar.gz

RUN ["npm", "ci", "--production", "--build-from-source", "--sqlite=/usr/local"]

FROM node:lts-alpine

WORKDIR /app
LABEL maintainer="xthursdayx"

ENV HOST=0.0.0.0 PORT=3333

RUN ["apk", "add", "--no-cache", "sqlite-libs", "curl"]

COPY --from=build /code /app
RUN ["touch", ".env"]

HEALTHCHECK CMD curl -sSf http://localhost:${PORT}/health

COPY entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
