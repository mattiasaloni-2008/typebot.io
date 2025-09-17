# Usa il Dockerfile originale ma crea gli entrypoint mancanti
FROM node:18-alpine

WORKDIR /app

# Installa dipendenze di sistema
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    git \
    python3 \
    make \
    g++

# Installa Bun
RUN npm install -g bun

# Copia tutto il progetto
COPY . .

# Installa dipendenze
RUN bun install

# Build dell'applicazione builder
RUN bun run build --filter=builder

# Genera Prisma client
RUN bunx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Crea l'entrypoint script mancante
RUN mkdir -p scripts && \
    echo '#!/bin/sh\nset -e\necho "Starting Typebot Builder..."\nif [ "$DATABASE_URL" ]; then\n  echo "Running database migrations..."\n  bunx prisma migrate deploy --schema=packages/prisma/postgresql/schema.prisma || echo "Migration failed or not needed"\nfi\nexec node apps/builder/.next/standalone/apps/builder/server.js' > scripts/builder-entrypoint.sh && \
    chmod +x scripts/builder-entrypoint.sh

# Esponi porta
EXPOSE 3000

# Avvia l'applicazione
ENTRYPOINT ["./scripts/builder-entrypoint.sh"]
