import { render, screen, fireEvent, act } from '@testing-library/react';
import TextInput from '../TextInput';  // Passen Sie den Pfad zu TextInput an
import { ColorContext } from '../ColorSwitcher';  // Passen Sie den Pfad zu ColorSwitcher an
import { useSocket } from '../SocketProvider';  // Passen Sie den Pfad zu SocketProvider an
import CustomButton from '../CustomButton';  // Passen Sie den Pfad zu CustomButton an

// Mocken von useSocket
jest.mock('../SocketProvider', () => ({
  useSocket: jest.fn(),
}));

describe('TextInput', () => {
  it('sends a message when the "Senden" button is clicked', () => {
    const mockSocket = {
      emit: jest.fn(),
    };
    useSocket.mockReturnValue(mockSocket);

    const mockContextValue = { darkMode: false }; // Beispielwert für darkMode

    const username = 'TestUser';

    render(
      <ColorContext.Provider value={mockContextValue}>
        <TextInput username={username} />
      </ColorContext.Provider>
    );

    const inputField = screen.getByPlaceholderText('schreib\' eine Nachricht...');
    const sendButton = screen.getByText('Senden');

    // Simulieren einer Nachrichteneingabe
    fireEvent.change(inputField, { target: { value: 'Testnachricht' } });

    // Überprüfen, ob der Wert im Eingabefeld gesetzt wurde
    expect(inputField.value).toBe('Testnachricht');

    // Simulieren eines Klicks auf den "Senden"-Button
    fireEvent.click(sendButton);

    // Überprüfen, ob die emit-Methode des Sockets mit den richtigen Daten aufgerufen wurde
    expect(mockSocket.emit).toHaveBeenCalledWith('send_message', expect.objectContaining({
      user: username,
      text: 'Testnachricht',
    }));

    // Überprüfen, ob das Eingabefeld nach dem Senden gelöscht wird
    expect(inputField.value).toBe('');
  });

  it('sends a message when Enter is pressed', () => {
    const mockSocket = {
      emit: jest.fn(),
    };
    useSocket.mockReturnValue(mockSocket);

    const mockContextValue = { darkMode: false };

    const username = 'TestUser';

    render(
      <ColorContext.Provider value={mockContextValue}>
        <TextInput username={username} />
      </ColorContext.Provider>
    );

    const inputField = screen.getByPlaceholderText('schreib\' eine Nachricht...');

    // Simulieren einer Nachrichteneingabe
    fireEvent.change(inputField, { target: { value: 'Testnachricht' } });

    // Simulieren der Enter-Taste (ohne Shift)
    fireEvent.keyDown(inputField, { key: 'Enter', code: 'Enter', charCode: 13 });

    // Überprüfen, ob die emit-Methode des Sockets mit den richtigen Daten aufgerufen wurde
    expect(mockSocket.emit).toHaveBeenCalledWith('send_message', expect.objectContaining({
      user: username,
      text: 'Testnachricht',
    }));

    // Überprüfen, ob das Eingabefeld nach dem Senden gelöscht wird
    expect(inputField.value).toBe('');
  });
});
