import { render, screen, act } from '@testing-library/react';
import UserDisplay from '../UserDisplay';  // Passen Sie den Pfad zu UserDisplay an
import { ColorContext } from '../ColorSwitcher';  // Passen Sie den Pfad zu ColorSwitcher an
import { useSocket } from '../SocketProvider';  // Passen Sie den Pfad zu SocketProvider an

// Mocken des useSocket-Hooks
jest.mock('../SocketProvider', () => ({
  useSocket: jest.fn(),
}));

describe('UserDisplay', () => {
  it('renders a list of users', () => {
    // Mocken des useSocket-Hooks, um ein mock Socket-Objekt zurückzugeben
    const mockSocket = {
      on: jest.fn(),
    };
    useSocket.mockReturnValue(mockSocket);

    // Mocken des ColorContext, um darkMode zu setzen
    const mockContextValue = { darkMode: true };  // Sie können hier auch false setzen

    // Benutzer, die im Test angezeigt werden
    const users = ['User 1', 'User 2', 'User 3'];

    // Rendering der Komponente mit dem gemockten ColorContext und useSocket
    render(
      <ColorContext.Provider value={mockContextValue}>
        <UserDisplay />
      </ColorContext.Provider>
    );

    // Simulieren einer Benutzeraktualisierung über den Socket
    act(() => {
      mockSocket.on.mock.calls[0][1](users);  // Aufruf des Event-Handlers für 'update_user'
    });

    // Überprüfen, ob die Benutzer korrekt im UI angezeigt werden
    users.forEach((user) => {
      expect(screen.getByText(user)).toBeInTheDocument();
    });
  });
});
