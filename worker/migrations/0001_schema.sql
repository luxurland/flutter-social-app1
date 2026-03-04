-- wallets: each user's balance
CREATE TABLE IF NOT EXISTS wallets ( 
user_id TEXT PRIMARY KEY, 
balance REAL NOT NULL DEFAULT 0, 
updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Transactions: All shipping/discount transactions
CREATE TABLE IF NOT EXISTS transactions ( 
id TEXT PRIMARY KEY, 
user_id TEXT NOT NULL, 
amount REAL NOT NULL, 
type TEXT NOT NULL, -- charge / money / payout 
feature_key TEXT, 
created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- feature_prices: Feature prices (subject to modification later)
CREATE TABLE IF NOT EXISTS feature_prices ( 
id TEXT PRIMARY KEY, 
feature_key TEXT UNIQUE NOT NULL, 
price REAL NOT NULL, 
currency TEXT DEFAULT 'EUR', 
updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- calls: call data
CREATE TABLE IF NOT EXISTS CALLS ( 
id TEXT PRIMARY KEY, 
creator_id TEXT NOT NULL, 
call_type TEXT NOT NULL, -- voice/video 
start_time TEXT, 
end_time TEXT, 
expires_at TEXT, 
total_price REAL DEFAULT 0, 
created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- call_participants: Call participants
CREATE TABLE IF NOT EXISTS call_participants ( 
id TEXT PRIMARY KEY, 
call_id TEXT NOT NULL, 
user_id TEXT NOT NULL, 
joined_at TEXT DEFAULT CURRENT_TIMESTAMP, 
FOREIGN KEY(call_id) REFERENCES calls(id)
);

-- call_temp_wallet: Temporary discounts for each call
CREATE TABLE IF NOT EXISTS call_temp_wallet ( 
id TEXT PRIMARY KEY, 
call_id TEXT NOT NULL, 
user_id TEXT NOT NULL, 
amount REAL NOT NULL, 
created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Current call rates (you can edit them later from the admin panel)

-- VOICE
INSERT OR IGNORE INTO feature_prices (id, feature_key, price)
VALUES

(lower(hex(randomblob(16))), 'call_voice_5min', 0.05),

(lower(hex(randomblob(16))), 'call_voice_15min', 0.20),

(lower(hex(randomblob(16))), 'call_voice_30min', 0.40),

(lower(hex(randomblob(16))), 'call_voice_60min', 0.80),

-- VIDEO

(lower(hex(randomblob(16))), 'call_video_5min', 0.10),

(lower(hex(randomblob(16))), 'call_video_15min', 0.40), 
(lower(hex(randomlob(16))), 'call_video_30min', 0.80), 
(lower(hex(randomlob(16))), 'call_video_60min', 1.50);
