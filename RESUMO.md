# Atividade 03 - Integração Contínua (CI)

**Disciplina:** DevOps - UNIVAS / Pouso Alegre-MG
**Professor:** Raffael Carvalho
**Aluno:** Luiz Antônio de Souza, Renan Carlos, Itallo

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

## Repositório e execução do pipeline

**Repositório:** https://github.com/LuixzSouza/ci-ola-mundo-devops
**Execução do CI:** https://github.com/LuixzSouza/ci-ola-mundo-devops/actions

Após o `git push`, o GitHub Actions detectou o arquivo `ci.yml` e disparou o
pipeline automaticamente:

- Run: **Pipeline de CI - Olá Mundo DevOps #1**
- Job: `test-and-build`
- Resultado: ✅ **Success** em 33 segundos
- Todos os passos passaram: Checkout → Node.js → Instalar Dependências →
  Rodar Testes → Docker Buildx → Build da Imagem Docker

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

---
---

# Atividade 04 - Protegendo a `main` e Publicando no Registro

**Disciplina:** DevOps - UNIVAS / Pouso Alegre-MG
**Professor:** Raffael Carvalho
**Aluno:** Luiz Antônio de Souza, Renan Carlos, Itallo

## Objetivo da atividade

Partindo do mesmo projeto da Atividade 03, agora precisamos:

1. **Proteger a branch `main`**, para que ninguém consiga fazer merge sem que a
   CI passe.
2. Fazer a CI virar um **status check obrigatório** no Pull Request.
3. **Publicar a imagem Docker** num registro (o GHCR - GitHub Container
   Registry), mas **só depois do merge na `main`** - nunca em Pull Request.

## Parte 1 - Proteção da branch `main`

Configurado em **Settings > Branches > Add branch protection rule**:

| Campo | Valor |
|---|---|
| Branch name pattern | `main` |
| Require status checks to pass before merging | ✅ marcado |
| Require branches to be up to date before merging | ✅ marcado |
| Status checks that are required | `test-and-build` |

A partir daí, um Pull Request só fica com o botão de merge liberado depois que
o job `test-and-build` termina em verde. Se o teste quebrar, o merge fica
bloqueado - a `main` nunca recebe código quebrado.

## Parte 2 - Mudanças no `.github/workflows/ci.yml`

Trabalho feito na branch `dev` (`git checkout -b dev`), nunca direto na `main`.

### a) Bloco `permissions` no job

```yaml
test-and-build:
  runs-on: ubuntu-latest
  permissions:
    contents: read   # ler o repositório (checkout)
    packages: write  # FAZER PUSH da imagem para o GitHub Packages/GHCR
```

Sem `packages: write`, o `GITHUB_TOKEN` do pipeline não teria permissão para
publicar a imagem e o push falharia com erro de autorização.

### b) Dois novos steps antes do build

| Step | O que faz |
|---|---|
| **Logar no GitHub Container Registry** | Faz login no `ghcr.io` usando `${{ github.actor }}` e o `${{ secrets.GITHUB_TOKEN }}` - um segredo que o GitHub cria sozinho a cada execução, não precisamos cadastrar nada. |
| **Extrair Metadados do Docker** | O `docker/metadata-action@v5` gera automaticamente as tags da imagem: `type=sha` (uma tag com o hash do commit, para rastrear exatamente qual código gerou aquela imagem) e `latest`. |

### c) O step "Build da Imagem Docker" virou "Build e Push da Imagem Docker"

```yaml
push: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}
tags: ${{ steps.meta.outputs.tags }}
labels: ${{ steps.meta.outputs.labels }}
```

### O truque do `if` - o coração da atividade

Os dois steps novos têm a condição:

```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

E o step de build usa a mesma expressão no campo `push:`. Traduzindo:

> "Só faça login e só envie a imagem se o evento for um **push** **e** se a
> branch for a **main**."

Como um Pull Request dispara o evento `pull_request` (e não `push`), a condição
é falsa e esses steps são **pulados (skipped)**. O PR continua rodando os
testes e o build - ou seja, ele **valida** que a imagem consegue ser
construída - mas não publica nada. Só quando o PR é mergeado é que nasce um
`push` na `main`, a condição vira verdadeira e a imagem é publicada.

## Parte 3 - Execução (o que dá para conferir no GitHub)

| # | Passo | O que observar |
|---|---|---|
| 1 | `git push origin dev` | A branch `dev` aparece no repositório. |
| 2 | Abrir o **Pull Request** `dev` → `main` | O pipeline dispara sozinho pelo evento `pull_request`. |
| 3 | **Observar (1)** | Na aba Actions, os steps "Logar no GitHub Container Registry" e "Extrair Metadados do Docker" aparecem como **skipped**, e o build roda com `push: false`. |
| 4 | **Observar (2)** | No PR, o check `test-and-build` fica ✅ e o botão de merge é liberado - é a proteção da branch em ação. |
| 5 | Fazer o **merge** do PR | O merge gera um `push` na `main`. |
| 6 | **Observar (3)** | O pipeline roda de novo, agora pelo evento `push` na `main`: os steps de login e metadados **executam**, e a imagem é enviada para o GHCR. |
| 7 | Conferir o pacote | A imagem aparece em **Packages**, em `ghcr.io/LuixzSouza/ci-ola-mundo-devops`, com as tags `latest` e `sha-<hash>`. |

## Por que isso importa numa empresa

Esta atividade fecha o ciclo que a Atividade 03 começou. Antes, a CI apenas
avisava se o código estava quebrado - mas nada impedia alguém de fazer merge
mesmo assim. Com a **proteção de branch**, o aviso vira uma **trava**: a `main`
passa a ser, por regra, sempre estável. E com a **publicação automática da
imagem**, todo commit que entra na `main` gera um artefato pronto, versionado
pelo hash do commit e guardado no registro - é exatamente esse artefato que o
ambiente de produção vai baixar e rodar. Ninguém mais precisa buildar imagem na
própria máquina e subir "na mão", o que elimina o clássico "na minha máquina
funcionava" e dá rastreabilidade: dá para saber, para qualquer imagem em
produção, qual commit exato a originou. Esse é o passo natural do CI para o CD
(Entrega Contínua).
