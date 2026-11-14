import crypto from 'node:crypto';
import fs from 'node:fs';

function base64Url(input) {
  return Buffer.from(input)
    .toString('base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');
}

async function getAccessToken(serviceAccount) {
  const now = Math.floor(Date.now() / 1000);
  const header = base64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const payload = base64Url(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/datastore',
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: now + 3600,
    }),
  );

  const unsigned = `${header}.${payload}`;
  const signer = crypto.createSign('RSA-SHA256');
  signer.update(unsigned);
  const signature = signer
    .sign(serviceAccount.private_key, 'base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: `${unsigned}.${signature}`,
    }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OAuth token request failed (${res.status}): ${text}`);
  }
  const json = await res.json();
  return json.access_token;
}

function readPubspecVersion() {
  try {
    const content = fs.readFileSync('pubspec.yaml', 'utf8');
    const match = content.match(/^version:\s*([^\s+]+)/m);
    return match ? match[1] : '1.0.0';
  } catch {
    return '1.0.0';
  }
}

async function main() {
  const rawSa = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!rawSa) {
    console.log('FIREBASE_SERVICE_ACCOUNT_JSON not set; skipping Firestore update.');
    return;
  }

  const serviceAccount = JSON.parse(rawSa);
  const projectId = serviceAccount.project_id;
  if (!projectId) {
    throw new Error('Missing project_id in FIREBASE_SERVICE_ACCOUNT_JSON.');
  }

  const platform = process.env.DIST_PLATFORM;
  if (platform !== 'android' && platform !== 'ios') {
    throw new Error(`DIST_PLATFORM must be 'android' or 'ios', got: ${platform}`);
  }

  const buildNumber = Number.parseInt(process.env.DIST_BUILD_NUMBER ?? '', 10);
  if (!Number.isFinite(buildNumber) || buildNumber <= 0) {
    throw new Error(`Invalid DIST_BUILD_NUMBER: ${process.env.DIST_BUILD_NUMBER}`);
  }

  const appVersion = process.env.DIST_VERSION || readPubspecVersion();
  const releaseNotes = (process.env.DIST_RELEASE_NOTES || 'Nová verze GrimGrind').trim();
  const downloadUrl =
    process.env.DIST_URL || 'https://appdistribution.firebase.dev';
  const fallbackUrl = process.env.DIST_FALLBACK_URL || '';

  const fields = {
    latestBuildNumber: { integerValue: String(buildNumber) },
    latestVersion: { stringValue: appVersion },
    releaseNotes: { stringValue: releaseNotes },
    updatedAt: { timestampValue: new Date().toISOString() },
  };

  if (platform === 'android') {
    fields.androidBuildNumber = { integerValue: String(buildNumber) };
    fields.androidVersion = { stringValue: appVersion };
    fields.androidUrl = { stringValue: downloadUrl };
  } else {
    fields.iosBuildNumber = { integerValue: String(buildNumber) };
    fields.iosVersion = { stringValue: appVersion };
    fields.iosUrl = { stringValue: downloadUrl };
  }

  if (fallbackUrl) {
    fields.fallbackUrl = { stringValue: fallbackUrl };
  }

  const maskParams = Object.keys(fields)
    .map((key) => `updateMask.fieldPaths=${encodeURIComponent(key)}`)
    .join('&');

  const endpoint =
    `https://firestore.googleapis.com/v1/projects/${encodeURIComponent(projectId)}` +
    `/databases/(default)/documents/app_config/distribution?${maskParams}`;

  const token = await getAccessToken(serviceAccount);
  const res = await fetch(endpoint, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields }),
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Firestore PATCH failed (${res.status}): ${text}`);
  }

  console.log(
    `Updated app_config/distribution for ${platform} (version=${appVersion}, build=${buildNumber}).`,
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
