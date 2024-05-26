# Stage 1: Build
FROM python:3.9-alpine as builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev
RUN apk add --no-cache --virtual .build-deps \
    g++ \
    musl-dev \
    linux-headers

# Create a virtual environment and install dependencies
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

COPY requirements.txt .
RUN /app/venv/bin/pip install --upgrade pip
RUN /app/venv/bin/pip install -r requirements.txt

# Stage 2: Final
FROM python:3.9-alpine

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/venv /app/venv
COPY app.py .

ENV PATH="/app/venv/bin:$PATH"

EXPOSE 8000

CMD ["/app/venv/bin/uvicorn", "--host", "0.0.0.0", "--port", "8000", "app:app"]
