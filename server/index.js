const express = require('express');
const https = require('https');
const http = require('http');
const { URL } = require('url');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

const QF_ENV = process.env.QF_ENV || 'production';
const CLIENT_ID = process.env.QF_CLIENT_ID || '';
const CLIENT_SECRET = process.env.QF_CLIENT_SECRET || '';

// Base URLs
const OAUTH_BASE_URL = QF_ENV === 'prelive'
  ? 'https://prelive-oauth2.quran.foundation'
  : 'https://oauth2.quran.foundation';

const CONTENT_API_BASE_URL = QF_ENV === 'prelive'
  ? 'https://prelive-api.quran.com/api/v4'
  : 'https://api.quran.com/api/v4';

// In-Memory Token Cache
let tokenCache = {
  accessToken: null,
  expiresAt: 0,
};

// Helper: Make HTTP/HTTPS Request
function makeHttpRequest(targetUrl, options = {}, postData = null) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(targetUrl);
    const transport = urlObj.protocol === 'https:' ? https : http;

    const reqOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: `${urlObj.pathname}${urlObj.search}`,
      method: options.method || 'GET',
      headers: options.headers || {},
    };

    const req = transport.request(reqOptions, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data,
        });
      });
    });

    req.on('error', (err) => reject(err));
    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

// OAuth2 Token Fetching / Refreshing
async function getAccessToken() {
  // If no credentials configured yet, return null (fallback to public API)
  if (!CLIENT_ID || !CLIENT_SECRET) {
    return null;
  }

  // Check if current cached token is valid (with 60-second safety buffer)
  if (tokenCache.accessToken && Date.now() < tokenCache.expiresAt - 60000) {
    return tokenCache.accessToken;
  }

  try {
    const tokenUrl = `${OAUTH_BASE_URL}/oauth2/token`;
    const postData = new URLSearchParams({
      grant_type: 'client_credentials',
      scope: 'content',
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
    }).toString();

    const authHeader = 'Basic ' + Buffer.from(`${CLIENT_ID}:${CLIENT_SECRET}`).toString('base64');

    const res = await makeHttpRequest(tokenUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': authHeader,
        'Content-Length': Buffer.byteLength(postData),
      },
    }, postData);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      const json = JSON.parse(res.body);
      tokenCache.accessToken = json.access_token;
      tokenCache.expiresAt = Date.now() + ((json.expires_in || 3600) * 1000);
      console.log('[QuranProxy] Successfully fetched new OAuth2 access token.');
      return tokenCache.accessToken;
    } else {
      console.warn(`[QuranProxy] OAuth token request failed (${res.statusCode}): ${res.body}`);
      return null;
    }
  } catch (err) {
    console.error('[QuranProxy] OAuth token fetch error:', err.message);
    return null;
  }
}

// Core Proxy Function with 401 retry logic
async function proxyToQuranApi(endpointPath, reqQuery, res) {
  try {
    const queryString = new URLSearchParams(reqQuery).toString();
    const fullUrl = `${CONTENT_API_BASE_URL}${endpointPath}${queryString ? '?' + queryString : ''}`;

    let token = await getAccessToken();

    const getHeaders = (authToken) => {
      const headers = { 'Accept': 'application/json' };
      if (authToken) {
        headers['x-auth-token'] = authToken;
        headers['Authorization'] = `Bearer ${authToken}`;
      }
      if (CLIENT_ID) {
        headers['x-client-id'] = CLIENT_ID;
      }
      return headers;
    };

    let apiRes = await makeHttpRequest(fullUrl, {
      method: 'GET',
      headers: getHeaders(token),
    });

    // 401 Handling: Invalidate token and retry once
    if (apiRes.statusCode === 401 && CLIENT_ID && CLIENT_SECRET) {
      console.warn('[QuranProxy] Received 401 from Quran API. Invalidation token and retrying...');
      tokenCache.accessToken = null;
      tokenCache.expiresAt = 0;
      token = await getAccessToken();

      apiRes = await makeHttpRequest(fullUrl, {
        method: 'GET',
        headers: getHeaders(token),
      });
    }

    res.status(apiRes.statusCode);
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.send(apiRes.body);
  } catch (err) {
    console.error(`[QuranProxy] Proxy error for ${endpointPath}:`, err.message);
    return res.status(502).json({
      error: 'Proxy Error',
      message: 'Failed to communicate with Quran Foundation API',
      details: err.message,
    });
  }
}

// API Routes
app.get('/api/chapters', (req, res) => proxyToQuranApi('/chapters', req.query, res));
app.get('/api/chapters/:id', (req, res) => proxyToQuranApi(`/chapters/${req.params.id}`, req.query, res));
app.get('/api/verses/by_chapter/:chapter', (req, res) => proxyToQuranApi(`/verses/by_chapter/${req.params.chapter}`, req.query, res));
app.get('/api/resources/translations', (req, res) => proxyToQuranApi('/resources/translations', req.query, res));
app.get('/api/search', (req, res) => proxyToQuranApi('/search', req.query, res));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    environment: QF_ENV,
    hasCredentials: Boolean(CLIENT_ID && CLIENT_SECRET),
    tokenCached: Boolean(tokenCache.accessToken),
  });
});

app.listen(PORT, () => {
  console.log(`[QuranProxy] RouteQible Quran API Proxy running on port ${PORT}`);
  console.log(`[QuranProxy] Environment: ${QF_ENV}`);
  if (!CLIENT_ID || !CLIENT_SECRET) {
    console.log('[QuranProxy] Note: QF_CLIENT_ID / QF_CLIENT_SECRET not set. Operating in fallback mode.');
  }
});
