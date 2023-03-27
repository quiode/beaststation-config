FROM "node:18"

WORKDIR /app
EXPOSE 8010
COPY package.json package-lock.json ./
RUN npm ci
COPY server.js ./

CMD node server.js
