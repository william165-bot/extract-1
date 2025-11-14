const path = require('path');
const fs = require('fs');
const express = require('express');
const session = require('express-session');
const helmet = require('helmet');
const morgan = require('morgan');
const bcrypt = require('bcryptjs');
const Database = require('better-sqlite3');
const dayjs = require('dayjs');

const app = express();

const PORT = process.env.PORT || 3000;
const SESSION_SECRET = process.env.SESSION_SECRET || 'change_this_secret';
const APP_BASE_URL = process.env.APP_BASE_URL || `http://localhost:${PORT}`;
const EMBED_URL = process.env.EMBED_URL || 'https://getindevice.com/';
const CROP_TOP_PX = parseInt(process.env.CROP_TOP_PX || '140', 10);

if (!fs.existsSync(path.join(__dirname, 'data'))) {
  fs.mkdirSync(path.join(__dirname, 'data'), { recursive: true });
}

const dbPath = process.env.SQLITE_PATH || path.join(__dirname, 'data', 'db.sqlite3');
const db = new Database(dbPath);

db.exec(`
  PRAGMA journal_mode = WAL;
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    trial_started_at INTEGER NOT NULL,
    premium_until INTEGER,
    last_payment_at INTEGER
  );
`);

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
const expressLayouts = require('express-ejs-layouts');
app.use(expressLayouts);
app.set('layout', 'layout');

app.use(helmet());
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(morgan('dev'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(
  session({
    name: 'nethunt.sid',
    secret: SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      sameSite: 'lax',
      secure: !!process.env.RENDER || process.env.NODE_ENV === 'production'
    }
  })
);

function setFlash(req, type, message) {
  req.session.flash = { type, message };
}

function getFlash(req) {
  const f = req.session.flash;
  delete req.session.flash;
  return f;
}

function currentUser(req) {
  if (!req.session.userId) return null;
  const stmt = db.prepare('SELECT * FROM users WHERE id = ?');
  const user = stmt.get(req.session.userId);
  return user || null;
}

function isTrialActive(user) {
  if (!user) return false;
  const start = user.trial_started_at || user.created_at;
  const expires = start + 24 * 60 * 60 * 1000;
  return Date.now() < expires;
}

function isPremiumActive(user) {
  if (!user || !user.premium_until) return false;
  return Date.now() < user.premium_until;
}

function canAccessEmbed(user) {
  return isTrialActive(user) || isPremiumActive(user);
}

function requireAuth(req, res, next) {
  if (!req.session.userId) {
    return res.redirect('/signin');
  }
  next();
}

function requireAdmin(req, res, next) {
  if (!req.session.isAdmin) {
    return res.redirect('/admin/login');
  }
  next();
}

app.use((req, res, next) => {
  res.locals.flash = getFlash(req);
  res.locals.user = currentUser(req);
  res.locals.brand = 'Nethunt URL Extractor';
  res.locals.appBaseUrl = APP_BASE_URL;
  res.locals.embedUrl = EMBED_URL;
  res.locals.cropTop = CROP_TOP_PX;
  next();
});

app.get('/', (req, res) => {
  if (!req.session.userId) return res.redirect('/signin');
  res.redirect('/app');
});

app.get('/signup', (req, res) => {
  res.render('auth/signup', { title: 'Sign up' });
});

app.post('/signup', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    setFlash(req, 'error', 'Please provide email and password.');
    return res.redirect('/signup');
  }
  const emailLower = String(email).trim().toLowerCase();
  if (!emailLower.endsWith('@gmail.com')) {
    setFlash(req, 'error', 'Only @gmail.com emails are allowed.');
    return res.redirect('/signup');
  }
  const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(emailLower);
  if (existing) {
    setFlash(req, 'error', 'Account already exists. Please sign in.');
    return res.redirect('/signin');
  }
  const hash = bcrypt.hashSync(password, 10);
  const now = Date.now();
  const info = db
    .prepare('INSERT INTO users (email, password_hash, created_at, trial_started_at) VALUES (?, ?, ?, ?)')
    .run(emailLower, hash, now, now);
  req.session.userId = info.lastInsertRowid;
  setFlash(req, 'success', 'Welcome! Your 1-day free trial has started.');
  res.redirect('/app');
});

app.get('/signin', (req, res) => {
  if (req.session.userId) return res.redirect('/app');
  res.render('auth/signin', { title: 'Sign in' });
});

app.post('/signin', (req, res) => {
  const { email, password } = req.body;
  const emailLower = String(email || '').trim().toLowerCase();
  const user = db.prepare('SELECT * FROM users WHERE email = ?').get(emailLower);
  if (!user) {
    setFlash(req, 'error', 'Account not found. Please sign up first.');
    return res.redirect('/signin');
  }
  const ok = bcrypt.compareSync(password || '', user.password_hash);
  if (!ok) {
    setFlash(req, 'error', 'Invalid credentials.');
    return res.redirect('/signin');
  }
  req.session.userId = user.id;
  setFlash(req, 'success', 'Signed in successfully.');
  res.redirect('/app');
});

app.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/signin');
  });
});

app.get('/app', requireAuth, (req, res) => {
  const user = res.locals.user;
  const trialActive = isTrialActive(user);
  const premiumActive = isPremiumActive(user);
  const canAccess = trialActive || premiumActive;
  const trialEndsAt = user.trial_started_at + 24 * 60 * 60 * 1000;
  res.render('app', {
    title: 'App',
    canAccess,
    trialActive,
    premiumActive,
    trialEndsAt,
    premiumUntil: user.premium_until || null
  });
});

app.get('/upgrade', requireAuth, (req, res) => {
  res.render('upgrade', { title: 'Upgrade' });
});

app.get('/pay', requireAuth, (req, res) => {
  req.session.paymentIntentAt = Date.now();
  res.redirect('https://flutterwave.com/pay/7k8wh62jmtzh');
});

app.get('/payment/unlock', requireAuth, (req, res) => {
  const user = res.locals.user;
  const now = Date.now();
  const premiumUntil = dayjs(now).add(1, 'month').valueOf();
  db.prepare('UPDATE users SET premium_until = ?, last_payment_at = ? WHERE id = ?').run(premiumUntil, now, user.id);
  setFlash(req, 'success', 'Premium unlocked for 1 month.');
  res.redirect('/app');
});

app.get('/admin/login', (req, res) => {
  res.render('admin/login', { title: 'Admin Login' });
});

app.post('/admin/login', (req, res) => {
  const { username, password } = req.body;
  if (username === 'nethunter' && password === 'cbtpratice@nethunter') {
    req.session.isAdmin = true;
    return res.redirect('/admin');
  }
  setFlash(req, 'error', 'Invalid admin credentials.');
  res.redirect('/admin/login');
});

app.post('/admin/logout', (req, res) => {
  req.session.isAdmin = false;
  res.redirect('/admin/login');
});

app.get('/admin', requireAdmin, (req, res) => {
  const users = db.prepare('SELECT * FROM users ORDER BY created_at DESC').all();
  const paidUsers = users.filter(u => u.premium_until && Date.now() < u.premium_until);
  res.render('admin/dashboard', {
    title: 'Admin Dashboard',
    users,
    paidUsers
  });
});

app.post('/admin/grant/:id', requireAdmin, (req, res) => {
  const id = parseInt(req.params.id, 10);
  const until = dayjs().add(1, 'month').valueOf();
  db.prepare('UPDATE users SET premium_until = ? WHERE id = ?').run(until, id);
  setFlash(req, 'success', 'Premium granted.');
  res.redirect('/admin');
});

app.post('/admin/revoke/:id', requireAdmin, (req, res) => {
  const id = parseInt(req.params.id, 10);
  db.prepare('UPDATE users SET premium_until = NULL WHERE id = ?').run(id);
  setFlash(req, 'success', 'Premium revoked.');
  res.redirect('/admin');
});

app.get('/healthz', (req, res) => {
  res.json({ ok: true });
});

app.listen(PORT, () => {
  console.log(`Server running on ${APP_BASE_URL}`);
});
