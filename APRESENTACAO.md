# Roteiro de Apresentação - Atividade 03 (CI)

## 1. O que o professor pediu (slide 21 do PDF)

> "Conforme a prática desta aula, replique os passos em seu computador. Envie o
> link do repositório criado no github, onde será possível conferir a execução
> do pipeline CI, juntamente com um pequeno parágrafo explicando em quais
> situações essa abordagem com CI pode ser útil dentro de uma empresa."

Ou seja, a entrega tem **duas partes**:

| # | Entrega | Onde está |
|---|---|---|
| 1 | Link do repositório com o pipeline **executado** | https://github.com/LuixzSouza/ci-ola-mundo-devops/actions |
| 2 | Parágrafo sobre a utilidade do CI numa empresa | Final do `RESUMO.md` (e no fim deste arquivo) |

---

## 2. O que mostrar na tela, nesta ordem

### Passo 1 - A aba Actions (o mais importante!)
Abra: https://github.com/LuixzSouza/ci-ola-mundo-devops/actions

É **aqui** que está a prova de que o pipeline rodou. Mostre:
- O run **"Pipeline de CI - Olá Mundo DevOps #1"** com o ✅ verde
- Que ele foi disparado sozinho pelo `push` (ninguém clicou em nada)
- Clique no run → clique no job **`test-and-build`** → aparecem os passos:
  `Checkout do Código` → `Configurar Node.js` → `Instalar Dependências` →
  `Rodar Testes` → `Configurar Docker Buildx` → `Build da Imagem Docker`
- Abra o passo **"Rodar Testes"** e mostre a saída do jest com o **PASS**
- Abra o passo **"Build da Imagem Docker"** e mostre a imagem sendo construída
- Tempo total: **33 segundos**

### Passo 2 - O arquivo ci.yml (explicar o "robô")
Abra `.github/workflows/ci.yml` no GitHub e explique as 3 partes:
- **`on:`** → *quando* roda (todo push e pull request na branch `main`)
- **`runs-on: ubuntu-latest`** → *onde* roda (uma máquina virtual do GitHub, não no meu PC)
- **`steps:`** → *o que* faz, em sequência

### Passo 3 - O código da aplicação
- `app.js` → a aplicação. Explique que ela **exporta** o app (`module.exports`)
  em vez de já ligar o servidor
- `server.js` → é quem liga o servidor. Essa separação é o que permite testar

### Passo 4 - O teste (detalhado no item 3 abaixo)
Abra `app.test.js`.

### Passo 5 - O Docker
- `Dockerfile` → é *multi-stage*: 1º estágio instala as dependências,
  2º monta a imagem final mais leve
- `.dockerignore` → evita copiar o `node_modules` local para dentro da imagem

---

## 3. O TESTE - o que é e como explicar

O arquivo é o **`app.test.js`**. Ele usa duas ferramentas:

- **Jest** → o *framework de teste*. É ele que encontra os arquivos `.test.js`,
  executa e diz se passou (PASS) ou falhou (FAIL).
- **Supertest** → permite fazer uma **requisição HTTP de mentira** direto no app,
  sem precisar subir o servidor de verdade numa porta.

### O código explicado

```js
const request = require("supertest");
const app = require("./app");            // importa o app (por isso o module.exports!)

describe("API Olá Mundo", () => {        // "describe" = grupo de testes
  it('Deve retornar "Olá Mundo DevOps!" na rota /', async () => {

    const response = await request(app).get("/");   // faz um GET na rota "/"

    expect(response.statusCode).toBe(200);          // o status tem que ser 200 (OK)
    expect(response.text).toBe("Olá Mundo DevOps!"); // o texto tem que ser exato
  });
});
```

### Explicando em uma frase

> "O teste faz uma requisição GET na rota `/` da aplicação e verifica duas
> coisas: se o status HTTP retornado é **200 (OK)** e se o texto da resposta é
> exatamente **'Olá Mundo DevOps!'**. Se qualquer uma das duas falhar, o Jest
> acusa FAIL, o passo 'Rodar Testes' quebra e **o pipeline inteiro para ali** —
> o build do Docker nem chega a acontecer."

### Por que esse teste importa para o CI

É ele que dá o **feedback rápido**. Se alguém alterar o `app.js` e trocar o
texto, ou quebrar a rota, o teste falha **automaticamente** em segundos, direto
no GitHub, antes daquele código chegar em produção. Esse é o coração da
Integração Contínua: o repositório principal só aceita código que passou nos
testes.

---

## 4. Perguntas que o professor pode fazer (e as respostas)

**"Por que separar `app.js` de `server.js`?"**
Porque se o `app.js` já ligasse o servidor, o teste ficaria preso numa porta
aberta e não terminaria. Separando, o teste importa só a lógica.

**"O que acontece se o teste falhar?"**
O passo "Rodar Testes" fica vermelho ❌, o job para naquele ponto e os passos
seguintes (Docker Buildx e Build da Imagem) **não executam**. Além disso o
GitHub notifica por e-mail.

**"Por que `push: false` no build do Docker?"**
Porque nesta atividade a gente só **valida** que a imagem consegue ser
construída. Enviar a imagem para um registro (Docker Hub) já seria a etapa
seguinte, o **CD** (Entrega Contínua).

**"Por que Node 22 no workflow?"**
Para ser a **mesma versão** do `FROM node:22-alpine` do Dockerfile — assim o que
foi testado é igual ao que vai rodar em produção.

**"O pipeline roda no seu computador?"**
Não. Roda numa máquina virtual `ubuntu-latest` do próprio GitHub, do zero. Isso
prova que o projeto funciona em qualquer máquina, não só na minha.

**"E o `npm ci --omit=dev` no Dockerfile?"**
Instala **só** as dependências de produção (sem jest e supertest), deixando a
imagem final menor. Ele exige o `package-lock.json`, que está versionado.

---

## 5. Parágrafo do exercício (para copiar na entrega)

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
