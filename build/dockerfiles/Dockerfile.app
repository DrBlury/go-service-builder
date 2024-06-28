FROM golang:alpine AS builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    GOOS=linux \
    GOARCH=amd64 \
    CGO_ENABLED=0

WORKDIR /build

# Copy and download dependency using go mod
ADD ./src/go.* /build/
RUN go mod download

# Copy sources to build container
ADD ./src /build/

# Build the app
RUN go build -a -tags musl -ldflags="-X 'main.version=v0.0.1' -X 'main.buildUser=$(id -u -n)' -X 'main.buildDate=$(date)'" -o /build/go-service-builder
######################################
FROM alpine:3
LABEL AUTHOR="Julian Bensch (Linuxcode)"

# install curl for healthcheck
RUN apk --no-cache add curl

# Essentials
RUN apk add -U tzdata
ENV TZ=Europe/Berlin
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

USER nobody
COPY --from=builder --chown=nobody /build/go-service-builder /custom/go-service-builder
ENTRYPOINT [ "/custom/go-service-builder" ]
