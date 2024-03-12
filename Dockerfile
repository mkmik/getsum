FROM golang:1.21@sha256:510344038708d4fa0855a15bb8cd0f91778b366059bbcc38d2371828a0abd0af as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:280852156756ea3f39f9e774a30346f2e756244e1f432aea3061c4ac85d90a66
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
