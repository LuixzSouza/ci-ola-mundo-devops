# Atividade 03 - Integração Contínua (CI)

**Disciplina:** DevOps - UNIVAS / Pouso Alegre-MG
**Professor:** Raffael Carvalho
**Aluno:** Luiz Antônio de Souza

---

## O que foi feito (resumo rápido)

Criamos uma aplicação Node.js "Olá Mundo DevOps!", com teste automatizado,
empacotamento em Docker e um pipeline de CI no GitHub Actions que roda
sozinho a cada `push` ou `pull request` na branch `main`.

## Arquivos criados

| Arquivo | Para que serve |
|---|---|
| `app.js` | A aplicação Express. Só a lógica, sem ligar o servidor (por isso é exportada com `module.exports`, para os testes conseguirem usá-la). |
| `server.js` | Só liga o servidor na porta 3000. Separar de `app.js` facilita testar. |
| `app.test.js` | O teste automatizado (jest + supertest): faz um GET em `/` e confere se voltou status 200 e o texto "Olá Mundo DevOps!". |
| `package.json` | Scripts `npm start` e `npm test` + as dependências. |
| `Dockerfile` | A "receita" da imagem Docker. É *multi-stage*: o 1º estágio instala só as dependências de produção, o 2º monta a imagem final, bem mais leve. |
| `.dockerignore` | Impede que `node_modules` local e `.git` entrem na imagem. |
| `.github/workflows/ci.yml` | O pipeline de CI (o "robô"). |

## O que o pipeline de CI faz (ci.yml)

Dispara em todo `push` e `pull request` para a `main` e executa, em ordem,
numa máquina virtual `ubuntu-latest`:

1. **Checkout do Código** - baixa o repositório.
2. **Configurar Node.js** - instala o Node 22 (a mesma versão do Dockerfile) com cache do npm.
3. **Instalar Dependências** - `npm install`.
4. **Rodar Testes** - `npm test`. **Se o teste falhar, o pipeline para aqui.**
5. **Configurar Docker Buildx** - prepara o build de imagem.
6. **Build da Imagem Docker** - constrói a imagem `ola-devops:latest` (`push: false`, ou seja, só constrói, não envia para registro).

## Testes que fiz na minha máquina (tudo passou)

| Comando | Resultado |
|---|---|
| `npm test` | `Test Suites: 1 passed` / `Tests: 1 passed` |
| `npm start` + acessar `http://localhost:3000` | Retornou `HTTP 200` e "Olá Mundo DevOps!" |
| `docker build -t ola-devops .` | Imagem construída com sucesso |
| `docker run -p 3000:3000 -d ola-devops` | Container no ar, respondendo "Olá Mundo DevOps!" na porta 3000 |
| `git init` + commit | Commit inicial criado na branch `main` |

## Falta fazer (só isso!)

Criar o repositório no GitHub e enviar o código - aí o pipeline roda sozinho
e aparece o ✅ verde na aba **Actions**:

```bash
git remote add origin <URL_DO_SEU_REPOSITORIO.git>
git push -u origin main
```

---

## Parágrafo do exercício: onde o CI é útil numa empresa

A Integração Contínua é útil em qualquer empresa onde mais de uma pessoa mexe
no mesmo código. Sem CI, cada desenvolvedor trabalha isolado por semanas e, na
hora de juntar tudo, aparecem conflitos e bugs difíceis de rastrear - ninguém
sabe qual mudança quebrou o sistema. Com CI, cada alteração pequena é integrada
e testada automaticamente várias vezes ao dia: se alguém quebra alguma coisa, a
equipe descobre em minutos e não em semanas, e como a mudança é pequena, achar
e corrigir o erro é muito mais fácil. Isso é especialmente valioso em times que
fazem entregas frequentes (e-commerce, SaaS, aplicativos), em empresas com
equipes remotas ou distribuídas, e em sistemas críticos onde uma falha em
produção custa dinheiro ou reputação. Além disso, o CI padroniza e automatiza
tarefas repetitivas (instalar dependências, rodar testes, gerar o build),
eliminando o erro humano e garantindo que a branch principal esteja sempre
estável e pronta para ser publicada - o que é justamente a base para o próximo
passo, a Entrega Contínua (CD).
