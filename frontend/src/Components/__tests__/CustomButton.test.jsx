import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { ColorProvider } from '../ColorSwitcher'; // Passen Sie den Import an den Pfad an
import CustomButton from '../CustomButton'; // Passen Sie den Import an den Pfad an

describe('CustomButton', () => {
  test('button renders children and responds to click', () => {
    const handleClick = jest.fn();

    // Button rendern, um den ColorProvider zu integrieren
    render(
      <ColorProvider>
        <CustomButton onClick={handleClick}>Click Me</CustomButton>
      </ColorProvider>
    );

    // Button durch Text finden
    const button = screen.getByText(/click me/i);

    // Überprüfen, dass der Button im Dokument vorhanden ist
    expect(button).toBeInTheDocument();

    // Button klicken und sicherstellen, dass der onClick Handler aufgerufen wird
    fireEvent.click(button);
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
