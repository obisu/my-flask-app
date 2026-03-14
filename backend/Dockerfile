FROM python:3.10-slim

WORKDIR /app

RUN apt-get update && apt-get install -y curl && apt-get clean

COPY . /app/

RUN pip install --no-cache-dir -r app/requirements.txt

CMD ["gunicorn", "-b", "0.0.0.0:5000", "app.main:app"]

