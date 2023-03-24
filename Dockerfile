FROM golang:1.20@sha256:41a6cb5f24c205e78cf153ed1d5328f2279e750d3cde797f545d06921fa90101 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:2c50b819aa3bfaf6ae72e47682f6c5abc0f647cf3f4224a4a9be97dd30433909
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
