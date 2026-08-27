const request = require("supertest");
const app = require("./app"); // Importamos nosso app

describe("API Olá Mundo", () => {
  it('Deve retornar "Olá Mundo DevOps!" na rota /', async () => {
    // Faz uma requisição GET para a rota /
    const response = await request(app).get("/");

    // Verifica se o status code é 200 (OK)
    expect(response.statusCode).toBe(200);

    // Verifica se o corpo da resposta é o esperado
    expect(response.text).toBe("Olá Mundo DevOps!");
  });
});
