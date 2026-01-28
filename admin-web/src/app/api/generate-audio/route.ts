import { NextRequest, NextResponse } from 'next/server';
import { generateAudio, getVoices, DEFAULT_VOICE_SETTINGS } from '@/lib/elevenlabs';

const ELEVENLABS_API_KEY = process.env.ELEVENLABS_API_KEY;

export async function POST(request: NextRequest) {
  if (!ELEVENLABS_API_KEY) {
    return NextResponse.json(
      { error: 'ElevenLabs API key not configured' },
      { status: 500 }
    );
  }

  try {
    const body = await request.json();
    const { text, voiceId, voiceSettings } = body;

    if (!text || typeof text !== 'string') {
      return NextResponse.json(
        { error: 'Text is required' },
        { status: 400 }
      );
    }

    if (!voiceId || typeof voiceId !== 'string') {
      return NextResponse.json(
        { error: 'Voice ID is required' },
        { status: 400 }
      );
    }

    // Limit text length to prevent abuse
    if (text.length > 5000) {
      return NextResponse.json(
        { error: 'Text must be less than 5000 characters' },
        { status: 400 }
      );
    }

    const result = await generateAudio(ELEVENLABS_API_KEY, {
      text,
      voiceId,
      voiceSettings: voiceSettings || DEFAULT_VOICE_SETTINGS,
    });

    // Return audio as base64 for easier client handling
    const base64Audio = Buffer.from(result.audioBuffer).toString('base64');

    return NextResponse.json({
      audio: base64Audio,
      contentType: result.contentType,
    });
  } catch (error) {
    console.error('Audio generation error:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to generate audio' },
      { status: 500 }
    );
  }
}

export async function GET() {
  if (!ELEVENLABS_API_KEY) {
    return NextResponse.json(
      { error: 'ElevenLabs API key not configured' },
      { status: 500 }
    );
  }

  try {
    const voices = await getVoices(ELEVENLABS_API_KEY);

    // Filter to most useful voices for tour narration
    const filteredVoices = voices.filter((voice) => {
      // Include premade voices and cloned voices
      return voice.category === 'premade' || voice.category === 'cloned';
    });

    return NextResponse.json({ voices: filteredVoices });
  } catch (error) {
    console.error('Get voices error:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to fetch voices' },
      { status: 500 }
    );
  }
}
