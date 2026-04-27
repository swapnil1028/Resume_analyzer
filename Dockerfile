FROM python:3.10-slim

WORKDIR /app

# Install system dependencies: Tesseract OCR, Poppler, Chromium for Selenium scraping
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    poppler-utils \
    libpoppler-dev \
    chromium \
    chromium-driver \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libnspr4 \
    libnss3 \
    lsb-release \
    xdg-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Chromium path for Selenium
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROMEDRIVER_PATH=/usr/bin/chromedriver

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download spaCy NLP model at build time (avoids runtime download)
RUN python -m spacy download en_core_web_sm

# Download NLTK data at build time
RUN python -c "import nltk; nltk.download('stopwords'); nltk.download('punkt'); nltk.download('averaged_perceptron_tagger'); nltk.download('wordnet')"

# Copy the rest of the application
COPY . .

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Render injects $PORT dynamically; default to 8501 for local
ENV PORT=8501

# Expose port
EXPOSE $PORT

# Start Streamlit using dynamic port from Render
CMD streamlit run app.py --server.port=$PORT --server.address=0.0.0.0 --server.headless=true