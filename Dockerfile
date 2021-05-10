ARG UBUNTU_IMAGE=docker.io/library/ubuntu:20.04@sha256:8bce67040cd0ae39e0beb55bcb976a824d9966d2ac8d2e4bf6119b45505cee64
ARG COMPILERS_IMAGE=docker.io/cilium/image-compilers:c1ba0665b6f9f012d014a642d9882f7c38bdf365@sha256:01c7c957e9b0fc200644996c6bedac297c98b81dea502a3bc3047837e67a7fcb

FROM ${COMPILERS_IMAGE} as builder
ADD . /src/iproute2
WORKDIR /src/iproute2
RUN ./configure \
	&& make clean \
 	&& make -j "$(getconf _NPROCESSORS_ONLN)" \
	&& strip ip/ip tc/tc misc/ss \
    && mkdir -p /out/linux/bin \
    && cp ip/ip tc/tc misc/ss /out/linux/bin

FROM ${UBUNTU_IMAGE} as rootfs
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=SC2215
RUN apt-get update \
    && apt-get install -y --no-install-recommends libelf1 libmnl0 \
    && apt-get purge --auto-remove -y
COPY --from=builder /out/linux/bin /usr/local/bin