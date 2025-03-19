import { render, screen, fireEvent } from '@testing-library/react';
import LogOff from '../LogOff';  // Passen Sie den Pfad zu LogOff an
import { ColorContext } from '../ColorSwitcher';  // Passen Sie den Pfad zu ColorSwitcher an

// Mocken des Socket-Providers
jest.mock('../SocketProvider', () => ({
  useSocket: jest.fn().mockReturnValue({ disconnect: jest.fn() }),
}));

describe('LogOff', () => {
  it('calls socket.disconnect and setUsername when the "Abmelden" button is clicked', () => {
    const mockSetUsername = jest.fn();

    // Mocken des ColorContext, um darkMode bereitzustellen
    const mockContextValue = { darkMode: false };

    // Rendering der LogOff-Komponente mit mocktem ColorContext
    render(
      <ColorContext.Provider value={mockContextValue}>
        <LogOff setUsername={mockSetUsername} />
      </ColorContext.Provider>
    );

    // Klick auf den "Abmelden"-Button
    fireEvent.click(screen.getByText(/Abmelden/i));

    // Überprüfen, ob socket.disconnect aufgerufen wurde
    expect(mockSetUsername).toHaveBeenCalledWith('');
  });
});
