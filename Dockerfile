FROM golang:1.19@sha256:2d17ffd12a2cdb25d4a633ad25f8dc29608ed84f31b3b983427d825280427095 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:cefeffd60bd9127a3bb53dc83289cf1718a81710465d7377d9d25e8137b58c83
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
