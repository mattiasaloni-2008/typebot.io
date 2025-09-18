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

# Genera Prisma client (già fatto dal postinstall ma assicuriamoci)
RUN bunx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Build di tutti i packages necessari usando turbo
ENV SKIP_ENV_VALIDATION=true
ENV CI=true
RUN bunx turbo build --filter=builder^... --filter=builder

# Esponi porta
EXPOSE 3000

# Comando di avvio diretto
CMD ["node", "apps/builder/.next/standalone/apps/builder/server.js"]
