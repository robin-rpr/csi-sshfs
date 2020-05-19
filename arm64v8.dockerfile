FROM alpine:3 AS builder
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm64v8/golang:1.12-alpine3.9 AS  build-env

COPY --from=builder qemu-aarch64-static /usr/bin

RUN apk add --no-cache git

ENV CGO_ENABLED=0, GO111MODULE=on
WORKDIR /go/src/github.com/chr-fritz/csi-sshfs

ADD . /go/src/github.com/chr-fritz/csi-sshfs

RUN go mod download
RUN export BUILD_TIME=`date -R` && \
    export VERSION=`cat /go/src/github.com/chr-fritz/csi-sshfs/version.txt 2&> /dev/null` && \
    apk add --no-cache gcc libc-dev && \
    go build -o /csi-sshfs -ldflags "-X 'github.com/chr-fritz/csi-sshfs/pkg/sshfs.BuildTime=${BUILD_TIME}' -X 'github.com/chr-fritz/csi-sshfs/pkg/sshfs.Version=${VERSION}'" github.com/chr-fritz/csi-sshfs/cmd/csi-sshfs

FROM arm64v8/alpine:3.9

COPY --from=builder qemu-aarch64-static /usr/bin

RUN apk add --no-cache ca-certificates sshfs findmnt

COPY --from=build-env /csi-sshfs /bin/csi-sshfs

ENTRYPOINT ["/bin/csi-sshfs"]
CMD [""]
