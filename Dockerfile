FROM golang:1.21@sha256:488f80a0e519d211d6e4f6c0abdfef7cab08e749003a2993f66904bb28965886 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:1aae189e3baecbb4044c648d356ddb75025b2ba8d14cdc9c2a19ba784c90bfb9
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
