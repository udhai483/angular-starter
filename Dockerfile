# Use NGINX Alpine
FROM nginx:alpine

# Remove default NGINX html files
RUN rm -rf /usr/share/nginx/html/*

# Copy Angular build into NGINX html folder
COPY dist/angular-starter/browser/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]