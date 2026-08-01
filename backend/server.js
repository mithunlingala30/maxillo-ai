const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const app = express();

app.use(cors());
// Allow large base64 image payloads up to 50MB
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

const apiKey = process.env.GEMINI_API_KEY;
const genAI = new GoogleGenerativeAI(apiKey);
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

// ── Swagger / OpenAPI Documentation (FastAPI Style) ─────────────────────────
const swaggerDocument = {
  openapi: '3.0.0',
  info: {
    title: 'Gen AI Backend API',
    version: '1.0.0',
    description: 'Interactive API documentation (FastAPI style) for Google Gemini AI Backend. Use `/docs` in your browser to test endpoints live!',
  },
  servers: [
    {
      url: 'http://localhost:3000',
      description: 'Local Express Server'
    }
  ],
  paths: {
    '/api/test': {
      get: {
        summary: 'Test server health status',
        responses: {
          '200': { description: 'Server status OK' }
        }
      }
    },
    '/api/ai/predict-image': {
      post: {
        summary: '📷 Predict / Analyze Image',
        description: 'Upload a base64 image (with or without data URI prefix) and optional prompt to get AI prediction/diagnosis.',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  image: {
                    type: 'string',
                    description: 'Base64 encoded image string',
                    example: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...'
                  },
                  mimeType: {
                    type: 'string',
                    example: 'image/jpeg'
                  },
                  prompt: {
                    type: 'string',
                    description: 'Optional custom instruction for the AI prediction',
                    example: 'Analyze this plant leaf and predict if it has any disease.'
                  }
                },
                required: ['image']
              }
            }
          }
        },
        responses: {
          '200': {
            description: 'Successful prediction output',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    success: { type: 'boolean', example: true },
                    prediction: { type: 'string', example: 'Plant: Tomato\nStatus: Early Blight...' }
                  }
                }
              }
            }
          }
        }
      }
    },
    '/api/ai/chat': {
      post: {
        summary: '💬 Chat with AI (Text + Optional Base64 Image)',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  message: { type: 'string', example: 'What is plant disease management?' },
                  image: { type: 'string', description: 'Optional base64 image' }
                }
              }
            }
          }
        },
        responses: {
          '200': { description: 'AI text response' }
        }
      }
    },
    '/api/ai/suggestions': {
      post: {
        summary: '💡 Get AI Suggestions',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  prompt: { type: 'string', example: 'Tips to maintain crop health' }
                },
                required: ['prompt']
              }
            }
          }
        },
        responses: {
          '200': { description: 'List of smart suggestions' }
        }
      }
    },
    '/api/ai/predict-score': {
      post: {
        summary: '📊 Predict Productivity Score',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  userId: { type: 'string', example: 'user1' },
                  data: {
                    type: 'object',
                    example: { tasksCompleted: 8, hoursWorked: 6 }
                  }
                }
              }
            }
          }
        },
        responses: {
          '200': { description: 'Score prediction from 0 to 100' }
        }
      }
    }
  }
};

app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
app.get('/api-docs.json', (req, res) => res.json(swaggerDocument));

// ── Helper: strip markdown code fences Gemini sometimes adds ─────────────────
function cleanJson(text) {
  return text
    .trim()
    .replace(/^```json\s*/i, '')
    .replace(/^```\s*/i, '')
    .replace(/```\s*$/i, '')
    .trim();
}

// ── Helper: parse base64 image string into Gemini generative format ───────────
function parseBase64Image(imageString, defaultMime = 'image/jpeg') {
  if (!imageString || typeof imageString !== 'string') return null;

  let mimeType = defaultMime;
  let data = imageString.trim();

  // Check if string contains data URI prefix (e.g. data:image/png;base64,...)
  const match = data.match(/^data:(image\/[a-zA-Z+]+);base64,(.+)$/s);
  if (match) {
    mimeType = match[1];
    data = match[2];
  }

  return {
    inlineData: {
      data: data.replace(/\s/g, ''), // strip whitespace/newlines
      mimeType: mimeType
    }
  };
}

// ── Root ─────────────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.send('✅ Gen AI Backend is running! Access Interactive Docs at <a href="/docs">http://localhost:3000/docs</a>');
});

// ── Test route ────────────────────────────────────────────────────────────────
app.get('/api/test', (req, res) => {
  res.json({ status: 'Server is working!' });
});

// ── Chat route (Supports Text & Base64 Image) ─────────────────────────────────
app.post('/api/ai/chat', async (req, res) => {
  try {
    const { message, prompt, systemContext, image, base64Image, mimeType } = req.body;
    const userMessage = message || prompt || 'Analyze this image.';

    console.log('💬 Chat request received');
    console.log('   input:', userMessage);

    const imageInput = image || base64Image;
    const imagePart = parseBase64Image(imageInput, mimeType);

    const fullPrompt = systemContext
      ? `${systemContext}\n\nUser: ${userMessage}`
      : `You are a helpful AI assistant.\n\nUser: ${userMessage}`;

    const contents = imagePart ? [fullPrompt, imagePart] : fullPrompt;

    const result = await model.generateContent(contents);
    const reply = result.response.text();

    console.log('✅ Chat reply generated');
    res.json({ reply });

  } catch (error) {
    console.error('❌ Chat error:', error.message);
    res.json({ 
      reply: "I'm currently resting my AI brain due to high demand! Please try again in a moment." 
    });
  }
});

// ── Image Prediction Route ───────────────────────────────────────────────────
app.post(['/api/ai/predict-image', '/api/ai/predict'], async (req, res) => {
  try {
    const { image, base64Image, mimeType, prompt, customPrompt, systemContext } = req.body;
    const rawImage = image || base64Image;

    console.log('📷 Image prediction request received');

    if (!rawImage) {
      return res.status(400).json({ 
        error: 'Image is required. Provide a base64 encoded image string in the "image" or "base64Image" field.' 
      });
    }

    const imagePart = parseBase64Image(rawImage, mimeType);
    if (!imagePart) {
      return res.status(400).json({ error: 'Invalid base64 image data provided.' });
    }

    const defaultPrompt = `Analyze this image carefully. Provide a detailed prediction and diagnosis.
If it is a plant/crop leaf: identify the plant name, disease/condition status (Healthy or Disease Name), confidence estimate, symptoms, causes, and recommended treatment/prevention steps.
If it is another image: identify the main subject, status/prediction details, and key observations.

Return your analysis in a clear, formatted response.`;

    const userPrompt = prompt || customPrompt || defaultPrompt;
    const fullPrompt = systemContext ? `${systemContext}\n\n${userPrompt}` : userPrompt;

    const result = await model.generateContent([fullPrompt, imagePart]);
    const responseText = result.response.text();

    console.log('✅ Image prediction generated successfully');

    // Attempt to parse JSON if model returned JSON
    let parsedResult = null;
    try {
      const cleaned = cleanJson(responseText);
      if (cleaned.startsWith('{') || cleaned.startsWith('[')) {
        parsedResult = JSON.parse(cleaned);
      }
    } catch (e) {
      // ignore JSON parse error
    }

    res.json({
      success: true,
      prediction: responseText,
      result: parsedResult || responseText
    });

  } catch (error) {
    console.error('❌ Image prediction error:', error.message);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to process image prediction.'
    });
  }
});

// ── Suggestions route ─────────────────────────────────────────────────────────
app.post('/api/ai/suggestions', async (req, res) => {
  try {
    const { prompt, userId, context } = req.body;

    console.log('💡 Suggestions request received');
    console.log('   body:', req.body);

    // Accept prompt from any of these fields
    const userPrompt = prompt || context;

    if (!userPrompt) {
      return res.status(400).json({ error: 'prompt field is required' });
    }

    const fullPrompt = `${userPrompt}

Return ONLY a valid JSON array. No explanation, no markdown, no code fences.
Each object must have exactly these fields:
- title (string)
- description (string)  
- category (one of: focus, break, schedule, app_usage)
- priority (one of: high, medium, low)

Example format:
[{"title":"...","description":"...","category":"focus","priority":"high"}]`;

    const result = await model.generateContent(fullPrompt);
    const rawText = result.response.text();

    console.log('📄 Raw Gemini response:', rawText.substring(0, 200));

    const cleanedText = cleanJson(rawText);
    const suggestions = JSON.parse(cleanedText);

    console.log('✅ Suggestions parsed:', suggestions.length, 'items');
    res.json({ suggestions });

  } catch (error) {
    console.error('❌ Suggestions error:', error.message);

    // Return fallback suggestions so the app never crashes
    res.json({
      suggestions: [
        {
          title: 'Try the Pomodoro Technique',
          description: 'Work for 25 minutes, then take a 5-minute break. Repeat 4 times then take a longer break.',
          category: 'focus',
          priority: 'high'
        },
        {
          title: 'Plan Your Top 3 Tasks',
          description: 'Every morning, write down the 3 most important things you need to accomplish today.',
          category: 'schedule',
          priority: 'high'
        },
        {
          title: 'Reduce Social Media',
          description: 'Limit social media to 30 minutes per day. Use app timers to enforce this.',
          category: 'app_usage',
          priority: 'medium'
        },
        {
          title: 'Take Movement Breaks',
          description: 'Every 90 minutes, step away from your screen for at least 5 minutes and move around.',
          category: 'break',
          priority: 'medium'
        },
        {
          title: 'End-of-Day Review',
          description: 'Spend 5 minutes at the end of each day reviewing what you accomplished and planning tomorrow.',
          category: 'schedule',
          priority: 'low'
        }
      ]
    });
  }
});

// ── Predict productivity score ────────────────────────────────────────────────
app.post('/api/ai/predict-score', async (req, res) => {
  try {
    const { userId, data } = req.body;

    console.log('📊 Score prediction request received');

    const prompt = `Based on this productivity data, predict a productivity score from 0 to 100.
Data: ${JSON.stringify(data)}
Return ONLY a JSON object like this: {"predictedScore": 75}
No explanation, no markdown.`;

    const result = await model.generateContent(prompt);
    const rawText = cleanJson(result.response.text());
    const parsed = JSON.parse(rawText);

    console.log('✅ Score predicted:', parsed.predictedScore);
    res.json(parsed);

  } catch (error) {
    console.error('❌ Predict score error:', error.message);
    res.json({ predictedScore: 70 }); // safe fallback
  }
});

// ── Start server ──────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log('');
  console.log('✅ Gen AI Backend is running!');
  console.log(`🌐 Server URL: http://localhost:${PORT}`);
  console.log(`📚 Interactive Docs (FastAPI Style): http://localhost:${PORT}/docs`);
  console.log('');
  console.log('Available routes:');
  console.log('  GET  /docs (Interactive Swagger UI)');
  console.log('  GET  /api/test');
  console.log('  POST /api/ai/predict-image');
  console.log('  POST /api/ai/predict');
  console.log('  POST /api/ai/chat');
  console.log('  POST /api/ai/suggestions');
  console.log('  POST /api/ai/predict-score');
  console.log('');
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`❌ Error: Port ${PORT} is already in use by another process.`);
    console.error(`👉 Close the process using port ${PORT} or run with: $env:PORT=3001; node server.js`);
  } else {
    console.error('❌ Server error:', err.message);
  }
});