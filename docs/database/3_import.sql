SET search_path TO nutrionista;

-- ─── Roles ────────────────────────────────────────────────────────────────
INSERT INTO role (name) VALUES ('ADMIN'), ('USER');

-- ─── Users ────────────────────────────────────────────────────────────────
-- All accounts share the password "demo" (bcrypt hash generated locally).
INSERT INTO "user" (username, password_hash, role_id) VALUES
                                                          ('madis', '$2a$10$sXdmvQgMOqD7MtUCuFMuDu9wYh0ogFd/oqIoxFyojcDYgT5ztTkBC', (SELECT id FROM role WHERE name='ADMIN')),
                                                          ('kaili', '$2a$10$sXdmvQgMOqD7MtUCuFMuDu9wYh0ogFd/oqIoxFyojcDYgT5ztTkBC', (SELECT id FROM role WHERE name='ADMIN')),
                                                          ('rain',  '$2a$10$sXdmvQgMOqD7MtUCuFMuDu9wYh0ogFd/oqIoxFyojcDYgT5ztTkBC', (SELECT id FROM role WHERE name='ADMIN')),
                                                          ('tarmo', '$2a$10$sXdmvQgMOqD7MtUCuFMuDu9wYh0ogFd/oqIoxFyojcDYgT5ztTkBC', (SELECT id FROM role WHERE name='USER'));

-- ─── Lookups: color codes (interaction-quality palette) ───────────────────
INSERT INTO color_code (name, color_code) VALUES
                                              ('GOOD',    '#22c55e'),
                                              ('NEUTRAL', '#eab308'),
                                              ('BAD',     '#ef4444');

-- ─── Lookups: couriers ────────────────────────────────────────────────────
INSERT INTO courier (name, type) VALUES
                                     ('Omniva pakiautomaat', 'P'),
                                     ('Smartpost',           'P'),
                                     ('Itella kullerteenus', 'H');

-- ─── Catalog: categories ──────────────────────────────────────────────────
INSERT INTO category (name, description) VALUES
                                             ('Vitamiinid',    'Rasvlahustuvad ja vees lahustuvad vitamiinid'),
                                             ('Mineraalid',    'Olulised mineraalid ja mikroelemendid'),
                                             ('Toidulisandid', 'Sportlikud ja üldised toidulisandid');

-- ─── Catalog: nutrients ───────────────────────────────────────────────────
-- created_at is set explicitly (ascending) so the "newest 4" home query is deterministic.
INSERT INTO nutrient (name, description, category_id, price, stock_quantity, created_at) VALUES
                                                                                             ('Vitamiin A',  'Oluline nägemisele ja immuunsüsteemile.',
                                                                                              (SELECT id FROM category WHERE name='Vitamiinid'),    18.75, 25, '2026-05-10 09:00:00'),
                                                                                             ('Vitamiin C',  'Tugevdab immuunsüsteemi.',
                                                                                              (SELECT id FROM category WHERE name='Vitamiinid'),    15.00, 40, '2026-05-11 09:00:00'),
                                                                                             ('Vitamiin D',  'Hea luudele ja meeleolule.',
                                                                                              (SELECT id FROM category WHERE name='Vitamiinid'),    12.99, 30, '2026-05-12 09:00:00'),
                                                                                             ('B-kompleks',  'Energiaks ja närvisüsteemile.',
                                                                                              (SELECT id FROM category WHERE name='Vitamiinid'),     9.50, 18, '2026-05-13 09:00:00'),
                                                                                             ('Magneesium',  'Lihaste ja närvide tööks.',
                                                                                              (SELECT id FROM category WHERE name='Mineraalid'),     7.25, 22, '2026-05-08 09:00:00'),
                                                                                             ('Tsink',       'Immuunsüsteemi tugi.',
                                                                                              (SELECT id FROM category WHERE name='Mineraalid'),     8.90, 15, '2026-05-09 09:00:00'),
                                                                                             ('Omega-3',     'Südame ja aju heaks.',
                                                                                              (SELECT id FROM category WHERE name='Toidulisandid'), 24.99, 12, '2026-05-07 09:00:00'),
                                                                                             ('Kollageen',   'Naha ja liigeste tervis.',
                                                                                              (SELECT id FROM category WHERE name='Toidulisandid'), 29.99,  8, '2026-05-06 09:00:00');