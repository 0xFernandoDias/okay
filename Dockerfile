FROM node:14.17.6-alpine

WORKDIR /app

ENV PORT_ENV=80

COPY package*.json .

RUN npm install

COPY . .

EXPOSE 80

CMD ["npm", "start"]