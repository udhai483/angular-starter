# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve
FROM nginx:stable-alpine

# Remove default configs and the template folder to be safe
RUN rm -rf /etc/nginx/conf.d/* /etc/nginx/templates

# Copy your nginx.conf directly
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Direct copy using wildcard to handle Angular 21's structure
COPY --from=build /app/dist/*/browser/ /usr/share/nginx/html/

# Cloud Run requires the container to listen on 8080
EXPOSE 8080

# Run nginx as the main process
CMD ["nginx", "-g", "daemon off;"]