# 🚀 Olá Mundo DevOps — Integração Contínua (CI)

![CI](https://github.com/LuixzSouza/univas-devops-ci-ola-mundo/actions/workflows/ci.yml/badge.svg)

Atividade 03 da disciplina de **DevOps** (Sistemas de Informação — UNIVÁS), Prof. Raffael Carvalho.
Equipe: Luiz Antônio de Souza, Renan Carlos e Itallo.

Uma aplicação Node.js "Olá Mundo DevOps!" com teste automatizado, imagem Docker *multi-stage* e um pipeline no GitHub Actions que testa e publica a imagem a cada `push` na `main`.

## 🧰 Tecnologias

`Node.js 22` · `Express` · `Jest` + `Supertest` · `Docker` · `GitHub Actions` · `GitHub Container Registry`

## ⚙️ O que o pipeline faz

A cada `push` ou *pull request* para a `main` ([ci.yml](.github/workflows/ci.yml)):

1. Baixa o código e instala o Node 22 (com cache do npm)
2. Instala as dependências e roda `npm test` — **se o teste falhar, o pipeline para**
3. Faz o build da imagem Docker
4. Em `push` na `main`: publica a imagem em `ghcr.io/luixzsouza/univas-devops-ci-ola-mundo` (tags `latest` e `sha`)

## ▶️ Como rodar

```bash
npm install
npm test      # roda o teste automatizado
npm start     # http://localhost:3000
```

Com Docker:

```bash
docker build -t ola-devops .
docker run -p 3000:3000 ola-devops
```

## 📁 Estrutura

| Arquivo | Para que serve |
|---|---|
| `app.js` | Aplicação Express (exportada para os testes) |
| `server.js` | Sobe o servidor na porta 3000 |
| `app.test.js` | Teste: `GET /` deve responder 200 com "Olá Mundo DevOps!" |
| `Dockerfile` | Imagem *multi-stage* (só dependências de produção na final) |
| `.github/workflows/ci.yml` | Pipeline de CI |

📄 Resumo completo da atividade: [RESUMO.md](RESUMO.md)
