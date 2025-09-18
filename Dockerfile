FROM node:18-alpine

WORKDIR /app

# Installa dipendenze di sistema
RUN apk add --no-cache libc6-compat openssl git python3 make g++

# Copia tutto
COPY . .

# Installa Bun globalmente
RUN npm install -g bun

# Installa dipendenze del progetto
RUN bun install

# Genera Prisma client
RUN bunx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Build tutti i packages prima del builder
RUN bun run build:packages || echo "Packages build failed, continuing..."

# Vai nella cartella builder e builda direttamente  
WORKDIR /app/apps/builder
RUN SKIP_ENV_VALIDATION=true bunx next build

# Torna alla root
WORKDIR /app

# Esponi porta
EXPOSE 3000

# Comando di avvio diretto
CMD ["node", "apps/builder/.next/standalone/apps/builder/server.js"]
