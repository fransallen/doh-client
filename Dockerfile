FROM golang:1.13-alpine AS doh-build

RUN apk add --no-cache bind-tools git make jq curl

WORKDIR /src

RUN DOH_VERSION_LATEST="$(curl -s https://api.github.com/repos/m13253/dns-over-https/tags|jq -r '.[0].name')" \
    && wget "https://github.com/m13253/dns-over-https/archive/${DOH_VERSION_LATEST}.zip" -O doh.zip \
    && unzip doh.zip \
    && rm doh.zip \
    && cd dns-over-https* \
    && make doh-client/doh-client \
    && mkdir /dist \
    && cp doh-client/doh-client /dist/doh-client \
    && echo ${DOH_VERSION_LATEST} > /dist/doh-client.version

FROM alpine:latest

COPY --from=doh-build /dist /client

ADD doh-client.conf /client/doh-server.conf

EXPOSE 5380/tcp
EXPOSE 5380/udp

CMD [ "/client/doh-client", "-conf", "/client/doh-client.conf" ]