# --- Stage 1: Build stage (Optimized for Pure Python) ---
FROM python:3.10-slim as builder

WORKDIR /app

# No apt-get needed because pymysql is pure python! 
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# --- Stage 2: Final runtime stage (ZERO TRUST) ---
FROM python:3.10-slim as runner

WORKDIR /app

# 1. Create a non-privileged user 'appuser'
RUN useradd -m appuser

# 2. Copy installed packages from builder to the new user's home
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

# 3. Copy application code with correct ownership
COPY --chown=appuser:appuser main.py .

# 4. Set the PATH so python can find the installed libraries in /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

# 5. Switch to the non-root user
USER appuser

EXPOSE 8000

# Start the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]