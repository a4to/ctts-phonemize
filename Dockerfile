FROM debian:bullseye as build
ARG TARGETARCH
ARG TARGETVARIANT

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
        build-essential cmake ca-certificates curl pkg-config git

WORKDIR /build

COPY ./ ./
RUN cmake -Bbuild -DCMAKE_INSTALL_PREFIX=install
RUN cmake --build build --config Release
RUN cmake --install build

# Do a test run
RUN ./build/ctts_phonemize --help

# Build .tar.gz to keep symlinks
WORKDIR /dist
RUN mkdir -p ctts_phonemize && \
    cp -dR /build/install/* ./ctts_phonemize/ && \
    tar -czf "ctts-phonemize_${TARGETARCH}${TARGETVARIANT}.tar.gz" ctts_phonemize/

# -----------------------------------------------------------------------------

FROM scratch

COPY --from=build /dist/ctts-phonemize_*.tar.gz ./
