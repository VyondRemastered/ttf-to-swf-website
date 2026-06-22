FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# -----------------------------
# Build deps
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    ca-certificates \
    autoconf \
    automake \
    libtool \
    pkg-config \
    bison \
    flex \
    gawk \
    patch \
    make \
    gcc \
    g++ \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libfontconfig1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# -----------------------------
# SWFTools source
# -----------------------------
RUN wget https://github.com/swftools/swftools/archive/refs/tags/v0.9.2.tar.gz \
    && tar -xzf v0.9.2.tar.gz \
    && mv swftools-0.9.2 swftools

WORKDIR /src/swftools

# -----------------------------
# Build flags for legacy C
# -----------------------------
ENV CFLAGS="-O2 -fcommon -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types"
ENV CXXFLAGS="-O2 -fcommon"

# -----------------------------
# HARD REMOVE PDF SYSTEM (IMPORTANT)
# -----------------------------

# 1. remove pdf module entirely (prevents TextOutputDev errors)
RUN rm -rf lib/pdf

# 2. remove pdf references from makefiles
RUN find . -name Makefile.in -exec sed -i \
    -e '/pdf/d' \
    -e '/PDF/d' \
    {} \; || true

# 3. regenerate build system
RUN autoreconf -fi || true

# -----------------------------
# Configure (no pdf dependency)
# -----------------------------
RUN ./configure \
    --prefix=/usr/local \
    --disable-werror

# -----------------------------
# Build
# -----------------------------
RUN make -j1

# -----------------------------
# Install
# -----------------------------
RUN make install

# -----------------------------
# Verify
# -----------------------------
RUN swfc -h || true
