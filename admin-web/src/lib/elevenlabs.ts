/**
 * ElevenLabs Text-to-Speech API Integration
 */

const ELEVENLABS_API_URL = 'https://api.elevenlabs.io/v1';

export interface ElevenLabsVoice {
  voice_id: string;
  name: string;
  category: string;
  description?: string;
  preview_url?: string;
  labels?: Record<string, string>;
}

export interface VoiceSettings {
  stability: number;
  similarity_boost: number;
  style?: number;
  use_speaker_boost?: boolean;
}

export interface GenerateAudioRequest {
  text: string;
  voiceId: string;
  voiceSettings?: VoiceSettings;
  modelId?: string;
}

export interface GenerateAudioResponse {
  audioBuffer: ArrayBuffer;
  contentType: string;
}

/**
 * Default voice settings for tour narration
 */
export const DEFAULT_VOICE_SETTINGS: VoiceSettings = {
  stability: 0.5,
  similarity_boost: 0.75,
  style: 0.5,
  use_speaker_boost: true,
};

/**
 * Fetch available voices from ElevenLabs
 */
export async function getVoices(apiKey: string): Promise<ElevenLabsVoice[]> {
  const response = await fetch(`${ELEVENLABS_API_URL}/voices`, {
    headers: {
      'xi-api-key': apiKey,
    },
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to fetch voices: ${response.status} - ${error}`);
  }

  const data = await response.json();
  return data.voices || [];
}

/**
 * Generate audio from text using ElevenLabs TTS
 */
export async function generateAudio(
  apiKey: string,
  request: GenerateAudioRequest
): Promise<GenerateAudioResponse> {
  const { text, voiceId, voiceSettings = DEFAULT_VOICE_SETTINGS, modelId = 'eleven_multilingual_v2' } = request;

  const response = await fetch(`${ELEVENLABS_API_URL}/text-to-speech/${voiceId}`, {
    method: 'POST',
    headers: {
      'xi-api-key': apiKey,
      'Content-Type': 'application/json',
      'Accept': 'audio/mpeg',
    },
    body: JSON.stringify({
      text,
      model_id: modelId,
      voice_settings: voiceSettings,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to generate audio: ${response.status} - ${error}`);
  }

  const audioBuffer = await response.arrayBuffer();
  const contentType = response.headers.get('content-type') || 'audio/mpeg';

  return { audioBuffer, contentType };
}

/**
 * Get user subscription info (for checking quota)
 */
export async function getSubscriptionInfo(apiKey: string): Promise<{
  character_count: number;
  character_limit: number;
  can_extend_character_limit: boolean;
}> {
  const response = await fetch(`${ELEVENLABS_API_URL}/user/subscription`, {
    headers: {
      'xi-api-key': apiKey,
    },
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to get subscription info: ${response.status} - ${error}`);
  }

  return response.json();
}
