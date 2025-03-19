import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import Login from '../Login'; // Passen Sie den Import an den Pfad an
import { ColorContext } from '../ColorSwitcher'; // Importiere den ColorContext

// Mocked Context für die Tests
const mockColorContext = {
  darkMode: false, // Beispielwert für darkMode, ändere es nach Bedarf
  setDarkMode: jest.fn(),
};

describe('Login', () => {
  test('renders input and button', () => {
    render(
      <ColorContext.Provider value={mockColorContext}>
        <Login onLogin={jest.fn()} />
      </ColorContext.Provider>
    );

    // Überprüfen, dass das Eingabefeld und der Button im Dokument vorhanden sind
    expect(screen.getByPlaceholderText(/wie ist dein name\.\.\./i)).toBeInTheDocument();
    expect(screen.getByText(/anmelden/i)).toBeInTheDocument();
  });

  test('calls onLogin with username when button is clicked', () => {
    const handleLogin = jest.fn();
    render(
      <ColorContext.Provider value={mockColorContext}>
        <Login onLogin={handleLogin} />
      </ColorContext.Provider>
    );

    const input = screen.getByPlaceholderText(/wie ist dein name\.\.\./i);
    const button = screen.getByText(/anmelden/i);

    // Eingabefeld mit einem Benutzernamen füllen
    fireEvent.change(input, { target: { value: 'Max' } });

    // Button klicken
    fireEvent.click(button);

    // Überprüfen, ob onLogin mit dem richtigen Benutzernamen aufgerufen wurde
    expect(handleLogin).toHaveBeenCalledWith('Max');
  });

  test('does not call onLogin when username is empty', () => {
    const handleLogin = jest.fn();
    render(
      <ColorContext.Provider value={mockColorContext}>
        <Login onLogin={handleLogin} />
      </ColorContext.Provider>
    );

    const input = screen.getByPlaceholderText(/wie ist dein name\.\.\./i);
    const button = screen.getByText(/anmelden/i);

    // Eingabefeld leer lassen
    fireEvent.change(input, { target: { value: '' } });

    // Button klicken
    fireEvent.click(button);

    // Überprüfen, dass onLogin nicht aufgerufen wurde
    expect(handleLogin).not.toHaveBeenCalled();
  });
});
