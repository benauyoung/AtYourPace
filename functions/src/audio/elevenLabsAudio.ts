import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import fetch from 'node-fetch';

const REQUESTS_PER_MINUTE = 1;
const MAX_TEXT_LENGTH = 5000;

// Get the ElevenLabs API key from Firebase config
// Set it using: firebase functions:config:set elevenlabs.apikey="your-api-key"
const getApiKey = (): string => {
  return functions.config().elevenlabs?.apikey || process.env.ELEVENLABS_API_KEY || '';
};

interface ElevenLabsRequest {
  text: string;
  voiceId: string;
  tourId: string;
  stopId: string;
}

interface RateLimitDoc {
  userId: string;
  tourId: string;
  stopId: string;
  requestedAt: admin.firestore.Timestamp;
  status: 'queued' | 'processing' | 'completed' | 'failed';
  textLength: number;
  resultUrl?: string;
  error?: string;
}

export const generateElevenLabsAudio = functions
  .runWith({
    timeoutSeconds: 120,
    memory: '512MB',
  })
  .https.onCall(async (data: ElevenLabsRequest, context) => {
    // 1. Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'You must be signed in to generate audio.'
      );
    }

    const userId = context.auth.uid;
    const { text, voiceId, tourId, stopId } = data;

    // 2. Validate input
    if (!text || typeof text !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Text is required.'
      );
    }

    if (text.length > MAX_TEXT_LENGTH) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Text must be less than ${MAX_TEXT_LENGTH} characters.`
      );
    }

    if (!voiceId || typeof voiceId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Voice ID is required.'
      );
    }

    if (!tourId || !stopId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Tour ID and Stop ID are required.'
      );
    }

    const db = admin.firestore();
    const storage = admin.storage();

    // 3. Check rate limit (1 request per minute per user)
    const oneMinuteAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 60000)
    );

    const recentRequests = await db
      .collection('rateLimits')
      .doc('elevenlabs')
      .collection('requests')
      .where('userId', '==', userId)
      .where('requestedAt', '>', oneMinuteAgo)
      .get();

    if (recentRequests.size >= REQUESTS_PER_MINUTE) {
      throw new functions.https.HttpsError(
        'resource-exhausted',
        'Rate limit exceeded. Please wait 1 minute between audio generation requests.'
      );
    }

    // 4. Verify the user owns this tour
    const tourDoc = await db.collection('tours').doc(tourId).get();
    if (!tourDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Tour not found.');
    }

    const tourData = tourDoc.data();
    if (tourData?.creatorId !== userId) {
      // Allow admins to generate audio for any tour
      const userDoc = await db.collection('users').doc(userId).get();
      if (userDoc.data()?.role !== 'admin') {
        throw new functions.https.HttpsError(
          'permission-denied',
          'You do not have permission to generate audio for this tour.'
        );
      }
    }

    // 5. Record the request
    const requestRef = await db
      .collection('rateLimits')
      .doc('elevenlabs')
      .collection('requests')
      .add({
        userId,
        tourId,
        stopId,
        requestedAt: admin.firestore.FieldValue.serverTimestamp(),
        status: 'processing',
        textLength: text.length,
      } as Partial<RateLimitDoc>);

    try {
      const apiKey = getApiKey();
      if (!apiKey) {
        throw new Error('ElevenLabs API key not configured');
      }

      // 6. Call ElevenLabs API
      const response = await fetch(
        `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
        {
          method: 'POST',
          headers: {
            Accept: 'audio/mpeg',
            'Content-Type': 'application/json',
            'xi-api-key': apiKey,
          },
          body: JSON.stringify({
            text,
            model_id: 'eleven_multilingual_v2',
            voice_settings: {
              stability: 0.5,
              similarity_boost: 0.75,
            },
          }),
        }
      );

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`ElevenLabs API error: ${response.status} - ${errorText}`);
      }

      const audioBuffer = await response.buffer();

      // 7. Upload to Firebase Storage
      const bucket = storage.bucket();
      const timestamp = Date.now();
      const filePath = `tours/${tourId}/audio/${stopId}_${timestamp}.mp3`;
      const file = bucket.file(filePath);

      await file.save(audioBuffer, {
        metadata: {
          contentType: 'audio/mpeg',
          metadata: {
            voiceId,
            generatedBy: 'elevenlabs',
            generatedAt: new Date().toISOString(),
            userId,
          },
        },
      });

      // Make the file publicly accessible
      await file.makePublic();

      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filePath}`;

      // 8. Update request record with success
      await requestRef.update({
        status: 'completed',
        resultUrl: publicUrl,
      });

      return { audioUrl: publicUrl };
    } catch (error) {
      // Update request record with failure
      await requestRef.update({
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error',
      });

      functions.logger.error('ElevenLabs audio generation failed:', error);

      throw new functions.https.HttpsError(
        'internal',
        'Audio generation failed. Please try again later.'
      );
    }
  });
