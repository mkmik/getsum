FROM golang:1.18@sha256:df1bd77cbaba9a1f8848ef880eccc0dc9af94383dee229b5bfa8656a8794fc35 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a08c76433d484340bd97013b5d868edfba797fbf83dc82174ebd0768d12f491d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
