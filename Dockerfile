# Use a base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /app

# Copy application code to the container
COPY app.py /app/app.py

# Install dependencies if needed
# RUN pip install -r requirements.txt

# Command to run your app
CMD ["python", "app.py"]