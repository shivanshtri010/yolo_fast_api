# Stage 1: Build
FROM python:3.10-alpine as builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev make

# Create a virtual environment and install dependencies
RUN python -m venv venv
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt .

# Upgrade pip and install dependencies, adding verbose output for debugging
RUN /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install -r requirements.txt --verbose

# Stage 2: Final
FROM python:3.10-alpine

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/venv /app/venv
COPY app.py /app/app.py

ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "--host", "0.0.0.0", "--port", "8000", "app:app"]
