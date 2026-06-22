FROM node:20

RUN apt-get update && apt-get install -y swftools

WORKDIR /app

COPY package.json .
RUN npm install

COPY . .

RUN mkdir -p uploads

EXPOSE 3000

CMD ["npm", "start"]
