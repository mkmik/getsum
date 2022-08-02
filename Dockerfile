FROM golang:1.18@sha256:c110edff9ce7d17d1e7267a898c3aa46fc788b2a1357c47bbbdf36ade06e9937 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a08c76433d484340bd97013b5d868edfba797fbf83dc82174ebd0768d12f491d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
