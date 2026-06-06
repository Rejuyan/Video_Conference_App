require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { AccessToken } = require('livekit-server-sdk');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable JSON parser and Cross-Origin Resource Sharing
app.use(express.json());
app.use(cors());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy', timestamp: new Date().toISOString() });
});

/**
 * Endpoint to generate a secure LiveKit JWT Access Token
 * POST /api/token
 * Body: { "room": "vmt-xyz-abc", "identity": "Alex Johnson" }
 */
app.post('/api/token', async (req, res) => {
  const { room, identity } = req.body;

  // Validate parameters
  if (!room || !identity) {
    return res.status(400).json({ 
      error: 'Missing parameters. Both "room" (meeting room ID) and "identity" (participant nickname) are required.' 
    });
  }

  const apiKey = process.env.LIVEKIT_API_KEY;
  const apiSecret = process.env.LIVEKIT_API_SECRET;

  if (!apiKey || !apiSecret) {
    console.error('SERVER ERROR: LIVEKIT_API_KEY or LIVEKIT_API_SECRET environment variables are missing.');
    return res.status(500).json({ 
      error: 'Server misconfiguration. LiveKit API credentials are not set on the host environment.' 
    });
  }

  try {
    // Instantiate LiveKit AccessToken
    const at = new AccessToken(apiKey, apiSecret, {
      identity: identity,
      ttl: '2h', // Token valid for 2 hours
    });

    // Add necessary WebRTC room join grants
    at.addGrant({
      roomJoin: true,
      room: room.trim().toLowerCase(),
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    // Generate JWT string
    const token = await at.toJwt();

    console.log(`Token issued: Room=[${room}], Participant=[${identity}]`);
    return res.json({ token });
  } catch (error) {
    console.error('Error generating token:', error);
    return res.status(500).json({ error: 'Failed to generate JWT access token due to an internal error.' });
  }
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`===================================================`);
    console.log(` VMeet secure Token Server running on port ${PORT} `);
    console.log(` Endpoint: http://localhost:${PORT}/api/token     `);
    console.log(`===================================================`);
  });
}

module.exports = app;
