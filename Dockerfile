FROM oven/bun:1.2.21-alpine

# Installa Node.js (necessario per alcuni packages)
RUN apk add --no-cache \
    nodejs \
    npm \
    libc6-compat \
    openssl \
    git \
    python3 \
    make \
    g++

WORKDIR /app

# Copia i file di configurazione
COPY package.json bun.lockb* ./
COPY apps/builder/package.json ./apps/builder/
COPY packages/*/package.json ./packages/*/

# Installa dipendenze con Bun
RUN bun install

# Copia il codice
COPY . .

# Build dell'applicazione
RUN bun run build --filter=apps/builder

# Genera Prisma client
RUN bunx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Esponi porta
EXPOSE 3000

# Comando di avvio con Node (Next.js funziona meglio con Node)
CMD ["node", "apps/builder/.next/standalone/apps/builder/server.js"]
