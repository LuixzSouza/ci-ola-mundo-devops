# Estágio 1: Build - Instala dependências
# Usamos uma imagem "builder" que contém todas as ferramentas do Node
FROM node:22-alpine AS builder
WORKDIR /usr/src/app
# Copia o package.json e package-lock.json
COPY package*.json ./
# Instala SOMENTE as dependências de produção
RUN npm ci --omit=dev
# Copia o restante do código da aplicação
COPY . .
# ---
# Estágio 2: Produção - Imagem final
# Usamos uma imagem "slim" mais leve para produção
FROM node:22-alpine
WORKDIR /usr/src/app
# Copia as dependências instaladas do estágio "builder"
COPY --from=builder /usr/src/app/node_modules ./node_modules
# Copia o código da aplicação do estágio "builder"
COPY --from=builder /usr/src/app ./
# Expõe a porta que a aplicação usa
EXPOSE 3000
# Comando para iniciar a aplicação
CMD [ "node", "server.js" ]
