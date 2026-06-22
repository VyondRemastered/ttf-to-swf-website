FROM debian:bullseye

# Use Debian archive snapshot where SWFTools still exists
RUN echo "deb http://snapshot.debian.org/archive/debian/20210101T000000Z bullseye main" > /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    swftools \
    ca-certificates \
    nodejs \
    npm

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
