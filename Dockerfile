FROM golang:1.19@sha256:598ccf410cffad697f77ae228b51e6485817521e13bb902c5b56d5e27cb8d018 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:b9c7d9344b1d95e57f7bd17a90137d8351541d06d80f2596dd0de6c2a4aae6a3
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
