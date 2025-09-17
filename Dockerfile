FROM node:18-alpine

# Installa dipendenze di sistema
RUN apk add --no-cache \
    libc6-compat \
    openssl \
    git \
    python3 \
    make \
    g++

WORKDIR /app

# Copia package.json files
COPY package*.json ./
COPY apps/builder/package*.json ./apps/builder/
COPY packages/*/package*.json ./packages/*/
COPY packages/*/package.json ./packages/*/

# Installa dipendenze
RUN npm install --legacy-peer-deps

# Copia il codice
COPY . .

# Build dell'applicazione
RUN npm run build --workspace=apps/builder

# Genera Prisma client
RUN npx prisma generate --schema=packages/prisma/postgresql/schema.prisma

# Esponi porta
EXPOSE 3000

# Comando di avvio
CMD ["npm", "run", "start", "--workspace=apps/builder"]
