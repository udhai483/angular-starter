# Stage 1: Build
FROM node:22-alpine AS build
# Increase memory limit for Angular 21 build
ENV NODE_OPTIONS="--max-old-space-size=4096"
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
# Run build - if this fails, the logs will now show why
RUN npm run build -- --configuration production

# Stage 2: Serve
FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# DEBUG & COPY: 
# This command looks for the 'index.html' regardless of which subfolder it's in
# and copies it to the nginx folder.
COPY --from=build /app/dist/ /temp_dist/
RUN find /temp_dist/ -name "index.html" -exec dirname {} \; > /folder_path.txt && \
    cp -r $(cat /folder_path.txt)/* /usr/share/nginx/html/

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]