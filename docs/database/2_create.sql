-- =============================================================
-- Full DDL – Nutrient Shop Database
-- Engine: PostgreSQL 18
-- =============================================================

SET search_path TO nutrionista;

-- -------------------------------------------------------------
-- 1. category
-- -------------------------------------------------------------
CREATE TABLE category
(
    id          SERIAL       NOT NULL,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    CONSTRAINT category_pk PRIMARY KEY (id),
    CONSTRAINT category_name_uq UNIQUE (name)
);

-- -------------------------------------------------------------
-- 2. color_code
-- -------------------------------------------------------------
CREATE TABLE color_code
(
    id         SERIAL      NOT NULL,
    name       VARCHAR(10) NOT NULL,
    color_code VARCHAR(10) NOT NULL,
    CONSTRAINT color_code_pk PRIMARY KEY (id),
    CONSTRAINT color_code_name_uq UNIQUE (name)
);

-- -------------------------------------------------------------
-- 3. property
-- -------------------------------------------------------------
CREATE TABLE property
(
    id          SERIAL       NOT NULL,
    type        VARCHAR(3)   NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description VARCHAR(150),
    CONSTRAINT property_pk PRIMARY KEY (id)
);

-- -------------------------------------------------------------
-- 4. role
-- -------------------------------------------------------------
CREATE TABLE role
(
    id   SERIAL      NOT NULL,
    name VARCHAR(10) NOT NULL,
    CONSTRAINT role_pk PRIMARY KEY (id),
    CONSTRAINT role_name_uq UNIQUE (name)
);

-- -------------------------------------------------------------
-- 5. courier
-- -------------------------------------------------------------
CREATE TABLE courier
(
    id           SERIAL       NOT NULL,
    name         VARCHAR(255) NOT NULL,
    type         CHAR(1)      NOT NULL,
    api_key      VARCHAR(255),
    endpoint_url VARCHAR(255),
    CONSTRAINT courier_pk PRIMARY KEY (id)
);

-- -------------------------------------------------------------
-- 6. nutrient
-- -------------------------------------------------------------
CREATE TABLE nutrient
(
    id             SERIAL        NOT NULL,
    name           VARCHAR(100)  NOT NULL,
    description    VARCHAR(500),
    category_id    INT           NOT NULL,
    price          NUMERIC(8, 2) NOT NULL,
    stock_quantity INT           NOT NULL,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT nutrient_pk PRIMARY KEY (id),
    CONSTRAINT nutrient_name_uq UNIQUE (name),
    CONSTRAINT nutrient_price_ck CHECK (price >= 0),
    CONSTRAINT nutrient_category_fk
        FOREIGN KEY (category_id) REFERENCES category (id)
);

-- -------------------------------------------------------------
-- 7. nutrient_image
-- -------------------------------------------------------------
CREATE TABLE nutrient_image
(
    id          SERIAL        NOT NULL,
    nutrient_id INT           NOT NULL,
    image_url   VARCHAR(1000) NOT NULL,
    CONSTRAINT nutrient_image_pk PRIMARY KEY (id),
    CONSTRAINT nutrient_image_nutrient_fk
        FOREIGN KEY (nutrient_id) REFERENCES nutrient (id)
            ON DELETE CASCADE
);

-- -------------------------------------------------------------
-- 8. nutrient_interaction
-- -------------------------------------------------------------
CREATE TABLE nutrient_interaction
(
    id                  SERIAL NOT NULL,
    nutrient_id         INT    NOT NULL,
    related_nutrient_id INT    NOT NULL,
    interaction_type_id INT    NOT NULL,
    description         VARCHAR(200),
    CONSTRAINT nutrient_interaction_pk PRIMARY KEY (id),
    CONSTRAINT nutrient_interaction_self_ck CHECK (nutrient_id <> related_nutrient_id),
    CONSTRAINT nutrient_interaction_nutrient_fk
        FOREIGN KEY (nutrient_id) REFERENCES nutrient (id)
            ON DELETE CASCADE,
    CONSTRAINT nutrient_interaction_related_nutrient_fk
        FOREIGN KEY (related_nutrient_id) REFERENCES nutrient (id)
            ON DELETE CASCADE,
    CONSTRAINT nutrient_interaction_color_code_fk
        FOREIGN KEY (interaction_type_id) REFERENCES color_code (id)
);

-- -------------------------------------------------------------
-- 9. nutrient_property
-- -------------------------------------------------------------
CREATE TABLE nutrient_property
(
    id          SERIAL      NOT NULL,
    nutrient_id INT         NOT NULL,
    property_id INT         NOT NULL,
    effect_type VARCHAR(10) NULL,
    CONSTRAINT nutrient_property_pk PRIMARY KEY (id),
    CONSTRAINT nutrient_property_effect_ck CHECK (effect_type IN ('ENHANCE', 'INHIBIT')),
    CONSTRAINT nutrient_property_nutrient_fk
        FOREIGN KEY (nutrient_id) REFERENCES nutrient (id)
            ON DELETE CASCADE,
    CONSTRAINT nutrient_property_property_fk
        FOREIGN KEY (property_id) REFERENCES property (id)
);

-- -------------------------------------------------------------
-- 10. user
-- -------------------------------------------------------------
CREATE TABLE "user"
(
    id         SERIAL      NOT NULL,
    email      VARCHAR(50) NOT NULL,
    password   VARCHAR(60) NOT NULL,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role_id    INT         NOT NULL,
    CONSTRAINT user_pk PRIMARY KEY (id),
    CONSTRAINT user_email_uq UNIQUE (email),
    CONSTRAINT user_role_fk
        FOREIGN KEY (role_id) REFERENCES role (id)
);

-- -------------------------------------------------------------
-- 11. contact
-- -------------------------------------------------------------
CREATE TABLE contact
(
    id         SERIAL       NOT NULL,
    user_id    INT          NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name  VARCHAR(255) NOT NULL,
    CONSTRAINT contact_pk PRIMARY KEY (id),
    CONSTRAINT contact_user
        FOREIGN KEY (user_id) REFERENCES "user" (id)
);

-- -------------------------------------------------------------
-- 12. cart
-- -------------------------------------------------------------
CREATE TABLE cart
(
    id      SERIAL NOT NULL,
    user_id INT    NOT NULL,
    CONSTRAINT cart_pk PRIMARY KEY (id),
    CONSTRAINT cart_user
        FOREIGN KEY (user_id) REFERENCES "user" (id)
);

-- -------------------------------------------------------------
-- 13. cart_item
-- -------------------------------------------------------------
CREATE TABLE cart_item
(
    id          SERIAL NOT NULL,
    nutrient_id INT    NOT NULL,
    cart_id     INT    NOT NULL,
    quantity    INT    NOT NULL,
    CONSTRAINT cart_item_pk PRIMARY KEY (id),
    CONSTRAINT cart_item_nutrient
        FOREIGN KEY (nutrient_id) REFERENCES nutrient (id),
    CONSTRAINT cart_item_cart
        FOREIGN KEY (cart_id) REFERENCES cart (id)
);

-- -------------------------------------------------------------
-- 14. billing
-- -------------------------------------------------------------
CREATE TABLE billing
(
    id         SERIAL       NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name  VARCHAR(255) NOT NULL,
    address    VARCHAR(255) NOT NULL,
    courier_id INT,
    CONSTRAINT billing_pk PRIMARY KEY (id),
    CONSTRAINT billing_courier
        FOREIGN KEY (courier_id) REFERENCES courier (id)
);

-- -------------------------------------------------------------
-- 15. order
-- -------------------------------------------------------------
CREATE TABLE "order"
(
    id                 SERIAL        NOT NULL,
    billing_id         INT           NOT NULL,
    total_sum          NUMERIC(8, 2) NOT NULL,
    status             CHAR(1)       NOT NULL,
    collect_from_store BOOLEAN       NOT NULL,
    CONSTRAINT order_pk PRIMARY KEY (id),
    CONSTRAINT order_billing
        FOREIGN KEY (billing_id) REFERENCES billing (id)
);

-- -------------------------------------------------------------
-- 16. order_item
-- -------------------------------------------------------------
CREATE TABLE order_item
(
    id          SERIAL        NOT NULL,
    order_id    INT           NOT NULL,
    nutrient_id INT           NOT NULL,
    price       NUMERIC(8, 2) NOT NULL,
    quantity    INT           NOT NULL,
    total_sum   NUMERIC(8, 2) NOT NULL,
    CONSTRAINT order_item_pk PRIMARY KEY (id),
    CONSTRAINT order_item_order
        FOREIGN KEY (order_id) REFERENCES "order" (id),
    CONSTRAINT order_item_nutrient
        FOREIGN KEY (nutrient_id) REFERENCES nutrient (id)
);

-- -------------------------------------------------------------
-- 17. feedback
-- -------------------------------------------------------------
CREATE TABLE feedback
(
    id         SERIAL       NOT NULL,
    name       VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL,
    message    TEXT         NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT feedback_pk PRIMARY KEY (id)
);

-- -------------------------------------------------------------
-- 18. blog
-- -------------------------------------------------------------
CREATE TABLE blog_article
(
    id         SERIAL       NOT NULL,
    title      VARCHAR(255) NOT NULL,
    summary    VARCHAR(500),
    content    VARCHAR(5000),
    image_url  VARCHAR(1000),
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
)