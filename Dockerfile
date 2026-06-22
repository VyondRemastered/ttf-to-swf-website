FROM debian:stretch

RUN printf "deb http://archive.debian.org/debian stretch main\ndeb http://archive.debian.org/debian-security stretch/updates main\n" > /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    ca-certificates \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    zlib1g-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libfontconfig1-dev \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/swftools/swftools/archive/refs/tags/v0.9.2.tar.gz \
    && tar -xzf v0.9.2.tar.gz \
    && cd swftools-* \
    && ./configure --disable-werror \
    && make -j1 \
    && make install

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

CMD ["npm", "start"]FROM debian:stretch

# Archive repos (required for EOL Debian)
RUN printf "deb http://archive.debian.org/debian stretch main\ndeb http://archive.debian.org/debian-security stretch/updates main\n" > /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    ca-certificates \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libgif-dev \
    zlib1g-dev \
    libx11-dev \
    libxpm-dev \
    libxt-dev \
    libfontconfig1-dev \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*
    
RUN wget https://github.com/swftools/swftools/archive/refs/tags/v0.9.2.tar.gz \
    && tar -xzf v0.9.2.tar.gz \
    && ls -la \
    && cd swftools-* \
    && ./configure --disable-werror \
    && make -j1 \
    && make install

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

CMD ["npm", "start"]
