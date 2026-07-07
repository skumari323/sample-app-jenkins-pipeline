# Step 1: Use the official NGINX image as the base image
FROM nginx:latest

# Step 2: Remove the default NGINX website
RUN rm -rf /usr/share/nginx/html/*

# Step 3: Copy our website files into the NGINX web root
COPY app/index.html /usr/share/nginx/html/

# Step 4: Copy the custom NGINX configuration
COPY app/nginx.conf /etc/nginx/conf.d/default.conf

# Step 5: Expose port 80
EXPOSE 80

# Step 6: Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]