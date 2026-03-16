# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
# Explicitly use the local CLI to build
RUN ./node_modules/.bin/ng build --configuration production

# IMPORTANT: Check if dist was actually created
RUN ls -la dist/

# Stage 2: Serve
FROM nginx:stable-alpine
RUN rm -rf /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Use a wildcard to find the folder regardless of the name
COPY --from=build /app/dist/ /usr/share/nginx/html/

# Move files to the root of the nginx html folder
RUN [ -d /usr/share/nginx/html/angular-starter/browser ] && mv /usr/share/nginx/html/angular-starter/browser/* /usr/share/nginx/html/ || true
RUN [ -d /usr/share/nginx/html/browser ] && mv /usr/share/nginx/html/browser/* /usr/share/nginx/html/ || true

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]