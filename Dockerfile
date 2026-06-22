FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libgif-dev \
    wget

# download SWFTools source
RUN wget https://www.swftools.org/swftools-0.9.2.tar.gz \
    && tar -xzf swftools-0.9.2.tar.gz \
    && cd swftools-0.9.2 \
    && ./configure \
    && make \
    && make install

# Node setup
RUN apt-get install -y nodejs npm

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000
CMD ["npm", "start"]
