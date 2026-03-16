# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN ./node_modules/.bin/ng build --configuration production

# Stage 2: Serve
FROM nginx:stable-alpine

# Clean default Nginx files
RUN rm -rf /etc/nginx/conf.d/*
RUN rm -rf /usr/share/nginx/html/*

# Copy your full nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Copy all built files
COPY --from=build /app/dist/ /usr/share/nginx/html/

# CRITICAL: Angular 21 often nests files in dist/project-name/browser.
# This finds that folder and moves the files to the root /usr/share/nginx/html/
RUN find /usr/share/nginx/html -type f -name "index.html" -exec dirname {} \; > /tmp/webroot.txt && \
    cp -r $(cat /tmp/webroot.txt)/* /usr/share/nginx/html/ || true

EXPOSE 8080

# Start Nginx using the explicit config file
CMD ["nginx", "-g", "daemon off;", "-c", "/etc/nginx/nginx.conf"]