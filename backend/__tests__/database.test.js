import {
  addChatMessage,
  getChatMessages,
  resetDatabase,
  deleteChatMessage,
} from "../database.js";

// This will run before each test
beforeEach(async () => {
  await resetDatabase();
});

// Test if we can add a chat message
test("addChatMessage", async () => {
  const text = "test message";

  await addChatMessage("testuser", text, Date.now(), new Date().toISOString());
  const chatMessages = await getChatMessages();

  expect(chatMessages.length).toBe(1);
  expect(chatMessages[0].username).toBe("testuser");
  expect(chatMessages[0].text).toBe(text);
});

// Test if we can delete a single chat message
test("deleteChatMessage", async () => {
  const text = "test message";
  await addChatMessage("testuser", text, Date.now(), new Date().toISOString());

  let chatMessages = await getChatMessages();
  const chatmessageid = chatMessages[0].id;

  await deleteChatMessage(chatmessageid);
  chatMessages = await getChatMessages();

  expect(chatMessages.length).toBe(0);
});
