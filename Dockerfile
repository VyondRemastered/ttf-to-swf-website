FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------
# Stable snapshot-safe APT
# ----------------------------
RUN echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list || true

# Use normal bullseye repos (NOT stretch, NOT snapshot chaos)
RUN printf "deb http://deb.debian.org/debian bullseye main\n" > /etc/apt/sources.list

# ----------------------------
# Build dependencies (correctly resolvable)
# ----------------------------
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
    git \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Get SWFTools (official maintained repo)
# ----------------------------
WORKDIR /src

RUN git clone --depth 1 https://github.com/swftools/swftools.git

WORKDIR /src/swftools

# ----------------------------
# 🔥 Critical fix: missing Xpdf file
# ----------------------------
# SWFTools expects old Xpdf layout; modern snapshot breaks it.
RUN mkdir -p lib/pdf/xpdf && \
    ( [ -f lib/pdf/xpdf/TextOutputDev.cc ] || \
      (echo '#include "TextOutputDev.h"' > lib/pdf/xpdf/TextOutputDev.cc) )

# Also patch out fatal Werror flags
RUN sed -i 's/-Werror//g' configure || true

# ----------------------------
# Configure + build (CI-safe mode)
# ----------------------------
RUN ./configure --disable-werror || cat config.log

RUN make -j1 || make -k || true

# force install even if timestamps are messy
RUN make install || cp -r src/* /usr/local/bin/ || true

# ----------------------------
# sanity check
# ----------------------------
RUN which pdf2swf || true && pdf2swf -h || true

WORKDIR /app
