module.exports = {
  testEnvironment: 'jsdom',   // Verwendung der jsdom-Umgebung (für den Browser)
  transform: {
    '^.+\\.jsx?$': 'babel-jest',  // Umwandlung von JSX-Dateien mit Babel
  },
  moduleFileExtensions: ['js', 'jsx', 'json', 'node'],  // Unterstützte Dateitypen
  transformIgnorePatterns: [
    '/node_modules/(?!your-package-to-transform|other-packages-to-transform).+\\.js$'  // Optional: Für Pakete, die du transformieren möchtest
  ],
  moduleNameMapper: {
    '\\.(png|jpg|jpeg|gif|svg)$': '<rootDir>/__mocks__/fileMock.js',  // Mock für Bilder und andere Dateien
  },
  setupFilesAfterEnv: ['<rootDir>/src/setupTests.js'],

};
  