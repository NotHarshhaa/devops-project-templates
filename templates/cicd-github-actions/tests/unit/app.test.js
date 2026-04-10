const { greet, add } = require('../../app/app');

describe('App Functions', () => {
    describe('greet', () => {
        test('should return greeting with name', () => {
            expect(greet('World')).toBe('Hello, World!');
        });

        test('should handle empty string', () => {
            expect(greet('')).toBe('Hello, !');
        });
    });

    describe('add', () => {
        test('should add two numbers correctly', () => {
            expect(add(2, 3)).toBe(5);
        });

        test('should handle negative numbers', () => {
            expect(add(-1, 1)).toBe(0);
        });

        test('should handle zero', () => {
            expect(add(0, 0)).toBe(0);
        });
    });
});
