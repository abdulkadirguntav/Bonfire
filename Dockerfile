FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils libglu1-mesa clang cmake ninja-build pkg-config \
    libgtk-3-0 libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter && \
    /usr/local/flutter/bin/flutter --version

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
COPY . .

RUN flutter pub get

CMD ["flutter", "run", "-d", "linux"]
