# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve
FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy your nginx.conf to a template location
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Copy files from build
COPY --from=build /app/dist/*/browser/ /usr/share/nginx/html/

# Cloud Run uses the $PORT variable. This command replaces $PORT in your config 
# and starts Nginx.
EXPOSE 8080
CMD ["sh", "-c", "envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]