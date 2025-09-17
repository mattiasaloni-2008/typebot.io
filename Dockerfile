FROM node:18-alpine

# Installa Yarn e dipendenze di sistema
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    git \
    python3 \
    make \
    g++ \
    && npm install -g yarn

WORKDIR /app

# Copia i file di configurazione Yarn
COPY package.json yarn.lock* ./
COPY apps/builder/package.json ./apps/builder/
COPY packages/*/package.json ./packages/*/

# Installa dipendenze con Yarn (supporta workspace)
RUN yarn install --frozen-lockfile

# Copia tutto il codice
COPY . .

# Build dell'applicazione
RUN yarn workspace apps/builder build

# Genera Prisma client
RUN yarn prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Esponi porta
EXPOSE 3000

# Comando di avvio
CMD ["yarn", "workspace", "apps/builder", "start"]
