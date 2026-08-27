// Este arquivo importa o 'app' e inicia o servidor.
// O CI não vai usar este arquivo, mas o Docker sim.

const app = require("./app");
const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Servidor rodando na porta ${port}`);
});
