BEGIN;

CREATE TABLE users(
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp, 
    disabled_at TIMESTAMPTZ NULL,
    api_key UUID NOT NULL DEFAULT gen_random_uuid()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

COMMENT ON COLUMN users.id IS 'Unique identifier for each user.';
COMMENT ON COLUMN users.first_name IS 'User Information: First Name';
COMMENT ON COLUMN users.last_name IS 'User Information: Last Name';
COMMENT ON COLUMN users.email IS 'User email for login.';
COMMENT ON COLUMN users.password IS 'User password for authentication.';
COMMENT ON COLUMN users.created_at IS 'When the user account was created.';
COMMENT ON COLUMN users.last_updated_at IS 'When the user account was last updated';
COMMENT ON COLUMN users.disabled_at IS 'When the user account was disabled / eliminated';
COMMENT ON COLUMN users.api_key IS 'This will be used a an API key';

CREATE TABLE qr_codes(
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    owner UUID NULL REFERENCES users (id),
    type VARCHAR(25) NOT NULL, 
    content VARCHAR(255),
    image_url TEXT,
    dynamic_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    is_active BOOLEAN NOT NULL DEFAULT 't',
    scanned_times BIGINT DEFAULT 0
);

CREATE INDEX idx_qr_codes_owner ON qr_codes(owner);
CREATE INDEX idx_qr_codes_type ON qr_codes(type);
CREATE INDEX idx_qr_codes_created_at ON qr_codes(created_at);


COMMENT ON COLUMN qr_codes.id IS 'Unique identifier for each QR code.';
COMMENT ON COLUMN qr_codes.owner IS 'ID of the user who created/owns this QR code.';
COMMENT ON COLUMN qr_codes.type IS 'Type of QR code: static or dynamic.';
COMMENT ON COLUMN qr_codes.content IS 'Embedded content for static QR codes, like URL or text.';
COMMENT ON COLUMN qr_codes.image_url IS 'URL where the generated QR code image is stored.';
COMMENT ON COLUMN qr_codes.dynamic_url IS 'Redirect URL for dynamic QR codes that can be updated.';
COMMENT ON COLUMN qr_codes.created_at IS 'Timestamp of QR code creation.';
COMMENT ON COLUMN qr_codes.last_updated_at IS 'Timestamp of the last update to the QR code.';
COMMENT ON COLUMN qr_codes.is_active IS 'Indicates whether the QR code is currently active.';
COMMENT ON COLUMN qr_codes.scanned_times IS 'Number of times the QR code has been scanned.';


CREATE TABLE qr_code_versions(
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    qr_code UUID NOT NULL REFERENCES qr_codes(id),
    old_url TEXT NULL,
    new_url TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    disabled_at TIMESTAMPTZ NULL,
    modified_by UUID NULL REFERENCES users (id)
);

CREATE INDEX idx_qr_code_versions_qr_code ON qr_code_versions(qr_code);


COMMENT ON COLUMN qr_code_versions.id IS 'Unique identifier for each version of a dynamic QR code.';
COMMENT ON COLUMN qr_code_versions.qr_code IS 'Foreign key linking to the main QR code.';
COMMENT ON COLUMN qr_code_versions.old_url IS 'Previous URL of the QR code before the update.';
COMMENT ON COLUMN qr_code_versions.new_url IS 'New URL assigned to the QR code in this version.';
COMMENT ON COLUMN qr_code_versions.created_at IS 'Timestamp when this QR code version was created.';
COMMENT ON COLUMN qr_code_versions.disabled_at IS 'Timestamp when this version was disabled, if applicable.';
COMMENT ON COLUMN qr_code_versions.modified_by IS 'ID of the user who modified the URL.';


ALTER TABLE qr_codes ADD version UUID NULL REFERENCES qr_code_versions (id);
COMMENT ON COLUMN qr_codes.version IS 'Reference to the current version of the dynamic QR code.';

CREATE TABLE events(
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    type VARCHAR(25) NOT NULL,
    qr_code UUID NULL REFERENCES qr_codes(id),
    location TEXT NULL,
    device_type VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    created_by UUID NULL REFERENCES users (id),
    ip_address VARCHAR(255) 
);

CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_events_type ON events(type);
CREATE INDEX idx_events_created_at ON events(created_at);
CREATE INDEX idx_events_qr_code ON events(qr_code);

COMMENT ON COLUMN events.id IS 'Unique identifier for each event.';
COMMENT ON COLUMN events.type IS 'Type of event (e.g., scan or view).';
COMMENT ON COLUMN events.qr_code IS 'ID of the QR code associated with this event.';
COMMENT ON COLUMN events.location IS 'Location information where the event occurred.';
COMMENT ON COLUMN events.device_type IS 'Type of device that triggered the event, like mobile or desktop.';
COMMENT ON COLUMN events.created_at IS 'Timestamp when the event occurred.';
COMMENT ON COLUMN events.created_by IS 'ID of the user who triggered the event, if applicable.';
COMMENT ON COLUMN events.ip_address IS 'IP address associated with the event, useful for geolocation.';


CREATE TABLE subscriptions(
    id UUID UNIQUE NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
    owned_by UUID NULL REFERENCES users (id),
    type VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp,
    start_date TIMESTAMPTZ NULL,
    end_date TIMESTAMPTZ NULL,
    is_active BOOLEAN NOT NULL DEFAULT 'f',
    renewal_times INT DEFAULT 0,
    last_updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', NOW())::timestamp
);

CREATE INDEX idx_subscriptions_type ON subscriptions(type);
CREATE INDEX idx_subscriptions_owner ON subscriptions(owned_by);

COMMENT ON COLUMN subscriptions.id IS 'Unique identifier for each subscription.';
COMMENT ON COLUMN subscriptions.owned_by IS 'ID of the user associated with the subscription.';
COMMENT ON COLUMN subscriptions.type IS 'Type of subscription, like free or premium.';
COMMENT ON COLUMN subscriptions.created_at IS 'Timestamp when the subscription was created.';
COMMENT ON COLUMN subscriptions.start_date IS 'Start date of the subscription.';
COMMENT ON COLUMN subscriptions.end_date IS 'End date of the subscription, if applicable.';
COMMENT ON COLUMN subscriptions.is_active IS 'Indicates if the subscription is currently active.';
COMMENT ON COLUMN subscriptions.renewal_times IS 'Number of times the subscription has been renewed.';
COMMENT ON COLUMN subscriptions.last_updated_at IS 'Timestamp of the last update to the subscription';

COMMIT;

--- TRIGGERS ---
CREATE OR REPLACE FUNCTION trigger_set_timestamp ()
	RETURNS TRIGGER
	AS $$
BEGIN
	ROW_TO_UPDATE.last_updated_at = timezone('utc', NOW())::timestamp;
	RETURN ROW_TO_UPDATE;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_users
	BEFORE UPDATE ON users
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp ();

CREATE TRIGGER set_timestamp_qr_codes
	BEFORE UPDATE ON qr_codes
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp ();

CREATE TRIGGER set_timestamp_events
	BEFORE UPDATE ON subscriptions
	FOR EACH ROW
	EXECUTE PROCEDURE trigger_set_timestamp ();