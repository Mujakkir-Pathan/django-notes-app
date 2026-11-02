FROM node:18-alpine AS frontend
WORKDIR /app
COPY mynotes/package.json mynotes/package-lock.json ./
RUN npm ci
COPY mynotes/public ./public
COPY mynotes/src ./src
RUN npm run build

FROM python:3.9

WORKDIR /app/backend

COPY requirements.txt /app/backend
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install app dependencies
RUN pip install mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/backend
COPY --from=frontend /app/build ./mynotes/build

EXPOSE 8000
CMD ["python3", "manage.py", "runserver", "0.0.0.0:8000"]
