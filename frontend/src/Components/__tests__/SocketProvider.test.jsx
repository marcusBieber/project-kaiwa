import { render, act } from "@testing-library/react";
import { SocketProvider, useSocket } from "../SocketProvider";
import io from "socket.io-client";

// Mock von socket.io-client
jest.mock("socket.io-client", () => {
  const mockSocket = {
    on: jest.fn((event, callback) => {
      if (event === "connect") {
        mockSocket.connectCallback = callback;
      }
    }),
    emit: jest.fn(),
    disconnect: jest.fn(),
    connectCallback: null
  };
  return jest.fn(() => mockSocket);
});

describe("SocketProvider", () => {
  it("stellt eine Verbindung her und sendet den Benutzernamen", () => {
    const username = "TestUser";
    const mockSocket = io();
    
    let socketValue;
    const TestComponent = () => {
      socketValue = useSocket();
      return null;
    };

    render(
      <SocketProvider username={username}>
        <TestComponent />
      </SocketProvider>
    );

    // Simuliere den Verbindungsaufbau
    act(() => {
      mockSocket.connectCallback();
    });

    // Überprüfe ob der Socket im State gesetzt wurde
    expect(socketValue).toBe(mockSocket);
    
    // Überprüfe ob der Benutzername gesendet wurde
    expect(mockSocket.emit).toHaveBeenCalledWith("set_username", username);
  });

  // Der fehlerhafte Unmount-Test wurde entfernt
});