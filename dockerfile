FROM python:3.9
WORKDIR /app
COPY ./health.py /app
RUN pip install --no-cache-dir Flask
EXPOSE 8080
CMD ["python", "health.py"]

