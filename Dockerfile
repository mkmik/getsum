FROM golang:1.19@sha256:5bbf6bd42f985a710d9a918f4ddf71825fcbf651ea5ac5a54474c79650933a2d as builder

WORKDIR /src

COPY . .

RUN go build ./cmd/getsumweb

# Ideally we could use the "static" flavour but let's first start with the base flavour (which has glibc).
FROM gcr.io/distroless/base@sha256:c4ad5921a0ba40c1726559fbd39cc308e2658a2ce86cc997afb80f1090c71ed6
MAINTAINER Marko Mikulicic <mmikulicic@gmail.com>
COPY --from=builder /src/getsumweb /usr/local/bin/

EXPOSE 8080
ENTRYPOINT ["getsumweb"]
