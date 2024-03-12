FROM golang:1.21@sha256:bc4a2530173d55db443a3f804268509e18a59046160138ae5f36fba8d9847724 as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:280852156756ea3f39f9e774a30346f2e756244e1f432aea3061c4ac85d90a66
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
