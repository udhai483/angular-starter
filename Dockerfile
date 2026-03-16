# Stage 1: Build Angular app
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci --legacy-peer-deps

COPY . .
RUN ./node_modules/.bin/ng build --configuration production

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine

RUN rm -rf /etc/nginx/conf.d/*
RUN rm -rf /usr/share/nginx/html/*

COPY nginx.conf /etc/nginx/conf.d/default.conf

# IMPORTANT:
# Replace this with your real Angular build output path from angular.json
COPY --from=build /app/dist/angular-starter-app/browser/ /usr/share/nginx/html/

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]