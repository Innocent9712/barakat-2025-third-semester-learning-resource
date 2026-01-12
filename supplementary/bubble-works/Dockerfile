FROM node:20-alpine

WORKDIR /app

COPY package*.json .

RUN npm install

COPY index.js deploy.sh /app/

# CMD ["bash", "/app/deploy.sh"]
CMD ["npm", "start"]
