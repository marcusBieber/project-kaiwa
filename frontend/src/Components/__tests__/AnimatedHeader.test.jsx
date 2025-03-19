import React from "react";
import { render, screen, waitFor } from '@testing-library/react';
import AnimatedHeader from '../AnimatedHeader';
import '@testing-library/jest-dom';

// Test: Überprüfen, ob das Bild anfangs nicht angezeigt wird.
test('does not show image initially', () => {
  render(<AnimatedHeader />);
  const image = screen.queryByAltText('Logo');
  expect(image).not.toBeInTheDocument(); // Das Bild sollte initial nicht vorhanden sein.
});

// Test: Überprüfen, ob das Bild nach dem Timeout angezeigt wird.
test('shows image after timeout', async () => {
  render(<AnimatedHeader />);
  
  // Warten, bis der Timeout abläuft und das Bild erscheint.
  await waitFor(() => screen.getByAltText('Logo'));
  
  const image = screen.getByAltText('Logo');
  expect(image).toBeInTheDocument(); // Das Bild sollte jetzt angezeigt werden.
});

// Test: Überprüfen, ob die Klasse "slide-in" nach dem Timeout hinzugefügt wird.
test('adds slide-in class after timeout', async () => {
  render(<AnimatedHeader />);
  
  // Warten, bis der Timeout abläuft und die Klasse hinzugefügt wird.
  await waitFor(() => screen.getByAltText('Logo'));
  
  const div = screen.getByAltText('Logo').parentElement;
  expect(div).toHaveClass('slide-in'); // Das div sollte die Klasse "slide-in" haben.
});
