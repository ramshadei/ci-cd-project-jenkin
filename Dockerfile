# Use the official Nginx image as the base
FROM nginx:latest

# Remove the default server definition
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom server configurations
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the static content
COPY app.py /usr/share/nginx/html/app.py
# Expose ports
EXPOSE 8090