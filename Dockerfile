FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    libjpeg-turbo8 \
    libfreetype6 \
    libpng12-0 \
    zlib1g

# download precompiled SWFTools binary bundle
RUN wget https://github.com/itsmattch/swftools-binaries/raw/main/swftools-linux.tar.gz \
    && tar -xzf swftools-linux.tar.gz \
    && mv swftools /usr/local/swftools \
    && ln -s /usr/local/swftools/bin/* /usr/local/bin/

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

CMD ["npm", "start"]
