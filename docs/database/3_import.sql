SET search_path TO nutrionista;

INSERT INTO role (id, name)
VALUES
    (1, 'ADMIN'),
    (2, 'USER');

INSERT INTO color_code (id, name, color_code)
VALUES
    (1, 'GREEN',  '#00C853'),
    (2, 'RED',    '#D50000'),
    (3, 'YELLOW', '#FFD600');

INSERT INTO "user" (id, email, password, role_id)
VALUES
    (1, 'admin@nutrionista.ee',   'admin123', 1),
    (2, 'jaan.tamm@mail.ee',      'jaan123', 2),
    (3, 'mari.mets@gmail.com',    'mari123', 2);

INSERT INTO contact (id, user_id, first_name, last_name)
VALUES
    (1, 1, 'Admin',  'Nutrionista'),
    (2, 2, 'Jaan',   'Tamm'),
    (3, 3, 'Mari',   'Mets');

INSERT INTO cart (id, user_id)
VALUES
    (1, 1),
    (2, 2),
    (3, 3);

INSERT INTO category (id, name, description)
VALUES
    (1, 'Rasvlahustuv', 'Lahustub rasvades'),
    (2, 'Vesilahustuv', 'Lahustub vees');

INSERT INTO nutrient
(id, name, description, category_id, price, stock_quantity, created_at, updated_at)
VALUES

    (
        1,
        'Vitamiin A',
        'Oluline nägemisele, immuunsusele ja naha tervisele.',
        1,
        9.99,
        8,
        NOW(),
        NOW()
    ),

    (
        2,
        'Vitamiin B12',
        'Toetab närvisüsteemi ja aitab vähendada väsimust.',
        2,
        14.50,
        6,
        NOW(),
        NOW()
    ),

    (
        3,
        'Vitamiin C',
        'Tuntud antioksüdant, mis toetab immuunsüsteemi.',
        2,
        7.90,
        10,
        NOW(),
        NOW()
    ),

    (
        4,
        'Vitamiin D3',
        'Toetab luid, immuunsust ja kaltsiumi omastamist.',
        1,
        12.99,
        7,
        NOW(),
        NOW()
    ),

    (
        5,
        'Vitamiin E',
        'Aitab kaitsta rakke oksüdatiivse stressi eest.',
        1,
        11.20,
        5,
        NOW(),
        NOW()
    ),

    (
        6,
        'Vitamiin K2',
        'Toetab vere hüübimist ja luude tervist.',
        1,
        13.75,
        4,
        NOW(),
        NOW()
    ),

    (
        7,
        'Vitamiin B6',
        'Toetab ainevahetust ja närvisüsteemi.',
        2,
        8.60,
        9,
        NOW(),
        NOW()
    ),

    (
        8,
        'Magneesium',
        'Toetab lihaste ja närvisüsteemi normaalset tööd.',
        2,
        10.40,
        7,
        NOW(),
        NOW()
    ),

    (
        9,
        'Tsink',
        'Toetab immuunsüsteemi ning naha tervist.',
        2,
        9.45,
        6,
        NOW(),
        NOW()
    ),

    (
        10,
        'Raud',
        'Oluline vereloome ja hapniku transpordi jaoks.',
        2,
        8.95,
        3,
        NOW(),
        NOW()
    );

INSERT INTO property (id, type, name, description)
VALUES
    (1, 'FUN', 'Immuunsus', 'Toetab immuunsüsteemi'),
    (2, 'FUN', 'Energia', 'Aitab vähendada väsimust'),
    (3, 'FUN', 'Luud', 'Toetab luude ja hammaste tervist'),
    (4, 'FUN', 'Nahk', 'Toetab naha tervist'),
    (5, 'FUN', 'Närvisüsteem', 'Toetab närvisüsteemi normaalset talitlust'),
    (6, 'FUN', 'Lihased', 'Toetab lihaste normaalset tööd'),
    (7, 'FUN', 'Vereloome', 'Toetab punaste vereliblede tootmist'),
    (8, 'FUN', 'Nägemine', 'Toetab normaalset nägemist');

INSERT INTO nutrient_property (nutrient_id, property_id)
VALUES

-- Vitamiin A
(1, 1),
(1, 4),
(1, 8),

-- Vitamiin B12
(2, 2),
(2, 5),
(2, 7),

-- Vitamiin C
(3, 1),
(3, 4),

-- Vitamiin D3
(4, 1),
(4, 3),
(4, 6),

-- Vitamiin E
(5, 4),

-- Vitamiin K2
(6, 3),

-- Vitamiin B6
(7, 2),
(7, 5),

-- Magneesium
(8, 5),
(8, 6),

-- Tsink
(9, 1),
(9, 4),

-- Raud
(10, 2),
(10, 7);

INSERT INTO nutrient_interaction
(id, nutrient_id, related_nutrient_id, interaction_type_id, description)
VALUES

    (
        1,
        4,
        8,
        1,
        'Vitamiin D aitab magneesiumi paremini omastada.'
    ),

    (
        2,
        3,
        10,
        1,
        'Vitamiin C parandab raua omastamist.'
    ),

    (
        3,
        6,
        4,
        1,
        'Vitamiin K2 töötab koos D-vitamiiniga luude toetamisel.'
    );

INSERT INTO courier
(id, name, type, api_key, endpoint_url)
VALUES

    (
        1,
        'Omniva',
        'O',
        'omniva_test_key',
        'https://api.omniva.ee/test'
    ),

    (
        2,
        'DPD',
        'D',
        'dpd_test_key',
        'https://api.dpd.ee/test'
    ),

    (
        3,
        'Smartpost',
        'S',
        'smartpost_test_key',
        'https://api.smartpost.ee/test'
    );

INSERT INTO billing
(id, first_name, last_name, address, courier_id)
VALUES

    (
        1,
        'Tarmo',
        'Tamm',
        'Tartu mnt 12, Tallinn',
        1
    ),

    (
        2,
        'Mari',
        'Majakas',
        'Pärnu mnt 88, Tallinn',
        2
    ),

    (
        3,
        'Karl',
        'Lepp',
        'Narva mnt 5, Tartu',
        3
    );

INSERT INTO cart_item
(id, nutrient_id, cart_id, quantity)
VALUES

    (1, 4, 1, 2),   -- Vitamiin D3
    (2, 3, 1, 1),   -- Vitamiin C

    (3, 8, 2, 1),   -- Magneesium
    (4, 9, 2, 2),   -- Tsink

    (5, 2, 3, 1),   -- Vitamiin B12
    (6, 10, 3, 1);  -- Raud

INSERT INTO "order"
(id, billing_id, total_sum, status, collect_from_store)
VALUES

    (
        1,
        1,
        33.88,
        'P',
        false
    ),

    (
        2,
        2,
        29.30,
        'C',
        true
    ),

    (
        3,
        3,
        23.45,
        'D',
        false
    );

INSERT INTO order_item
(id, order_id, nutrient_id, price, quantity, total_sum)
VALUES

-- ORDER 1
(1, 1, 4, 12.99, 2, 25.98),
(2, 1, 3, 7.90, 1, 7.90),

-- ORDER 2
(3, 2, 8, 10.40, 1, 10.40),
(4, 2, 9, 9.45, 2, 18.90),

-- ORDER 3
(5, 3, 2, 14.50, 1, 14.50),
(6, 3, 10, 8.95, 1, 8.95);

INSERT INTO feedback (id, name, email, message)
VALUES
    (1, 'Mari Mets',    'mari.mets@gmail.com',    'Väga hea valik tooteid! Vitamiin D3 jõudis kätte kiiresti.'),
    (2, 'Jaan Tamm',    'jaan.tamm@hot.ee',       'Magneesium aitas une kvaliteeti parandada. Soovitan!'),
    (3, 'Kati Kask',    'kati.kask@mail.ee',      'Kas plaanite lisada ka oomega-3 tooteid? Oleks väga vajalik.');

INSERT INTO nutrient_image (nutrient_id, image_data)
VALUES
    (1, 'data:image/jpeg;base64,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'),
    (2, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqa8hGUvFAfMf-O52HqmkH8ZTR1KpoOH1yPg&s'),
    (3, 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZLhunJraK0ZqhoIHYl6qRO-dR3qWKDgHoLw&s');