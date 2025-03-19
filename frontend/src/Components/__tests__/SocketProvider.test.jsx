import { render, screen, waitFor } from '@testing-library/react';
import { SocketProvider, useSocket } from '../SocketProvider';
import io from 'socket.io-client';

// Mock von socket.io-client
jest.mock('socket.io-client', () => {
  return jest.fn().mockImplementation(() => ({
    on: jest.fn(),
    emit: jest.fn(),
    disconnect: jest.fn(),
  }));
});

describe('SocketProvider', () => {
  it('stellt eine Verbindung her und sendet den Benutzernamen', async () => {
    const username = 'TestUser';

    // Wrapper-Komponente, um den Context zu testen
    const Wrapper = () => {
      const socket = useSocket();
      return <div>{socket ? 'connected' : 'not connected'}</div>;
    };

    // Komponente rendern und den SocketProvider einbinden
    render(
      <SocketProvider username={username}>
        <Wrapper />
      </SocketProvider>
    );

    // Warten, bis die Verbindung hergestellt ist
    await waitFor(() => {
      // Überprüfen, ob die Verbindung hergestellt wurde (d.h. 'connected' wird angezeigt)
      expect(screen.getByText('connected')).toBeInTheDocument();
    });

    // Überprüfen, ob der Benutzernamen über den Socket gesendet wurde
    expect(io().emit).toHaveBeenCalledWith('set_username', username);
  });

  it('trennt die Verbindung beim Unmounten', async () => {
    const username = 'TestUser';

    const Wrapper = () => {
      const socket = useSocket();
      return <div>{socket ? 'connected' : 'not connected'}</div>;
    };

    const { unmount } = render(
      <SocketProvider username={username}>
        <Wrapper />
      </SocketProvider>
    );

    // Verbindungsaufbau abwarten
    await waitFor(() => expect(screen.getByText('connected')).toBeInTheDocument());

    // Unmount der Komponente
    unmount();

    // Überprüfen, ob die Verbindung getrennt wurde
    expect(io().disconnect).toHaveBeenCalled();
  });
});
