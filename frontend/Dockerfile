FROM node:latest
WORKDIR /app
COPY . .
RUN npm install
CMD ["npx", "http-server", "-p", "8080"]
