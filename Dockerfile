FROM golang:1.19@sha256:e71528e1017a5b76506d7437501fe3f5462519ad75f156dcfccc6e05d8f298df as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:9e6e03068e43358fd02a9bb967f5735587673c0ede0267b4d0d1cd0e0142bc08
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
