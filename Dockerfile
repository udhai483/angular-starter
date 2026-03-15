# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app

# Modern Angular 21/Node 22 setup
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve
FROM nginx:alpine

# 1. Clear the default Nginx config to avoid port 80 conflicts
RUN rm /etc/nginx/conf.d/default.conf

# 2. Copy your custom config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 3. Path Correction: 
# We copy from the dist/angular-starter/browser folder.
# If this path is wrong, the build will now fail with a clear error here.
COPY --from=build /app/dist/angular-starter/browser /usr/share/nginx/html

# 4. Verification: This confirms index.html is in the right place
RUN ls -la /usr/share/nginx/html/index.html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]