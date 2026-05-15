-- Created by Redgate Data Modeler (https://datamodeler.redgate-platform.com)
-- Last modification date: 2026-05-15 12:38:04.223

-- tables
-- Table: category
CREATE TABLE category (
                          id serial  NOT NULL,
                          name varchar(100)  NOT NULL,
                          description text  NULL,
                          CONSTRAINT category_name_uq UNIQUE (name) NOT DEFERRABLE  INITIALLY IMMEDIATE,
                          CONSTRAINT category_pk PRIMARY KEY (id)
);

-- Table: color_code
CREATE TABLE color_code (
                            id serial  NOT NULL,
                            name varchar(10)  NOT NULL,
                            color_code varchar(10)  NOT NULL,
                            CONSTRAINT color_code_name_uq UNIQUE (name) NOT DEFERRABLE  INITIALLY IMMEDIATE,
                            CONSTRAINT color_code_pk PRIMARY KEY (id)
);

-- Table: nutrient_image
-- The link to the owning nutrient is held by nutrient.image_id; no back-pointer here.
CREATE TABLE nutrient_image (
                                id serial  NOT NULL,
                                image_data bytea  NOT NULL,
                                CONSTRAINT nutrient_image_pk PRIMARY KEY (id)
);

-- Table: nutrient_interaction
CREATE TABLE nutrient_interaction (
                                      id serial  NOT NULL,
                                      nutrient_id int  NOT NULL,
                                      related_nutrient_id int  NOT NULL,
                                      interaction_type_id int  NOT NULL,
                                      description varchar(200)  NULL,
                                      CONSTRAINT nutrient_interaction_self_ck CHECK (( nutrient_id <> related_nutrient_id )) NOT DEFERRABLE INITIALLY IMMEDIATE,
                                      CONSTRAINT nutrient_interaction_pk PRIMARY KEY (id)
);

-- Table: nutrient_property
CREATE TABLE nutrient_property (
                                   id serial  NOT NULL,
                                   nutrient_id int  NOT NULL,
                                   property_id int  NOT NULL,
                                   effect_type varchar(10)  NULL,
                                   CONSTRAINT nutrient_property_effect_ck CHECK (( effect_type IN ( 'ENHANCE' , 'INHIBIT' ) )) NOT DEFERRABLE INITIALLY IMMEDIATE,
                                   CONSTRAINT nutrient_property_pk PRIMARY KEY (id)
);

-- Table: nutrient
CREATE TABLE nutrient (
                          id serial  NOT NULL,
                          name varchar(100)  NOT NULL,
                          description varchar(500)  NULL,
                          category_id int  NOT NULL,
                          price numeric(8,2)  NOT NULL DEFAULT 0,
                          in_stock boolean  NOT NULL DEFAULT true,
                          created_at timestamp  NOT NULL DEFAULT current_timestamp,
                          updated_at timestamp  NOT NULL DEFAULT current_timestamp,
                          image_id int  NULL,
                          CONSTRAINT nutrient_name_uq UNIQUE (name) NOT DEFERRABLE  INITIALLY IMMEDIATE,
                          CONSTRAINT nutrient_price_ck CHECK (( price >= 0 )) NOT DEFERRABLE INITIALLY IMMEDIATE,
                          CONSTRAINT nutrient_pk PRIMARY KEY (id)
);

-- Table: property
CREATE TABLE property (
                          id serial  NOT NULL,
                          type varchar(3)  NOT NULL,
                          name varchar(150)  NOT NULL,
                          description varchar(150)  NULL,
                          CONSTRAINT property_pk PRIMARY KEY (id)
);

-- Table: role
CREATE TABLE role (
                      id serial  NOT NULL,
                      name varchar(10)  NOT NULL,
                      CONSTRAINT role_name_uq UNIQUE (name) NOT DEFERRABLE  INITIALLY IMMEDIATE,
                      CONSTRAINT role_pk PRIMARY KEY (id)
);

-- Table: "user"  ("user" on PostgreSQL-is reserveeritud sõna)
CREATE TABLE "user" (
                        id serial  NOT NULL,
                        username varchar(50)  NOT NULL,
                        password_hash varchar(60)  NOT NULL,
                        created_at timestamp  NOT NULL DEFAULT current_timestamp,
                        role_id int  NOT NULL,
                        CONSTRAINT user_username_uq UNIQUE (username) NOT DEFERRABLE  INITIALLY IMMEDIATE,
                        CONSTRAINT user_pk PRIMARY KEY (id)
);

-- foreign keys
-- Reference: nutrient_category (table: nutrient)
ALTER TABLE nutrient ADD CONSTRAINT nutrient_category_fk
    FOREIGN KEY (category_id)
        REFERENCES category (id)
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_image (table: nutrient)
ALTER TABLE nutrient ADD CONSTRAINT nutrient_image_fk
    FOREIGN KEY (image_id)
        REFERENCES nutrient_image (id)
        ON DELETE SET NULL
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_interaction_nutrient (table: nutrient_interaction)
ALTER TABLE nutrient_interaction ADD CONSTRAINT nutrient_interaction_nutrient_fk
    FOREIGN KEY (nutrient_id)
        REFERENCES nutrient (id)
        ON DELETE CASCADE
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_interaction_related_nutrient (table: nutrient_interaction)
ALTER TABLE nutrient_interaction ADD CONSTRAINT nutrient_interaction_related_nutrient_fk
    FOREIGN KEY (related_nutrient_id)
        REFERENCES nutrient (id)
        ON DELETE CASCADE
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_interaction_color_code (table: nutrient_interaction)
ALTER TABLE nutrient_interaction ADD CONSTRAINT nutrient_interaction_color_code_fk
    FOREIGN KEY (interaction_type_id)
        REFERENCES color_code (id)
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_property_nutrient (table: nutrient_property)
ALTER TABLE nutrient_property ADD CONSTRAINT nutrient_property_nutrient_fk
    FOREIGN KEY (nutrient_id)
        REFERENCES nutrient (id)
        ON DELETE CASCADE
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: nutrient_property_property (table: nutrient_property)
ALTER TABLE nutrient_property ADD CONSTRAINT nutrient_property_property_fk
    FOREIGN KEY (property_id)
        REFERENCES property (id)
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- Reference: user_role (table: "user")
ALTER TABLE "user" ADD CONSTRAINT user_role_fk
    FOREIGN KEY (role_id)
        REFERENCES role (id)
        NOT DEFERRABLE
            INITIALLY IMMEDIATE
;

-- End of file.
