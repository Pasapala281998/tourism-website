# Use lightweight Nginx image to serve static files
FROM nginx:alpine

# Copy all website files to Nginx default directory
COPY . /usr/share/nginx/html/

# Copy custom Nginx config (optional)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
