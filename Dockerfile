FROM golang:1.18@sha256:f3d3d6903d92ff29a3b87f55a97a72cb6828055161eb10cfd20772dbbf346770 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:a08c76433d484340bd97013b5d868edfba797fbf83dc82174ebd0768d12f491d
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
