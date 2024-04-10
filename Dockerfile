FROM golang:1.21@sha256:458d205f35b476ccb2824b38850989da68eb0534489b76db3862caa25592db7f as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9bc3117a99c731a41200a28774405125cb6fbda1819f4a1af88bd3bfad5dcf32
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
