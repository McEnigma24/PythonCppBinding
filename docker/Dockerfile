# Wspólna definicja obrazów — kontekst budowy: katalog nadrzędny (PythonCppBinding), patrz docker/*/compile.sh
#
# ==========================================
# 1. RUNTIME BASE — wspólne biblioteki (C++ runner + Python + natywny moduł)
# ==========================================
FROM ubuntu:22.04 AS runtime-base
ENV DEBIAN_FRONTEND=noninteractive \
    NEEDRESTART_MODE=a \
    TERM=xterm-256color

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends ca-certificates
RUN apt-get install -y --no-install-recommends libssl3
RUN apt-get install -y --no-install-recommends libcurl4
RUN apt-get install -y --no-install-recommends libprotobuf23
RUN apt-get install -y --no-install-recommends libgomp1
RUN apt-get install -y --no-install-recommends zlib1g
RUN rm -rf /var/lib/apt/lists/*

# ==========================================
# 2. DEV (kompilacja C++ w kontenerze)
# ==========================================
FROM runtime-base AS dev-env

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends tar
RUN apt-get install -y --no-install-recommends make
RUN apt-get install -y --no-install-recommends cmake
RUN apt-get install -y --no-install-recommends ninja-build
RUN apt-get install -y --no-install-recommends build-essential
RUN apt-get install -y --no-install-recommends gcc
RUN apt-get install -y --no-install-recommends g++
RUN apt-get install -y --no-install-recommends clang
RUN apt-get install -y --no-install-recommends libstdc++-11-dev
RUN apt-get install -y --no-install-recommends libomp-dev
RUN apt-get install -y --no-install-recommends libbenchmark-dev
RUN apt-get install -y --no-install-recommends libcurl4-openssl-dev
RUN apt-get install -y --no-install-recommends libssl-dev
RUN apt-get install -y --no-install-recommends libprotobuf-dev
RUN apt-get install -y --no-install-recommends protobuf-compiler
RUN apt-get install -y --no-install-recommends git
RUN apt-get install -y --no-install-recommends python3
RUN apt-get install -y --no-install-recommends python3-dev
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# ==========================================
# 3. BUILD (alias dev — CMD z projektu cpp)
# ==========================================
FROM dev-env AS builder
CMD ["/bin/sh", "-c", "exec ./docker/start.sh"]

# ==========================================
# 4. RUNNER — artefakty z cpp/build (ścieżki względem kontekstu = repo root)
# ==========================================
FROM runtime-base AS runner
WORKDIR /app

RUN mkdir -p exe log output input run_time_config build
COPY cpp/input /app/input
COPY cpp/run_time_config /app/run_time_config
COPY cpp/build/*.exe /app/build/
COPY cpp/build/*.a /app/build/
COPY cpp/build/*.so /app/build/
COPY cpp/build/*.dylib /app/build/
ENV LD_LIBRARY_PATH=/app/build
CMD ["/bin/sh", "-c", "exec /app/build/*.exe"]

# ==========================================
# 5. PYTHON — ta sama warstwa runtime-base + tylko Python
# ==========================================
FROM runtime-base AS python-runner
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y --no-install-recommends python3
RUN apt-get install -y --no-install-recommends python3-pip
RUN apt-get install -y --no-install-recommends python-is-python3
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["python3", "app/main.py"]
