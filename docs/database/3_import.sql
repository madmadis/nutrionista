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

INSERT INTO nutrient_image (nutrient_id, image_url)
VALUES
    (1, 'https://placehold.co/400x300'),
    (2, 'https://placehold.co/400x300'),
    (3, 'https://placehold.co/400x300');

INSERT INTO blog_article (title, summary, content, image_url)
VALUES
    ('C-vitamiin ja immuunsüsteem', 'C-vitamiin on üks olulisemaid antioksüdante, mis toetab keha kaitsevõimet.', 'C-vitamiin ehk askorbiinhape on vees lahustuv vitamiin, mis mängib olulist rolli
  immuunsüsteemi toetamisel...', 'https://placehold.co/400x300'),
    ('Magneesium ja uni', 'Magneesium aitab lihaspinget leevendada ja toetab kvaliteetset und.', 'Magneesium on mineraal, mis osaleb üle 300 ensümaatilise reaktsiooni käigus kehas...',
     'https://placehold.co/400x300'),
    ('D-vitamiin talvel', 'Talvekuudel on D-vitamiini tase sageli madal — mida see tähendab tervisele?', 'D-vitamiin sünteesitakse nahas päikesevalguse toimel, mistõttu talvekuudel võib selle tase
  langeda...', 'https://placehold.co/400x300');