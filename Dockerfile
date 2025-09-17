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

# Genera Prisma client
RUN bunx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Build solo del builder senza typecheck
ENV SKIP_ENV_VALIDATION=true
ENV CI=true
WORKDIR /app/apps/builder
RUN bun run build:only
WORKDIR /app

# Se il comando sopra non esiste, prova questo:
# RUN cd apps/builder && bun run next build

# Crea l'entrypoint script
RUN mkdir -p scripts && \
    echo '#!/bin/sh\nset -e\necho "Starting Typebot Builder..."\nif [ "$DATABASE_URL" ]; then\n  echo "Running database migrations..."\n  bunx prisma migrate deploy --schema=packages/prisma/postgresql/schema.prisma || echo "Migration failed or not needed"\nfi\nexec node apps/builder/.next/standalone/apps/builder/server.js' > scripts/builder-entrypoint.sh && \
    chmod +x scripts/builder-entrypoint.sh

# Esponi porta
EXPOSE 3000

# Avvia l'applicazione
ENTRYPOINT ["./scripts/builder-entrypoint.sh"]
