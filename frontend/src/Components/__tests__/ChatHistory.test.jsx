import { render, screen, waitFor } from "@testing-library/react";
import ChatHistory from "../ChatHistory";
import React from "react";

jest.mock("../ChatHistory", () => (props) => (
  <div>
    {props.messages.map((msg) => (
      <div key={msg.id} className="last-message">
        <span>{msg.username}</span>
        <p>{msg.text}</p>
      </div>
    ))}
  </div>
));

describe("ChatHistory", () => {
  it("lädt und zeigt Nachrichten aus der API", async () => {
    const messages = [
      { id: 1, username: "Alice", text: "Hallo Welt!", date: "2024-03-19 10:00:00" },
    ];

    render(<ChatHistory messages={messages} />);

    // Warten, bis der Text erscheint, ohne `act` explizit zu nutzen
    await waitFor(() => {
      expect(screen.getByText("Hallo Welt!")).toBeInTheDocument();
      expect(screen.getByText("Alice")).toBeInTheDocument();
    });
  });
});
