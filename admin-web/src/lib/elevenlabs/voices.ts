// Curated list of ElevenLabs voices for tour narration
// These voices are selected for clarity, professional quality, and suitability for tour guides

export interface ElevenLabsVoice {
  id: string;
  name: string;
  description: string;
  category: 'male' | 'female' | 'neutral';
  accent?: string;
  style?: string;
  previewUrl?: string;
}

// Curated voice list - these are popular ElevenLabs voices suitable for narration
// Voice IDs from ElevenLabs public voice library
export const ELEVENLABS_VOICES: ElevenLabsVoice[] = [
  // Female voices
  {
    id: 'EXAVITQu4vr4xnSDxMaL',
    name: 'Sarah',
    description: 'Soft, warm, and conversational',
    category: 'female',
    accent: 'American',
    style: 'Conversational',
  },
  {
    id: 'XB0fDUnXU5powFXDhCwa',
    name: 'Charlotte',
    description: 'Professional, clear narration',
    category: 'female',
    accent: 'British',
    style: 'Narration',
  },
  {
    id: 'pFZP5JQG7iQjIQuC4Bku',
    name: 'Lily',
    description: 'Warm, friendly, expressive',
    category: 'female',
    accent: 'British',
    style: 'Expressive',
  },
  {
    id: 'jBpfuIE2acCO8z3wKNLl',
    name: 'Gigi',
    description: 'Young, energetic, upbeat',
    category: 'female',
    accent: 'American',
    style: 'Animated',
  },
  {
    id: 'oWAxZDx7w5VEj9dCyTzz',
    name: 'Grace',
    description: 'Elegant, sophisticated narration',
    category: 'female',
    accent: 'American',
    style: 'Narration',
  },

  // Male voices
  {
    id: 'onwK4e9ZLuTAKqWW03F9',
    name: 'Daniel',
    description: 'Deep, authoritative, documentary style',
    category: 'male',
    accent: 'British',
    style: 'Documentary',
  },
  {
    id: 'N2lVS1w4EtoT3dr4eOWO',
    name: 'Callum',
    description: 'Natural, conversational, friendly',
    category: 'male',
    accent: 'American',
    style: 'Conversational',
  },
  {
    id: 'TX3LPaxmHKxFdv7VOQHJ',
    name: 'Liam',
    description: 'Young, clear, articulate',
    category: 'male',
    accent: 'American',
    style: 'Narration',
  },
  {
    id: 'pNInz6obpgDQGcFmaJgB',
    name: 'Adam',
    description: 'Deep, mature, storytelling',
    category: 'male',
    accent: 'American',
    style: 'Storytelling',
  },
  {
    id: 'yoZ06aMxZJJ28mfd3POQ',
    name: 'Sam',
    description: 'Warm, trustworthy, educational',
    category: 'male',
    accent: 'American',
    style: 'Educational',
  },
];

// Helper to get voice by ID
export function getVoiceById(id: string): ElevenLabsVoice | undefined {
  return ELEVENLABS_VOICES.find((voice) => voice.id === id);
}

// Helper to get voices by category
export function getVoicesByCategory(
  category: 'male' | 'female' | 'neutral'
): ElevenLabsVoice[] {
  return ELEVENLABS_VOICES.filter((voice) => voice.category === category);
}

// Get default voice (first female voice)
export function getDefaultVoice(): ElevenLabsVoice {
  return ELEVENLABS_VOICES[0];
}

// Group voices by category for display
export function getGroupedVoices(): Record<string, ElevenLabsVoice[]> {
  return {
    Female: getVoicesByCategory('female'),
    Male: getVoicesByCategory('male'),
    Neutral: getVoicesByCategory('neutral'),
  };
}
