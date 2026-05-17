SET search_path TO nutrionista;

-- ─── Catalog (foundation) ──────────────────────────────────────────────────

CREATE TABLE category (
                          id          SERIAL PRIMARY KEY,
                          name        VARCHAR(100) UNIQUE NOT NULL,
                          description TEXT
);

CREATE TABLE nutrient (
                          id             SERIAL PRIMARY KEY,
                          name           VARCHAR(100) UNIQUE NOT NULL,
                          description    VARCHAR(500),
                          category_id    INTEGER NOT NULL REFERENCES category(id),
                          price          NUMERIC(8,2) NOT NULL DEFAULT 0 CHECK (price >= 0),  -- € amount
                          stock_quantity INTEGER NOT NULL,
                          created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Back-pointer FK: each image row knows which nutrient it belongs to.
-- This is the v2 inversion — Rev. 4 had nutrient.image_id pointing the other way.
CREATE TABLE nutrient_image (
                                id          SERIAL PRIMARY KEY,
                                nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
                                image_data  BYTEA NOT NULL
);

CREATE TABLE property (
                          id          SERIAL PRIMARY KEY,
                          type        VARCHAR(3)  NOT NULL,   -- FN | AM | AF | DS discriminator
                          name        VARCHAR(150) NOT NULL,
                          description VARCHAR(150)
);

-- effect_type was missing in the v2 XML but referenced by the CHECK; fixed here.
-- Nullable: only set for absorption-factor (type='AF') rows.
CREATE TABLE nutrient_property (
                                   id          SERIAL PRIMARY KEY,
                                   nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
                                   property_id INTEGER NOT NULL REFERENCES property(id),
                                   effect_type VARCHAR(10),
                                   CONSTRAINT nutrient_property_effect_ck CHECK (effect_type IN ('ENHANCE','INHIBIT'))
);

CREATE TABLE color_code (
                            id         SERIAL PRIMARY KEY,
                            name       VARCHAR(10) UNIQUE NOT NULL,   -- GOOD | NEUTRAL | BAD
                            color_code VARCHAR(10) NOT NULL           -- e.g. "#22c55e"
);

CREATE TABLE nutrient_interaction (
                                      id                  SERIAL PRIMARY KEY,
                                      nutrient_id         INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
                                      related_nutrient_id INTEGER NOT NULL REFERENCES nutrient(id) ON DELETE CASCADE,
                                      interaction_type_id INTEGER NOT NULL REFERENCES color_code(id),
                                      description         VARCHAR(200),
                                      CONSTRAINT nutrient_interaction_self_ck CHECK (nutrient_id <> related_nutrient_id)
);

-- ─── Identity ──────────────────────────────────────────────────────────────

CREATE TABLE role (
                      id   SERIAL PRIMARY KEY,
                      name VARCHAR(10) UNIQUE NOT NULL   -- ADMIN | USER
);

-- "user" is a PostgreSQL reserved word — hence the double quotes.
CREATE TABLE "user" (
                        id            SERIAL PRIMARY KEY,
                        username      VARCHAR(50) UNIQUE NOT NULL,
                        password_hash VARCHAR(60) NOT NULL,           -- bcrypt output (always 60 chars)
                        created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        role_id       INTEGER NOT NULL REFERENCES role(id)
);

-- ─── Shipping & billing ────────────────────────────────────────────────────

CREATE TABLE courier (
                         id           SERIAL PRIMARY KEY,
                         name         VARCHAR(255) NOT NULL,
                         type         CHAR(1) NOT NULL,        -- P = parcel-locker, H = home, S = in-store
                         api_key      VARCHAR(255),
                         endpoint_url VARCHAR(255)
);

CREATE TABLE billing (
                         id         SERIAL PRIMARY KEY,
                         first_name VARCHAR(255) NOT NULL,
                         last_name  VARCHAR(255) NOT NULL,
                         address    VARCHAR(255) NOT NULL,
                         courier_id INTEGER REFERENCES courier(id)   -- nullable when collect_from_store
);

-- ─── Commerce ──────────────────────────────────────────────────────────────

CREATE TABLE cart (
                      id      SERIAL PRIMARY KEY,
                      user_id INTEGER NOT NULL REFERENCES "user"(id) ON DELETE CASCADE
);

CREATE TABLE cart_item (
                           id          SERIAL PRIMARY KEY,
                           cart_id     INTEGER NOT NULL REFERENCES cart(id) ON DELETE CASCADE,
                           nutrient_id INTEGER NOT NULL REFERENCES nutrient(id),
                           quantity    INTEGER NOT NULL
);

-- "order" is a PostgreSQL reserved word — hence the double quotes.
CREATE TABLE "order" (
                         id                 SERIAL PRIMARY KEY,
                         billing_id         INTEGER NOT NULL REFERENCES billing(id),
                         total_sum          NUMERIC(8,2) NOT NULL,
                         status             CHAR(1) NOT NULL,            -- P pending | A paid | S shipped | C cancelled
                         collect_from_store BOOLEAN NOT NULL
);

CREATE TABLE order_item (
                            id          SERIAL PRIMARY KEY,
                            order_id    INTEGER NOT NULL REFERENCES "order"(id) ON DELETE CASCADE,
                            nutrient_id INTEGER NOT NULL REFERENCES nutrient(id),
                            price       NUMERIC(8,2) NOT NULL,   -- snapshot of nutrient.price at checkout
                            quantity    INTEGER NOT NULL,
                            total_sum   NUMERIC(8,2) NOT NULL    -- = price * quantity, computed in the service
);

-- ─── Feedback ──────────────────────────────────────────────────────────────

CREATE TABLE contact (
                         id         SERIAL PRIMARY KEY,
                         user_id    INTEGER NOT NULL REFERENCES "user"(id),
                         first_name VARCHAR(255) NOT NULL,
                         last_name  VARCHAR(255) NOT NULL
);