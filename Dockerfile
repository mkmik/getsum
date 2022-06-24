FROM golang:1.18@sha256:7c6cf4ca6d795b722d79b9a39f98175da1d63049feb999f28601e7985b2b61a3 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cd46126707e268844faec3aca618761c6728170e08ccf1f174dbc7ed7ca1b36a
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
