# Stage 1: Build
FROM node:22-alpine AS build
WORKDIR /app

# Step 1: Install dependencies
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Step 2: Build the app
COPY . .
RUN npx ng build --configuration production

# Step 3: Debug (This will show us where the files actually went in the logs)
RUN ls -R dist/

# Stage 2: Serve
FROM nginx:stable-alpine
RUN rm -rf /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Step 4: The "Safe" Copy
# This copies everything in dist to a temp folder, then we move the browser files
COPY --from=build /app/dist/ /usr/share/nginx/html/

# We move files from the subfolders (like 'angular-starter/browser') to the root
RUN mv /usr/share/nginx/html/*/browser/* /usr/share/nginx/html/ || \
    mv /usr/share/nginx/html/browser/* /usr/share/nginx/html/ || true

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]