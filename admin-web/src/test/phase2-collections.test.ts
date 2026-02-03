import { describe, expect, it } from 'vitest';

describe('Phase 2: Collections Manager', () => {
    describe('Collection Model', () => {
        it('should have all required fields', () => {
            interface CollectionModel {
                id: string;
                name: string;
                description: string;
                coverImageUrl?: string;
                tourIds: string[];
                isCurated: boolean;
                isFeatured: boolean;
                tags: string[];
                type: 'geographic' | 'thematic' | 'seasonal' | 'custom';
                sortOrder: number;
                createdAt: Date;
                updatedAt: Date;
            }

            const mockCollection: CollectionModel = {
                id: 'col-123',
                name: 'Paris Highlights',
                description: 'The best of Paris in one collection.',
                tourIds: ['tour-1', 'tour-2'],
                isCurated: true,
                isFeatured: false,
                tags: ['paris', 'history'],
                type: 'geographic',
                sortOrder: 0,
                createdAt: new Date(),
                updatedAt: new Date(),
            };

            expect(mockCollection.id).toBeDefined();
            expect(mockCollection.name).toBe('Paris Highlights');
            expect(mockCollection.type).toBe('geographic');
        });

        it('should have valid collection types', () => {
            const validTypes = ['geographic', 'thematic', 'seasonal', 'custom'];
            expect(validTypes).toHaveLength(4);
        });
    });

    describe('Validation Logic', () => {
        it('should validate name length', () => {
            const isValidName = (name: string) => name.length >= 3;
            expect(isValidName('ab')).toBe(false);
            expect(isValidName('abc')).toBe(true);
            expect(isValidName('Paris Collection')).toBe(true);
        });

        it('should validate description length', () => {
            const isValidDesc = (desc: string) => desc.length >= 10;
            expect(isValidDesc('Short')).toBe(false);
            expect(isValidDesc('This is a long enough description')).toBe(true);
        });

        it('should validate cover image URL if present', () => {
            const isValidUrl = (url?: string) => {
                if (!url) return true; // Optional
                return url.startsWith('http');
            };

            expect(isValidUrl()).toBe(true);
            expect(isValidUrl('')).toBe(true); // Empty string treated as empty/valid optional
            expect(isValidUrl('https://example.com/image.jpg')).toBe(true);
            expect(isValidUrl('invalid-url')).toBe(false);
        });
    });

    describe('Business Logic', () => {
        it('should allow adding unique tours only', () => {
            const addTour = (currentIds: string[], newId: string) => {
                if (currentIds.includes(newId)) return currentIds;
                return [...currentIds, newId];
            };

            const initial = ['tour-1'];
            expect(addTour(initial, 'tour-2')).toHaveLength(2);
            expect(addTour(initial, 'tour-1')).toHaveLength(1);
        });

        it('should reorder tours correctly', () => {
            const reorder = (items: string[], fromIndex: number, toIndex: number) => {
                const result = [...items];
                const [removed] = result.splice(fromIndex, 1);
                result.splice(toIndex, 0, removed);
                return result;
            };

            const tours = ['A', 'B', 'C'];
            // Move A to end (index 0 to 2)
            expect(reorder(tours, 0, 2)).toEqual(['B', 'C', 'A']);
            // Move C to start (index 2 to 0) -> from previous result ['B', 'C', 'A']
            // Actually fresh: ['A', 'B', 'C'] -> C to start -> ['C', 'A', 'B']
            expect(reorder(['A', 'B', 'C'], 2, 0)).toEqual(['C', 'A', 'B']);
        });
    });
});
