# Środowisko uruchomieniowe Pythona — Ubuntu 22.04 jak w cpp/Dockerfile (spójne libc / Python 3.10).
FROM ubuntu:22.04 AS python-runner
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends ca-certificates
RUN apt-get install -y --no-install-recommends python3
RUN apt-get install -y --no-install-recommends python3-pip
RUN apt-get install -y --no-install-recommends python-is-python3
RUN apt-get install -y --no-install-recommends libgomp1
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Moduł natywny jest montowany z hosta (../cpp/build); PYTHONPATH ustawia run.sh
CMD ["python3", "app/main.py"]
