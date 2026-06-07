# ---- base image ----
# Debian 11 (Bullseye) has full Chrome dependency support out of the box.
FROM python:3.11-slim-bullseye

# Install wget/xvfb, then pull & install the latest stable Chrome .deb
# (Chrome's postinst script handles all its own library deps via apt -f)
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        gnupg \
        xvfb \
    && wget -q -O /tmp/chrome.deb \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps before copying source (better layer caching)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY solver.py service.py clientsend.py ./

# ---- runtime config ----
ENV PORT=8191 \
    MAX_WORKERS=4 \
    TS_PROFILE_DIR=/tmp/ts_profile \
    CHROME_PATH=/usr/bin/google-chrome-stable

EXPOSE 8191

CMD ["python", "service.py"]
