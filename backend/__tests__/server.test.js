import request from "supertest";
import { io as Client } from "socket.io-client";
import { serverInstance, app, io } from "../server.js";

const TEST_USER = "TestUser";

describe("API & WebSocket Tests", () => {
  let clientSocket;

  beforeAll((done) => {
    clientSocket = new Client("http://localhost:3000", {
      transports: ["websocket"],
    });
    clientSocket.on("connect", done);
  });

  afterAll((done) => {
    clientSocket.disconnect();
    serverInstance.close(done);
  });

  test("GET /chat should return chat messages", async () => {
    const res = await request(app).get("/chat");
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  test("WebSocket: User should be able to connect and set username", (done) => {
    clientSocket.emit("set_username", TEST_USER);
    clientSocket.on("update_user", (users) => {
      expect(users).toContain(TEST_USER);
      done();
    });
  });

  test("WebSocket: Sending a message should broadcast it", (done) => {
    const message = { user: TEST_USER, text: "Hallo!", id: "123", timestamp: Date.now() };

    clientSocket.emit("send_message", message);

    clientSocket.on("receive_message", (receivedMessage) => {
      expect(receivedMessage).toEqual(message);
      done();
    });
  });
});
