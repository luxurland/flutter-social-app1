/* ============================================
   USERS
============================================ */
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    banned INTEGER DEFAULT 0,
    user_hex_id TEXT UNIQUE
);

/* ============================================
   WALLETS
============================================ */
CREATE TABLE IF NOT EXISTS wallets (
    user_id INTEGER PRIMARY KEY,
    balance REAL NOT NULL DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
);

/* ============================================
   TRANSACTIONS
============================================ */
CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    type TEXT NOT NULL,
    feature_key TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
);

/* ============================================
   FEATURE PRICES
============================================ */
CREATE TABLE IF NOT EXISTS feature_prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    feature_key TEXT UNIQUE NOT NULL,
    price REAL NOT NULL,
    currency TEXT DEFAULT 'EUR',
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

/* ============================================
   CALLS
============================================ */
CREATE TABLE IF NOT EXISTS calls (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    creator_id INTEGER NOT NULL,
    call_type TEXT NOT NULL,
    start_time TEXT,
    end_time TEXT,
    expires_at TEXT,
    total_price REAL DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(creator_id) REFERENCES users(id)
);

/* ============================================
   CALL PARTICIPANTS
============================================ */
CREATE TABLE IF NOT EXISTS call_participants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    call_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    joined_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(call_id) REFERENCES calls(id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

/* ============================================
   CALL TEMP WALLET
============================================ */
CREATE TABLE IF NOT EXISTS call_temp_wallet (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    call_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    amount REAL NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(call_id) REFERENCES calls(id),
    FOREIGN KEY(user_id) REFERENCES users(id)
);

/* ============================================
   STORES
============================================ */
CREATE TABLE IF NOT EXISTS stores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES users(id)
);

/* ============================================
   PRODUCTS
============================================ */
CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    store_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    hidden INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(store_id) REFERENCES stores(id)
);

/* ============================================
   PERSONAL POSTS
============================================ */
CREATE TABLE IF NOT EXISTS posts_personal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    public_id TEXT UNIQUE NOT NULL,
    post_hex_id TEXT NOT NULL,
    owner_id INTEGER NOT NULL,
    cid TEXT NOT NULL,
    type TEXT NOT NULL,
    hidden INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES users(id)
);

/* ============================================
   MERCHANT POSTS
============================================ */
CREATE TABLE IF NOT EXISTS posts_product (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    public_id TEXT UNIQUE NOT NULL,
    post_hex_id TEXT NOT NULL,
    owner_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    cid TEXT NOT NULL,
    type TEXT NOT NULL,
    hidden INTEGER DEFAULT 0,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES users(id),
    FOREIGN KEY(product_id) REFERENCES products(id)
);

/* ============================================
   REPORTS
============================================ */
CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_type TEXT NOT NULL,
    post_public_id TEXT NOT NULL,
    reporter_id INTEGER NOT NULL,
    reason TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(reporter_id) REFERENCES users(id)
);

/* ============================================
   FEATURE PRICES SEED
============================================ */
INSERT OR IGNORE INTO feature_prices (feature_key, price) VALUES
('call_voice_5min', 0.05),
('call_voice_15min', 0.20),
('call_voice_30min', 0.40),
('call_voice_60min', 0.80),
('call_video_5min', 0.10),
('call_video_15min', 0.40),
('call_video_30min', 0.80),
('call_video_60min', 1.50);
