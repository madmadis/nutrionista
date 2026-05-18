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