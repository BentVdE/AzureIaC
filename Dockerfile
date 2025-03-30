# Use a light Python image
FROM python:3.8-slim

# Install git and any build tools needed
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/gurkanakdeniz/example-flask-crud.git

# Set working directory
WORKDIR /example-flask-crud

# Upgrade pip, install required packages
RUN pip install --upgrade pip && pip install -r requirements.txt

# Set the Flask application environment variable
ENV FLASK_APP=crudapp.py

# Expose port 80
EXPOSE 80 

# Initialize database, run migrations, start the app
RUN flask db init && flask db migrate -m "entries table" && flask db upgrade

# Start Flask, bind to all interfaces on port 80
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]