import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { ColorProvider, ColorSwitcher } from '../ColorSwitcher'; // Passen Sie den Import an den Pfad an

describe('ColorSwitcher', () => {
  test('toggle color scheme between light and dark mode', () => {
    render(
      <ColorProvider>
        <ColorSwitcher />
      </ColorProvider>
    );

    const button = screen.getByText(/dark mode/i);

    // Überprüfen, dass der Button initial "Dark Mode" anzeigt
    expect(button).toBeInTheDocument();

    // Simulieren des Klicks, um den Modus zu wechseln
    fireEvent.click(button);

    // Überprüfen, dass der Text nach dem Klick "Light Mode" ist
    expect(button).toHaveTextContent(/light mode/i);

    // Erneut klicken, um den Modus wieder auf Dark Mode zu setzen
    fireEvent.click(button);

    // Überprüfen, dass der Text wieder "Dark Mode" anzeigt
    expect(button).toHaveTextContent(/dark mode/i);
  });

  test('button style changes on hover', () => {
    render(
      <ColorProvider>
        <ColorSwitcher />
      </ColorProvider>
    );

    const button = screen.getByText(/dark mode/i);

    // Button hover simulieren
    fireEvent.mouseEnter(button);

    // Überprüfen, dass der Button die Hover-Stile ändert
    expect(button).toHaveStyle('transform: translateY(-2px)');
    expect(button).toHaveStyle('box-shadow: 0px 4px 15px rgba(0, 0, 0, 0.2)');

    // Button Hover entfernen
    fireEvent.mouseLeave(button);

    // Überprüfen, dass der Hover-Stil entfernt wird
    expect(button).toHaveStyle('transform: translateY(0)');
    expect(button).toHaveStyle('box-shadow: none');
  });
});
