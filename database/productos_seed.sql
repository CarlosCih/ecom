-- ============================================================
-- SEED: Productos para E-commerce (~202 productos)
-- Compatible con: SQL Server (T-SQL)
-- Tablas: inventario_product, inventario_product_category
-- Ejecutar DESPUES de categorias_seed.sql
-- ============================================================
USE ecomdb;
BEGIN TRAN;

-- =================================================================
-- PARTE 1: INSERTAR PRODUCTOS
-- Usa NOT EXISTS por slug para evitar duplicados
-- =================================================================

-- ======================== TECLADOS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Teclado Mecánico Red Switch',  N'Teclado mecánico con switches Red lineales, ideal para gaming intenso', 299.99, 50, N'teclado-mecanico-red'),
    (N'Teclado Mecánico Blue Switch', N'Teclado mecánico con switches Blue táctiles y audibles',                319.99, 45, N'teclado-mecanico-blue'),
    (N'Teclado Mecánico Brown Switch',N'Switches Brown táctiles silenciosos, versátil para trabajo y gaming',  329.99, 40, N'teclado-mecanico-brown'),
    (N'Teclado Membrana USB',         N'Teclado de membrana silencioso, compatible con Windows y Mac',          89.99, 100, N'teclado-membrana-usb'),
    (N'Teclado Inalámbrico Bluetooth',N'Conexión Bluetooth 5.0, batería 3 meses de duración',                 199.99, 60, N'teclado-inalambrico-bluetooth'),
    (N'Teclado Gaming RGB Completo',  N'Retroiluminación RGB por tecla, anti-ghosting 100%',                  449.99, 35, N'teclado-gaming-rgb'),
    (N'Teclado Compacto TKL',         N'Tamaño 80%, sin teclado numérico, ideal para escritorios pequeños',   259.99, 55, N'teclado-compacto-tkl'),
    (N'Teclado Ergonómico Dividido',  N'Diseño ergonómico que reduce la tensión en muñecas',                  349.99, 25, N'teclado-ergonomico-dividido')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== MOUSE ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Mouse Gaming 6400 DPI',         N'Sensor óptico 6400 DPI, 6 botones programables, RGB',        199.99, 70, N'mouse-gaming-6400dpi'),
    (N'Mouse Inalámbrico Ergonómico',  N'Receptor USB 2.4GHz, batería recargable, 3 niveles DPI',     299.99, 65, N'mouse-inalambrico-ergonomico'),
    (N'Mouse Básico USB',              N'Mouse óptico básico plug and play, 1000 DPI',                  49.99, 200, N'mouse-basico-usb'),
    (N'Mouse Vertical Ergonómico',     N'Diseño vertical reduce el síndrome del túnel carpiano',       249.99, 40, N'mouse-vertical-ergonomico'),
    (N'Mouse Gaming RGB 16000 DPI',    N'16000 DPI ajustable, polling rate 1000Hz, 8 botones',        279.99, 50, N'mouse-gaming-rgb-16000dpi'),
    (N'Mouse Bluetooth Portátil',      N'Ultra delgado, Bluetooth 5.0, compatible multi-SO',          159.99, 80, N'mouse-bluetooth-portatil'),
    (N'Mouse Trackball Inalámbrico',   N'Control de cursor preciso con trackball, sin mover el mouse', 329.99, 20, N'mouse-trackball-inalambrico')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== MONITORES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Monitor 24" Full HD IPS',      N'Panel IPS 1080p, tiempo de respuesta 5ms, 75Hz',              899.99, 40, N'monitor-24-full-hd-ips'),
    (N'Monitor 27" QHD 144Hz',        N'2560x1440 QHD, 144Hz para gaming, panel IPS',               1499.99, 30, N'monitor-27-qhd-144hz'),
    (N'Monitor 32" 4K UHD',           N'3840x2160 4K, panel VA, HDR400, para diseño profesional',   2499.99, 15, N'monitor-32-4k-uhd'),
    (N'Monitor Curvo 27" 165Hz',      N'Panel curvo 1500R, 165Hz, 1ms GTG, FreeSync Premium',       1699.99, 25, N'monitor-curvo-27-165hz'),
    (N'Monitor Gaming 240Hz',         N'1080p 240Hz competitivo, 0.5ms, G-Sync Compatible',         1799.99, 20, N'monitor-gaming-240hz'),
    (N'Monitor Portátil USB-C 15"',   N'15.6" 1080p, alimentado por USB-C, peso 800g',               899.99, 35, N'monitor-portatil-usbc-15')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== IMPRESORAS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Impresora Láser Monocromo',    N'30 páginas/min, conectividad WiFi, bandeja 250 hojas',        799.99, 20, N'impresora-laser-monocromo'),
    (N'Impresora Tinta Color',        N'Impresión en color de alta calidad, WiFi, USB',               549.99, 30, N'impresora-tinta-color'),
    (N'Multifuncional Imprime-Escanea-Copia', N'3 en 1, WiFi, doble cara automático, LCD',           999.99, 25, N'multifuncional-imprime-escanea'),
    (N'Impresora Fotográfica 6x4',    N'Impresión fotográfica sin PC, papel brillante incluido',     1299.99, 15, N'impresora-fotografica-6x4')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== LAPTOPS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Laptop Core i5 8GB 256GB SSD',    N'Intel Core i5-12450H, 8GB RAM, 256GB SSD, pantalla 15.6" FHD', 5999.99, 20, N'laptop-i5-8gb-256ssd'),
    (N'Laptop Core i7 16GB 512GB SSD',   N'Intel Core i7-12700H, 16GB DDR5, 512GB NVMe, 15.6" FHD IPS',   9999.99, 15, N'laptop-i7-16gb-512ssd'),
    (N'Laptop Gamer RTX 3060 16GB',      N'Ryzen 7 6800H, RTX 3060, 16GB RAM, 1TB SSD, 144Hz',           14999.99, 10, N'laptop-gamer-rtx3060-16gb'),
    (N'Laptop Ultrabook 14" Core i5',    N'Ultradelgada 14" FHD, Core i5-1235U, 16GB, 512GB, 8h batería', 11999.99, 12, N'laptop-ultrabook-14-i5'),
    (N'Laptop MacBook Air M2 8GB 256GB', N'Chip Apple M2, 8GB RAM unificada, 256GB SSD, pantalla Liquid Retina', 19999.99, 8, N'laptop-macbook-air-m2'),
    (N'Laptop Económica Celeron 4GB',    N'Intel Celeron N4020, 4GB RAM, 128GB eMMC, 14" HD, liviana',     3499.99, 30, N'laptop-economica-celeron-4gb'),
    (N'Laptop 2 en 1 Táctil i5',        N'360° táctil, Core i5, 8GB RAM, 256GB SSD, stylus incluido',     8999.99, 12, N'laptop-2en1-tactil-i5'),
    (N'Laptop Chromebook 11"',           N'Chrome OS, 4GB RAM, 64GB eMMC, 11" HD, batería 12h',            2999.99, 25, N'laptop-chromebook-11')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== PC DE ESCRITORIO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'PC Escritorio Core i5 16GB',    N'Intel Core i5-12400, 16GB DDR4, 500GB SSD, sin monitor',     6999.99, 15, N'pc-escritorio-i5-16gb'),
    (N'PC Escritorio Core i9 32GB',    N'Intel Core i9-13900, 32GB DDR5, 1TB NVMe, GPU integrada',   15999.99, 8,  N'pc-escritorio-i9-32gb'),
    (N'PC All-in-One 27" FHD i7',      N'Todo en uno 27" FHD, Core i7, 16GB, 512GB SSD, webcam',    11999.99, 10, N'pc-aio-27-fhd-i7'),
    (N'Mini PC Intel NUC i5',          N'Compacto, Core i5, 8GB RAM, 256GB SSD, HDMI 4K',             4999.99, 20, N'mini-pc-intel-nuc-i5'),
    (N'PC Gamer Ensamblado i7 RTX',    N'Core i7-13700K, RTX 4060, 32GB DDR5, 1TB SSD, RGB',        18999.99, 7,  N'pc-gamer-i7-rtx4060')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== COMPONENTES PC ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Procesador Intel Core i5-13400', N'10 núcleos (6P+4E), hasta 4.6GHz, socket LGA1700, incluye disipador', 2999.99, 25, N'procesador-intel-i5-13400'),
    (N'Procesador Intel Core i9-13900K',N'24 núcleos, hasta 5.8GHz, desbloqueado para overclocking',            8999.99, 10, N'procesador-intel-i9-13900k'),
    (N'Procesador AMD Ryzen 5 7600X',   N'6 núcleos 12 hilos, hasta 5.3GHz, socket AM5',                        3499.99, 20, N'procesador-amd-ryzen5-7600x'),
    (N'Memoria RAM 16GB DDR5 5200MHz',  N'Kit 2x8GB DDR5-5200, CL38, compatible Intel/AMD',                      899.99, 40, N'memoria-ram-16gb-ddr5'),
    (N'Memoria RAM 32GB DDR4 3200MHz',  N'Kit 2x16GB DDR4-3200, CL16, XMP 2.0',                                 1199.99, 35, N'memoria-ram-32gb-ddr4'),
    (N'SSD 1TB NVMe PCIe 4.0',          N'Velocidad lectura 7000MB/s, escritura 6500MB/s, M.2 2280',              999.99, 50, N'ssd-1tb-nvme-pcie4'),
    (N'GPU Nvidia RTX 4070 12GB',        N'12GB GDDR6X, DLSS 3, ray tracing, HDMI 2.1',                         12999.99, 8,  N'gpu-nvidia-rtx4070-12gb'),
    (N'Fuente Poder 750W 80+ Gold',      N'Modular, certificado 80 Plus Gold, 135mm ventilador silencioso',        799.99, 30, N'fuente-poder-750w-gold')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== AUDIO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Audífonos Over-Ear Noise Cancelling', N'ANC activo, 30h batería, plegables, estuche incluido',   1299.99, 30, N'audifonos-over-ear-anc'),
    (N'Bocina Bluetooth 360° 20W',           N'Sonido 360°, resistente al agua IPX7, 12h batería',        499.99, 55, N'bocina-bluetooth-360-20w'),
    (N'Soundbar 2.1 con Subwoofer 120W',     N'HDMI ARC, Bluetooth 5.0, bass boost, control remoto',    1499.99, 20, N'soundbar-21-subwoofer-120w'),
    (N'Audífonos In-Ear Sport Inalámbricos', N'Resistente al sudor IPX5, TWS, autonomía 6h + case 18h',  299.99, 80, N'audifonos-inear-sport-tws'),
    (N'Barra de Sonido Surround 5.1',        N'Surround virtual 5.1, Dolby Atmos, HDMI ARC, 200W RMS',  2199.99, 12, N'barra-sonido-surround-51')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CAMARAS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Cámara DSLR 24MP Kit 18-55mm',    N'Sensor APS-C 24MP, video Full HD, WiFi, visor óptico',     7999.99, 10, N'camara-dslr-24mp-kit'),
    (N'Cámara Mirrorless Sony 33MP',      N'Full Frame 33MP, AF con IA, video 4K60fps, estabilización',12999.99, 7,  N'camara-mirrorless-sony-33mp'),
    (N'Cámara de Acción 4K60fps',         N'4K60fps, resistente al agua 10m, pantalla táctil, HyperSmooth', 3999.99, 20, N'camara-accion-4k60fps'),
    (N'Cámara Instantánea con Película',  N'Imprime en 10s, película incluida x10, flash automático',   1299.99, 40, N'camara-instantanea-pelicula'),
    (N'Cámara Web 4K USB-C Streaming',    N'4K 30fps, micrófono dual integrado, campo visual 90°',       899.99, 35, N'camara-web-4k-usbc')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== WEARABLES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Smartwatch Samsung Galaxy Watch 6',  N'1.5" AMOLED, monitoreo salud 24/7, NFC, GPS, 40h batería',  1999.99, 25, N'smartwatch-samsung-galaxy-w6'),
    (N'Apple Watch Series 9 41mm',          N'Chip S9, pantalla siempre activa, ECG, detección caídas',   5999.99, 12, N'apple-watch-series9-41mm'),
    (N'Banda Fitness Xiaomi Band 8',        N'AMOLED 1.62", SpO2, frecuencia cardiaca, 16 días batería',   499.99, 70, N'banda-fitness-xiaomi-band8'),
    (N'Smartwatch Garmin GPS Running',      N'GPS multicanal, mapas precargados, batería 14 días, ANT+',  3499.99, 15, N'smartwatch-garmin-gps-running')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== TV Y VIDEO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Televisor 55" 4K Smart TV UHD',  N'4K Ultra HD, Smart TV Android, HDR10+, Dolby Vision, 60Hz',    7999.99, 15, N'televisor-55-4k-smart-uhd'),
    (N'Televisor 65" OLED 4K',          N'Panel OLED, negros perfectos, 120Hz, HDMI 2.1, webOS',         19999.99, 5,  N'televisor-65-oled-4k'),
    (N'Proyector Full HD 3000 Lúmenes', N'1080p nativo, 3000 lumens, HDMI x2, USB, altavoz integrado',    4999.99, 12, N'proyector-full-hd-3000lm'),
    (N'Televisor 43" Full HD Smart',    N'1080p, Smart TV, WiFi, HDMI x3, USB x2, control de voz',        3999.99, 20, N'televisor-43-fhd-smart'),
    (N'Televisor 75" QLED 4K 120Hz',    N'QLED 4K, 120Hz, Quantum HDR, compatible con Alexa/Google',     24999.99, 5,  N'televisor-75-qled-4k-120hz')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== SMARTPHONES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Samsung Galaxy S24 256GB',        N'Snapdragon 8 Gen 3, cámara 50MP, 6.1" Dynamic AMOLED 2X',    13999.99, 20, N'samsung-galaxy-s24-256gb'),
    (N'iPhone 15 Pro Max 256GB',         N'Chip A17 Pro, titanio, cámara 48MP ProRAW, USB-C 3.0',        24999.99, 10, N'iphone-15-pro-max-256gb'),
    (N'Xiaomi Redmi Note 13 128GB',      N'Snapdragon 685, cámara 108MP, 6.67" AMOLED, 5000mAh',         3499.99, 40, N'xiaomi-redmi-note13-128gb'),
    (N'Motorola Edge 40 256GB',          N'Dimensity 8020, OLED 144Hz, 68W carga rápida, IP68',           6999.99, 25, N'motorola-edge40-256gb'),
    (N'Google Pixel 8 128GB',            N'Chip Tensor G3, cámara computacional, 7 años actualizaciones', 14999.99, 12, N'google-pixel8-128gb'),
    (N'Samsung Galaxy A55 256GB',        N'Exynos 1480, AMOLED 120Hz, triple cámara 50MP, IP67',          6499.99, 30, N'samsung-galaxy-a55-256gb'),
    (N'iPhone 14 128GB',                 N'Chip A15 Bionic, 6.1" Super Retina XDR, modo cinematic',       17999.99, 15, N'iphone-14-128gb'),
    (N'Xiaomi POCO X6 Pro 256GB',        N'Dimensity 8300-Ultra, 64MP, carga 67W, pantalla 120Hz',         4999.99, 35, N'xiaomi-poco-x6-pro-256gb')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== FUNDAS Y PROTECTORES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Funda iPhone 15 Silicona Líquida',  N'Silicona líquida suave, antihuella, compatible MagSafe',    149.99, 80, N'funda-iphone15-silicona-liquida'),
    (N'Funda Samsung S24 TPU Transparente',N'TPU flexible anti-amarillamiento, bordes elevados, slim',   129.99, 90, N'funda-samsung-s24-tpu-trans'),
    (N'Vidrio Templado 9H Universal 6.7"', N'Dureza 9H, transmisión luz 99.9%, pack x2',                  99.99, 150, N'vidrio-templado-9h-universal'),
    (N'Funda Cartera con Tarjetero',       N'Cuero PU, 3 ranuras tarjetas, cierre magnético',             199.99, 60, N'funda-cartera-tarjetero'),
    (N'Funda Antigolpes Military Grade',   N'Protección caída 4 metros, bordes de absorción de impacto',  179.99, 70, N'funda-antigolpes-military')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CARGADORES Y CABLES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Cargador Rápido 65W GaN USB-C',   N'GaN 65W, carga iPhone/Android/laptop, compacto',             249.99, 60, N'cargador-rapido-65w-gan-usbc'),
    (N'Cargador Inalámbrico Qi 15W',     N'Qi 15W MagSafe compatible, indicador LED, anti-calor',        299.99, 50, N'cargador-inalambrico-qi-15w'),
    (N'Cable USB-C a USB-C 2m Nylon',    N'100W carga rápida, trenzado nylon, resistente a 20,000 dobleces', 149.99, 100, N'cable-usbc-usbc-2m-nylon'),
    (N'Power Bank 20000mAh 65W PD',      N'65W PD, carga rápida, LCD capacidad, 3 salidas simultáneas',  599.99, 40, N'powerbank-20000mah-65w-pd'),
    (N'Cargador Auto 30W USB-C + USB-A', N'Dual puerto, PD 30W + QC 3.0, compacto, LED indicador',       149.99, 80, N'cargador-auto-30w-dual')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== AUDIO MÓVIL ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'AirPods Pro 2da Generación',       N'ANC adaptativo, modo transparencia, chip H2, USB-C, IP54',   3999.99, 15, N'airpods-pro-2da-generacion'),
    (N'Samsung Galaxy Buds 2 Pro',        N'ANC 3 micrófonos, Dolby Atmos, 360 Audio, batería 8h',       1299.99, 25, N'samsung-galaxy-buds2-pro'),
    (N'Audífonos TWS Xiaomi Buds 4',      N'ANC 40dB, Bluetooth 5.3, 8h batería, IP54 resistente',        399.99, 55, N'audifonos-tws-xiaomi-buds4'),
    (N'Audífonos Bluetooth Deportivos',   N'Over-ear deportivos, banda cervical, IP67, 10h autonomía',    299.99, 45, N'audifonos-bluetooth-deportivos')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== MUEBLES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Sofá 3 Puestos Tela Gris',     N'Tela antimanchas, espuma alta densidad, patas madera',     4999.99, 8,  N'sofa-3-puestos-tela-gris'),
    (N'Mesa de Centro Madera MDF',     N'MDF con chapa nogal, 120x60cm, 2 cajones',                1999.99, 12, N'mesa-centro-madera-mdf'),
    (N'Cama Queen Base Madera 160cm',  N'Madera sólida, cabecero acolchado, incluye somier',       5999.99, 6,  N'cama-queen-madera-160cm'),
    (N'Librero 5 Estantes MDF',        N'80x180cm, 5 estantes ajustables, color blanco/negro',     1499.99, 15, N'librero-5-estantes-mdf'),
    (N'Escritorio Esquinero Madera',   N'Forma L, 140x120cm, cajón y estante lateral',             2499.99, 10, N'escritorio-esquinero-madera')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== DECORACION ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Cuadro Abstracto Canvas 80x60cm',N'Impresión en canvas, bastidor madera, listo para colgar',    599.99, 20, N'cuadro-abstracto-canvas-80x60'),
    (N'Lámpara de Pie LED Regulable',   N'LED 12W regulable, 3 temperaturas de color, USB carga',      799.99, 18, N'lampara-pie-led-regulable'),
    (N'Set 4 Cojines Decorativos',      N'Funda algodón 45x45cm, varios colores, lavable',             299.99, 35, N'set-4-cojines-decorativos'),
    (N'Espejo Decorativo Marco Dorado', N'Forma hexagonal, marco metálico dorado, 80cm diámetro',      899.99, 10, N'espejo-decorativo-marco-dorado')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== LIMPIEZA HOGAR ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Aspiradora Vertical sin Cable 22V', N'22V, filtro HEPA, 2 en 1 vertical/portátil, 45min batería', 1299.99, 20, N'aspiradora-vertical-22v'),
    (N'Mopa Microfibra con Cubo Escurridor',N'Cubo con escurridor a pedal, repuesto microfibra incluido',  199.99, 40, N'mopa-microfibra-cubo-escurridor'),
    (N'Robot Aspirador y Fregador Wi-Fi',  N'LiDAR mapping, mapa multi-piso, app, compatible Alexa',     3499.99, 10, N'robot-aspirador-fregador-wifi'),
    (N'Set Limpieza Baño 5 Piezas',        N'Escobilla, porta escobilla, jabonera, vaso, toallero',        149.99, 60, N'set-limpieza-bano-5-piezas')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ORGANIZACION ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Organizador Closet 20 Divisiones', N'Tela no tejida, 20 celdas, cuelga en barra closet',        299.99, 50, N'organizador-closet-20div'),
    (N'Cajas Plástico Transparente x3',   N'Set 3 cajas apilables con tapa, 15L cada una',              199.99, 45, N'cajas-plastico-transparente-x3'),
    (N'Estante Metálico 5 Niveles',       N'Acero lacado, 90x180cm, soporta 80kg/nivel, fácil armado',  899.99, 12, N'estante-metalico-5-niveles')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ELECTRODOMESTICOS COCINA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Freidora de Aire Digital 5.5L',  N'Digital táctil, 5.5L, 1800W, 8 programas preestablecidos',    899.99, 30, N'freidora-aire-digital-55l'),
    (N'Licuadora de Vaso 600W 2L',      N'600W, vaso 2L Tritan irrompible, 3 velocidades + pulso',       499.99, 40, N'licuadora-vaso-600w-2l'),
    (N'Microondas Digital 25L 900W',    N'900W, 25L, 10 niveles potencia, grill, display LED',           799.99, 25, N'microondas-digital-25l-900w'),
    (N'Cafetera Espresso 15 Bar',       N'Bomba 15 bar, vapor para espumar leche, 1450W, depósito 1.8L', 1299.99, 18, N'cafetera-espresso-15bar'),
    (N'Tostadora 4 Ranuras 1500W',      N'4 ranuras anchas, 7 niveles tostado, bandeja desmontable',      349.99, 35, N'tostadora-4-ranuras-1500w')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== UTENSILIOS COCINA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Set Cuchillos Acero Inox 7 Piezas', N'Acero inoxidable 1.4116, mango ergonómico, bloque madera',   599.99, 20, N'set-cuchillos-acero-inox-7pz'),
    (N'Tabla de Corte Bambú Antideslizante',N'Bambú orgánico 38x28cm, antideslizante, antimicrobial',      199.99, 45, N'tabla-corte-bambu-anti'),
    (N'Wok Antiadherente 32cm Inducción',  N'Recubrimiento cerámico antiadherente, apta inducción/gas',    349.99, 30, N'wok-antiadherente-32cm-ind'),
    (N'Rallador Multiusos 6 Caras',        N'Acero inox, 6 superficies rallado, base antideslizante',       99.99, 60, N'rallador-multiusos-6-caras')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== VAJILLA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Vajilla Cerámica 12 Piezas',     N'4 platos hondo, 4 llano, 4 postre, apta lavavajillas',      699.99, 15, N'vajilla-ceramica-12-piezas'),
    (N'Set Vasos Cristal Soplado x6',   N'Cristal soplado artesanal, capacidad 350ml, libre de plomo', 299.99, 25, N'set-vasos-cristal-soplado-x6'),
    (N'Cubiertos Acero Inox 24 Piezas', N'18/10 acero inox, set 6 personas, caja regalo incluida',     399.99, 20, N'cubiertos-acero-inox-24pz'),
    (N'Tazas Café Porcelana Set x4',    N'Porcelana 280ml, aptas microondas y lavavajillas, regalo',    199.99, 35, N'tazas-cafe-porcelana-x4')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ALMACENAMIENTO COCINA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Set Recipientes Herméticos x5',  N'Vidrio borosilicato, tapas hermética, apto freezer/micro',    249.99, 30, N'recipientes-hermeticos-vidrio-x5'),
    (N'Organizador Especiero 16 Frascos',N'16 frascos especiero 150ml, estante metálico giratorio',     179.99, 25, N'organizador-especiero-16fr'),
    (N'Bolsas Vacío Reutilizables x10', N'Cierre zip reforzado, compatible bomba de vacío manual',      199.99, 40, N'bolsas-vacio-reutilizables-x10')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ROPA HOMBRE ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Polo Básico Algodón 100%',     N'Algodón peinado 180g, cuello redondo, tallas S-XXL',         149.99, 100, N'polo-basico-algodon-100'),
    (N'Jeans Slim Fit Azul Oscuro',   N'Denim 98% algodón, corte slim, tiro medio, elástico',         399.99, 60,  N'jeans-slim-fit-azul-oscuro'),
    (N'Camisa Formal Oxford Blanca',  N'Oxford 100% algodón, corte regular, botonadura completa',     299.99, 50,  N'camisa-formal-oxford-blanca'),
    (N'Chaqueta Bomber Poliéster',    N'Interior polar, cierre metálico, bolsillos laterales',         699.99, 30,  N'chaqueta-bomber-poliester'),
    (N'Short Deportivo Dry-Fit',      N'Tela dry-fit transpirable, elástico y cordón, bolsillo',       199.99, 70,  N'short-deportivo-dry-fit')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ROPA MUJER ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Blusa Floral Gasa',             N'Gasa 100% poliéster, cuello V, manga corta, varios colores',   199.99, 80, N'blusa-floral-gasa'),
    (N'Vestido Casual Midi Verano',    N'Tela fluida, sin mangas, cintura elástica, estampado floral',   349.99, 50, N'vestido-casual-midi-verano'),
    (N'Leggins Deportivos Tiro Alto',  N'Compresión 4-way stretch, tiro alto, bolsillo lateral',         199.99, 90, N'leggins-deportivos-tiro-alto'),
    (N'Blazer Elegante Entallado',     N'Tela sarga, corte entallado, forro interior, 2 botones',        799.99, 25, N'blazer-elegante-entallado'),
    (N'Falda Midi Plisada',            N'Satén suave, cintura elástica, plisado completo, midi',         299.99, 40, N'falda-midi-plisada')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CALZADO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Tenis Running Hombre Amortiguado',N'Suela EVA amortiguada, upper mesh transpirable, tallas 38-46', 599.99, 40, N'tenis-running-hombre-amort'),
    (N'Zapatos Formales Cuero Genuino', N'Cuero bovino genuino, suela cuero, plantilla acolchada',       799.99, 20, N'zapatos-formales-cuero-genuino'),
    (N'Sandalias Mujer Tacón Bajo',     N'Correa ajustable, tacón 4cm, tiras cruzadas, varios colores',  299.99, 45, N'sandalias-mujer-tacon-bajo'),
    (N'Botas Caña Alta Mujer',          N'Caña alta 35cm, cierre lateral, suela antideslizante',         899.99, 18, N'botas-cana-alta-mujer')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ACCESORIOS MODA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Bolso Cuero PU Mujer Tote',    N'Cuero PU suave, asa larga + corta, bolsillos interiores',     699.99, 25, N'bolso-cuero-pu-mujer-tote'),
    (N'Cinturón Cuero Genuino Hombre',N'Cuero genuino 100%, hebilla níquel, ancho 3.5cm, tallas',     249.99, 40, N'cinturon-cuero-genuino-hombre'),
    (N'Reloj Análogo Acero Clásico',  N'Mecanismo japonés, correa acero 316L, cristal mineral 5ATM',  999.99, 15, N'reloj-analogico-acero-clasico')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== MAQUILLAJE ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Base Líquida SPF 30 FPS',       N'Cobertura media-alta, 30 tonos, SPF 30, duración 24h',        249.99, 50, N'base-liquida-spf30-fps'),
    (N'Paleta Sombras 12 Tonos Nude',  N'12 tonos matte y shimmer, altamente pigmentada, espejo',      299.99, 35, N'paleta-sombras-12-nude'),
    (N'Labial Mate de Larga Duración', N'Fórmula mate, 8h sin retoques, no transfiere, 24 tonos',       99.99, 80, N'labial-mate-larga-duracion'),
    (N'Corrector Líquido Iluminador',  N'Cobertura buildable, hidratante, 20 tonos, finish luminoso',   179.99, 55, N'corrector-liquido-iluminador')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CUIDADO FACIAL ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Sérum Vitamina C 20% 30ml',     N'Vitamina C estabilizada 20%, ácido ferúlico, antioxidante',    299.99, 40, N'serum-vitamina-c-20-30ml'),
    (N'Crema Hidratante SPF 50 50ml',  N'Hidratación 48h, SPF 50, sin parabenos, todos tipos piel',     199.99, 55, N'crema-hidratante-spf50-50ml'),
    (N'Limpiador Facial Espuma Gentle', N'pH balanceado, libre sulfatos, apto piel sensible, 150ml',     149.99, 65, N'limpiador-facial-espuma-gentle')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CUIDADO CAPILAR ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Shampoo Anticaída Biotina 400ml', N'Biotina + Keratina, fortalece desde la raíz, sin sal',       129.99, 60, N'shampoo-anticaida-biotina-400ml'),
    (N'Mascarilla Reparadora Argán 250g',N'Aceite de argán marroquí, repara puntas, brillo intenso',    179.99, 45, N'mascarilla-reparadora-argan-250g'),
    (N'Aceite Argán Puro Cabello 50ml', N'100% puro prensado en frío, multipropósito, sin silicona',    199.99, 35, N'aceite-argan-puro-cabello-50ml')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== PERFUMES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Perfume Floral Mujer EDP 100ml', N'Eau de Parfum, notas floral-frutal, duración 8-10h',          499.99, 20, N'perfume-floral-mujer-edp-100ml'),
    (N'Colonia Hombre EDT 100ml',       N'Eau de Toilette, notas amaderadas-especiadas, duración 6h',    399.99, 25, N'colonia-hombre-edt-100ml'),
    (N'Set Regalo Perfume + Body Loción',N'EDP 50ml + Body Lotion 200ml, caja regalo premium',           699.99, 15, N'set-regalo-perfume-body-locion')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== FITNESS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Mancuernas Ajustables 2-20kg',   N'Sistema dial ajuste rápido, reemplaza 15 pares, base incluida', 1499.99, 12, N'mancuernas-ajustables-2-20kg'),
    (N'Colchoneta Yoga Antidesliz 6mm', N'6mm espesor, caucho natural, superficie antidesliz, 183x61cm',   299.99, 50, N'colchoneta-yoga-anti-6mm'),
    (N'Banda Elástica Resistencia x3',  N'Set 3 niveles resistencia (liviana, media, fuerte), látex natural', 149.99, 70, N'banda-elastica-resist-x3'),
    (N'Cuerda Saltar Speed PRO',        N'Cable acero recubierto, mangos aluminum, ajustable, contador',    199.99, 55, N'cuerda-saltar-speed-pro'),
    (N'Guantes Gym Antidesliz L/XL',    N'Cuero sintético palma, velcro ajustable, ventilación dorso',     149.99, 65, N'guantes-gym-antidesliz')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== FUTBOL ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Balón Fútbol Termosellado No.5', N'Termosellado 32 paneles, cuero PU, apto césped/sintético',    299.99, 40, N'balon-futbol-termosellado-no5'),
    (N'Guayos Fútbol Césped Natural',   N'Upper sintético, suela TPU 13 tacos, tallas 36-45',            499.99, 30, N'guayos-futbol-cesped-natural'),
    (N'Espinilleras con Tobillera',     N'EVA alta densidad, tobillera integrada, tallas XS-XL',          149.99, 60, N'espinilleras-con-tobillera'),
    (N'Arco Portátil Entrenamiento',    N'Aluminio 180x120cm, red incluida, piquetas fijación, plegable',  799.99, 15, N'arco-portatil-entrenamiento')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== CICLISMO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Casco Ciclismo MTB Adulto',      N'Certificado CE EN1078, ventilación 18 canales, talla M-L',     399.99, 25, N'casco-ciclismo-mtb-adulto'),
    (N'Guantes Ciclismo Acolchados',    N'Gel palma, dedos cortos, velcro, protección impacto',          149.99, 45, N'guantes-ciclismo-acolchados'),
    (N'Silla Ciclismo Gel Acolchada',   N'Gel dual densidad, rieles acero, 27.2mm, 280g',                299.99, 30, N'silla-ciclismo-gel-acolchada')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== OUTDOOR ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Carpa Camping 4 Personas Domo',  N'Impermeable 2000mm, montaje 5min, doble capa, bolsa',        1499.99, 12, N'carpa-camping-4-personas-domo'),
    (N'Sleeping Bag -5°C Momia',        N'Relleno 200g fibra hueca, temperatura confort -5°C, 1.2kg',    599.99, 20, N'sleeping-bag-minus5-momia'),
    (N'Mochila Trekking 45L Impermeable',N'Armazón aluminio, cinturón lumbar, cubierta lluvia, 45L',     899.99, 15, N'mochila-trekking-45l-imp')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== JUGUETES BEBE ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Gimnasio Actividades Bebé 0-12m',N'5 juguetes colgantes, alfombra suave, arcos desmontables',    699.99, 18, N'gimnasio-actividades-bebe-012m'),
    (N'Sonajeros Set x4 Piezas',        N'BPA free, colores vivos, texturas variadas, lavable',          149.99, 55, N'sonajeros-set-x4-piezas'),
    (N'Andadera Musical con Luces',     N'Bandeja extraíble, 6 actividades, melodías, 6-18 meses',        499.99, 20, N'andadera-musical-con-luces')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== JUEGOS DE MESA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Monopolio Clásico Español',      N'Edición clásica en español, 2-6 jugadores, +8 años',           349.99, 25, N'monopolio-clasico-espanol'),
    (N'Scrabble Deluxe Español',        N'Tablero giratorio, fichas premium, 2-4 jugadores',              299.99, 20, N'scrabble-deluxe-espanol'),
    (N'Rompecabezas 1000 Piezas Paisaje',N'1000 piezas premium, 70x50cm terminado, marco incluido',       199.99, 35, N'rompecabezas-1000-piezas-paisaje')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== FIGURAS Y COLECCIONABLES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Figura Acción Articulada 30cm',  N'12 puntos articulación, accesorios incluidos, 30cm',           199.99, 30, N'figura-accion-articulada-30cm'),
    (N'Set Dinosaurios Realistas x8',   N'8 figuras pintadas a mano, escala 1:30, caucho suave',          299.99, 25, N'set-dinosaurios-realistas-x8'),
    (N'Colección Vehículos Metal x5',   N'Miniaturas fundición metal 1:64, diferentes modelos',           249.99, 40, N'coleccion-vehiculos-metal-x5')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== JUGUETES EDUCATIVOS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Kit Construcción Bloques 200pz', N'200 bloques compatibles, colores vivos, bolsa almacenaje',      449.99, 30, N'kit-construccion-bloques-200pz'),
    (N'Ábaco Madera Colores 10 Filas',  N'Madera maciza, 100 cuentas, base antideslizante, +2 años',      149.99, 40, N'abaco-madera-colores-10filas'),
    (N'Telescopio Infantil 40x Trípode',N'40x ampliación, lente 70mm, trípode ajustable, manual',         499.99, 15, N'telescopio-infantil-40x-tripode')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ACCESORIOS AUTO ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Set Tapetes Goma Universal x4',  N'Goma antideslizante, borde elevado, fácil limpieza, x4',        299.99, 35, N'tapetes-goma-universal-x4'),
    (N'Soporte Celular Ventilación Mag',N'Compatible MagSafe, rotación 360°, instalación sin tornillos',   99.99, 80, N'soporte-celular-ventilacion-mag'),
    (N'Cámara de Reversa HD 170°',      N'1080p, visión nocturna, ángulo 170°, resistente agua IP68',      399.99, 20, N'camara-reversa-hd-170'),
    (N'Ambientador Auto Premium Pack x3',N'3 fragancias (vainilla, cuero, cítrico), duración 60 días',      79.99, 100, N'ambientador-auto-premium-x3')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== HERRAMIENTAS TALLER ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Kit Herramientas 40 Piezas Maletín',N'Maletín aluminio, acero CrV, destornilladores+llaves+alicates', 699.99, 18, N'kit-herramientas-40pz-maletin'),
    (N'Inflador Digital Auto 150PSI',    N'150PSI, pantalla LCD, apagado automático, 12V mechero',           299.99, 25, N'inflador-digital-auto-150psi'),
    (N'Gato Hidráulico Botella 2 Ton',  N'2 toneladas capacidad, altura mín 18cm máx 35cm, acero',           899.99, 12, N'gato-hidraulico-botella-2ton')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== LUBRICANTES ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Aceite Motor Sintético 5W-30 4L', N'100% sintético API SN, compatible gasolina/diesel, 4L',         299.99, 30, N'aceite-motor-sint-5w30-4l'),
    (N'Refrigerante Motor Concentrado 1L',N'Concentrado 1:2, protección -35°C a +120°C, 1L',                119.99, 40, N'refrigerante-motor-conc-1l')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== REPUESTOS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Batería Auto 60Ah 540A MF',      N'Libre mantenimiento, 60Ah, 540A arranque, polaridad estándar',  1299.99, 10, N'bateria-auto-60ah-540a-mf'),
    (N'Filtro de Aceite Universal',     N'Acero galvanizado, compatible 90% vehículos, 3/4-16 UNF',         79.99, 60, N'filtro-aceite-universal')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== DESPENSA ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Arroz Extra Largo 5kg Premium',   N'Grano largo premium, sin gluten, bolsa resellable',              89.99, 80, N'arroz-extra-largo-5kg-premium'),
    (N'Aceite de Girasol Extra 1L',      N'Alto oleico, prensado en frío, libre colesterol',                 49.99, 120, N'aceite-girasol-extra-1l'),
    (N'Espagueti 500g Pack x5 Bronce',  N'Elaborado con trigo duro, textura rugosa, pack ahorro x5',         69.99, 100, N'espagueti-500g-bronce-x5')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== BEBIDAS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Agua Mineral Natural 500ml x12', N'Manantial natural, sin gas, pack 12 botellas x500ml',             79.99, 100, N'agua-mineral-500ml-x12'),
    (N'Jugo Natural Naranja 100% 1L',   N'Sin azúcar añadida, sin conservantes, 100% naranja',              49.99, 80,  N'jugo-natural-naranja-100-1l'),
    (N'Café Molido Arábica 500g',       N'Arábica 100%, tostado medio, molienda fina para espresso',        129.99, 60,  N'cafe-molido-arabica-500g')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== SNACKS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Papas Fritas Sabor Natural 150g', N'Rebanadas finas, sal marina, sin glutamato, bolsa 150g',          29.99, 150, N'papas-fritas-natural-150g'),
    (N'Galletas Chocolate Pack x6 200g',N'Doble choco chip, pack 6 bolsas, sin colorantes artificiales',    59.99, 120, N'galletas-chocolate-x6-200g')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== LACTEOS Y HUEVOS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Leche Entera UHT 1L Pack x6',    N'Entera 3.5% grasa, UHT larga vida, sin lactosa disponible',      89.99, 80, N'leche-entera-uht-1l-x6'),
    (N'Yogur Natural sin Azúcar x4',    N'Bifidus activo, sin azúcar añadida, pack 4x125g',                  49.99, 70, N'yogur-natural-sin-azucar-x4')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ALIMENTO PERROS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Croquetas Perro Adulto Pollo 15kg',N'Pollo como 1er ingrediente, omega 3+6, sin colorantes',          599.99, 20, N'croquetas-perro-adulto-pollo-15k'),
    (N'Comida Húmeda Perro Res 400g x6', N'Res y vegetales en gelatina, 85% carne, sin soja x6',             299.99, 30, N'comida-humeda-perro-res-400g-x6')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ALIMENTO GATOS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Croquetas Gato Adulto Atún 8kg', N'Atún y salmón, taurina, hairball control, bolsa 8kg',              399.99, 18, N'croquetas-gato-adulto-atun-8kg'),
    (N'Pouch Atún y Pollo Gato x4',     N'Gelatina natural, sin cereales, alto en proteína, x4 85g',          79.99, 55, N'pouch-atun-pollo-gato-x4')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== HIGIENE MASCOTAS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Shampoo Antipulgas Perro 500ml', N'Clorexidina 2%, elimina pulgas/garrapatas, pH neutro',            149.99, 40, N'shampoo-antipulgas-perro-500ml'),
    (N'Arena Sanitaria Gato Aglomerante 10kg', N'Ultra aglomerante, control olor 30 días, sin polvo',        179.99, 30, N'arena-sanitaria-gato-aglom-10kg')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- ======================== ACCESORIOS MASCOTAS ========================
INSERT INTO inventario_product (name, description, price, stock, image, slug, active, created_at, updated_at)
SELECT src.name, src.description, src.price, src.stock, NULL, src.slug, CAST(1 AS BIT), GETDATE(), GETDATE()
FROM (VALUES
    (N'Collar Ajustable con Placa ID',  N'Nylon reforzado, placa acero grabable, ajuste S-M-L',              99.99, 60, N'collar-ajustable-placa-id'),
    (N'Cama Ortopédica Mascotas L',     N'Espuma ortopédica 10cm, funda polar lavable, talla L 90x70cm',     499.99, 15, N'cama-ortopedica-mascotas-l'),
    (N'Juguete Kong Relleno Perros M',  N'Caucho natural resistente, rellenable con snacks, talla M',        129.99, 45, N'juguete-kong-relleno-perros-m')
) AS src(name, description, price, stock, slug)
WHERE NOT EXISTS (SELECT 1 FROM inventario_product WHERE slug = src.slug);

-- =================================================================
-- PARTE 2: RELACIONES PRODUCTO <-> CATEGORÍA (ManyToMany)
-- Tabla: inventario_product_category (product_id, category_id)
-- =================================================================

-- === TECLADOS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Teclados'
  AND p.slug IN (N'teclado-mecanico-red', N'teclado-mecanico-blue', N'teclado-mecanico-brown',
                 N'teclado-membrana-usb', N'teclado-inalambrico-bluetooth', N'teclado-gaming-rgb',
                 N'teclado-compacto-tkl', N'teclado-ergonomico-dividido')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === MOUSE ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Mouse'
  AND p.slug IN (N'mouse-gaming-6400dpi', N'mouse-inalambrico-ergonomico', N'mouse-basico-usb',
                 N'mouse-vertical-ergonomico', N'mouse-gaming-rgb-16000dpi', N'mouse-bluetooth-portatil',
                 N'mouse-trackball-inalambrico')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === MONITORES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Monitores'
  AND p.slug IN (N'monitor-24-full-hd-ips', N'monitor-27-qhd-144hz', N'monitor-32-4k-uhd',
                 N'monitor-curvo-27-165hz', N'monitor-gaming-240hz', N'monitor-portatil-usbc-15')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === IMPRESORAS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Impresoras'
  AND p.slug IN (N'impresora-laser-monocromo', N'impresora-tinta-color',
                 N'multifuncional-imprime-escanea', N'impresora-fotografica-6x4')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === LAPTOPS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Laptops'
  AND p.slug IN (N'laptop-i5-8gb-256ssd', N'laptop-i7-16gb-512ssd', N'laptop-gamer-rtx3060-16gb',
                 N'laptop-ultrabook-14-i5', N'laptop-macbook-air-m2', N'laptop-economica-celeron-4gb',
                 N'laptop-2en1-tactil-i5', N'laptop-chromebook-11')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === PC DE ESCRITORIO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'PC de Escritorio'
  AND p.slug IN (N'pc-escritorio-i5-16gb', N'pc-escritorio-i9-32gb', N'pc-aio-27-fhd-i7',
                 N'mini-pc-intel-nuc-i5', N'pc-gamer-i7-rtx4060')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === COMPONENTES PC ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Componentes PC'
  AND p.slug IN (N'procesador-intel-i5-13400', N'procesador-intel-i9-13900k', N'procesador-amd-ryzen5-7600x',
                 N'memoria-ram-16gb-ddr5', N'memoria-ram-32gb-ddr4', N'ssd-1tb-nvme-pcie4',
                 N'gpu-nvidia-rtx4070-12gb', N'fuente-poder-750w-gold')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === AUDIO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Audio'
  AND p.slug IN (N'audifonos-over-ear-anc', N'bocina-bluetooth-360-20w', N'soundbar-21-subwoofer-120w',
                 N'audifonos-inear-sport-tws', N'barra-sonido-surround-51')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CAMARAS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Camaras'
  AND p.slug IN (N'camara-dslr-24mp-kit', N'camara-mirrorless-sony-33mp', N'camara-accion-4k60fps',
                 N'camara-instantanea-pelicula', N'camara-web-4k-usbc')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === WEARABLES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Wearables'
  AND p.slug IN (N'smartwatch-samsung-galaxy-w6', N'apple-watch-series9-41mm',
                 N'banda-fitness-xiaomi-band8', N'smartwatch-garmin-gps-running')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === TV Y VIDEO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'TV y Video'
  AND p.slug IN (N'televisor-55-4k-smart-uhd', N'televisor-65-oled-4k', N'proyector-full-hd-3000lm',
                 N'televisor-43-fhd-smart', N'televisor-75-qled-4k-120hz')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === SMARTPHONES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Smartphones'
  AND p.slug IN (N'samsung-galaxy-s24-256gb', N'iphone-15-pro-max-256gb', N'xiaomi-redmi-note13-128gb',
                 N'motorola-edge40-256gb', N'google-pixel8-128gb', N'samsung-galaxy-a55-256gb',
                 N'iphone-14-128gb', N'xiaomi-poco-x6-pro-256gb')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === FUNDAS Y PROTECTORES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Fundas y Protectores'
  AND p.slug IN (N'funda-iphone15-silicona-liquida', N'funda-samsung-s24-tpu-trans',
                 N'vidrio-templado-9h-universal', N'funda-cartera-tarjetero', N'funda-antigolpes-military')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CARGADORES Y CABLES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Cargadores y Cables'
  AND p.slug IN (N'cargador-rapido-65w-gan-usbc', N'cargador-inalambrico-qi-15w', N'cable-usbc-usbc-2m-nylon',
                 N'powerbank-20000mah-65w-pd', N'cargador-auto-30w-dual')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === AUDIO MOVIL ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id
FROM inventario_product p
CROSS JOIN inventario_category c
WHERE c.name = N'Audio Movil'
  AND p.slug IN (N'airpods-pro-2da-generacion', N'samsung-galaxy-buds2-pro',
                 N'audifonos-tws-xiaomi-buds4', N'audifonos-bluetooth-deportivos')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === MUEBLES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Muebles'
  AND p.slug IN (N'sofa-3-puestos-tela-gris', N'mesa-centro-madera-mdf', N'cama-queen-madera-160cm',
                 N'librero-5-estantes-mdf', N'escritorio-esquinero-madera')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === DECORACION ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Decoracion'
  AND p.slug IN (N'cuadro-abstracto-canvas-80x60', N'lampara-pie-led-regulable',
                 N'set-4-cojines-decorativos', N'espejo-decorativo-marco-dorado')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === LIMPIEZA HOGAR ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Limpieza Hogar'
  AND p.slug IN (N'aspiradora-vertical-22v', N'mopa-microfibra-cubo-escurridor',
                 N'robot-aspirador-fregador-wifi', N'set-limpieza-bano-5-piezas')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ORGANIZACION ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Organizacion'
  AND p.slug IN (N'organizador-closet-20div', N'cajas-plastico-transparente-x3', N'estante-metalico-5-niveles')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ELECTRODOMESTICOS COCINA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Electrodomesticos Cocina'
  AND p.slug IN (N'freidora-aire-digital-55l', N'licuadora-vaso-600w-2l', N'microondas-digital-25l-900w',
                 N'cafetera-espresso-15bar', N'tostadora-4-ranuras-1500w')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === UTENSILIOS COCINA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Utensilios Cocina'
  AND p.slug IN (N'set-cuchillos-acero-inox-7pz', N'tabla-corte-bambu-anti',
                 N'wok-antiadherente-32cm-ind', N'rallador-multiusos-6-caras')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === VAJILLA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Vajilla'
  AND p.slug IN (N'vajilla-ceramica-12-piezas', N'set-vasos-cristal-soplado-x6',
                 N'cubiertos-acero-inox-24pz', N'tazas-cafe-porcelana-x4')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ALMACENAMIENTO COCINA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Almacenamiento Cocina'
  AND p.slug IN (N'recipientes-hermeticos-vidrio-x5', N'organizador-especiero-16fr', N'bolsas-vacio-reutilizables-x10')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ROPA HOMBRE ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Ropa Hombre'
  AND p.slug IN (N'polo-basico-algodon-100', N'jeans-slim-fit-azul-oscuro', N'camisa-formal-oxford-blanca',
                 N'chaqueta-bomber-poliester', N'short-deportivo-dry-fit')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ROPA MUJER ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Ropa Mujer'
  AND p.slug IN (N'blusa-floral-gasa', N'vestido-casual-midi-verano', N'leggins-deportivos-tiro-alto',
                 N'blazer-elegante-entallado', N'falda-midi-plisada')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CALZADO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Calzado'
  AND p.slug IN (N'tenis-running-hombre-amort', N'zapatos-formales-cuero-genuino',
                 N'sandalias-mujer-tacon-bajo', N'botas-cana-alta-mujer')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ACCESORIOS MODA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Accesorios Moda'
  AND p.slug IN (N'bolso-cuero-pu-mujer-tote', N'cinturon-cuero-genuino-hombre', N'reloj-analogico-acero-clasico')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === MAQUILLAJE ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Maquillaje'
  AND p.slug IN (N'base-liquida-spf30-fps', N'paleta-sombras-12-nude', N'labial-mate-larga-duracion', N'corrector-liquido-iluminador')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CUIDADO FACIAL ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Cuidado Facial'
  AND p.slug IN (N'serum-vitamina-c-20-30ml', N'crema-hidratante-spf50-50ml', N'limpiador-facial-espuma-gentle')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CUIDADO CAPILAR ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Cuidado Capilar'
  AND p.slug IN (N'shampoo-anticaida-biotina-400ml', N'mascarilla-reparadora-argan-250g', N'aceite-argan-puro-cabello-50ml')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === PERFUMES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Perfumes'
  AND p.slug IN (N'perfume-floral-mujer-edp-100ml', N'colonia-hombre-edt-100ml', N'set-regalo-perfume-body-locion')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === FITNESS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Fitness'
  AND p.slug IN (N'mancuernas-ajustables-2-20kg', N'colchoneta-yoga-anti-6mm', N'banda-elastica-resist-x3',
                 N'cuerda-saltar-speed-pro', N'guantes-gym-antidesliz')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === FUTBOL ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Futbol'
  AND p.slug IN (N'balon-futbol-termosellado-no5', N'guayos-futbol-cesped-natural',
                 N'espinilleras-con-tobillera', N'arco-portatil-entrenamiento')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === CICLISMO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Ciclismo'
  AND p.slug IN (N'casco-ciclismo-mtb-adulto', N'guantes-ciclismo-acolchados', N'silla-ciclismo-gel-acolchada')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === OUTDOOR ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Outdoor'
  AND p.slug IN (N'carpa-camping-4-personas-domo', N'sleeping-bag-minus5-momia', N'mochila-trekking-45l-imp')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === JUGUETES BEBE ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Juguetes Bebe'
  AND p.slug IN (N'gimnasio-actividades-bebe-012m', N'sonajeros-set-x4-piezas', N'andadera-musical-con-luces')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === JUEGOS DE MESA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Juegos de Mesa'
  AND p.slug IN (N'monopolio-clasico-espanol', N'scrabble-deluxe-espanol', N'rompecabezas-1000-piezas-paisaje')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === FIGURAS Y COLECCIONABLES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Figuras y Coleccionables'
  AND p.slug IN (N'figura-accion-articulada-30cm', N'set-dinosaurios-realistas-x8', N'coleccion-vehiculos-metal-x5')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === JUGUETES EDUCATIVOS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Juguetes Educativos'
  AND p.slug IN (N'kit-construccion-bloques-200pz', N'abaco-madera-colores-10filas', N'telescopio-infantil-40x-tripode')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ACCESORIOS AUTO ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Accesorios Auto'
  AND p.slug IN (N'tapetes-goma-universal-x4', N'soporte-celular-ventilacion-mag',
                 N'camara-reversa-hd-170', N'ambientador-auto-premium-x3')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === HERRAMIENTAS TALLER ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Herramientas Taller'
  AND p.slug IN (N'kit-herramientas-40pz-maletin', N'inflador-digital-auto-150psi', N'gato-hidraulico-botella-2ton')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === LUBRICANTES ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Lubricantes'
  AND p.slug IN (N'aceite-motor-sint-5w30-4l', N'refrigerante-motor-conc-1l')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === REPUESTOS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Repuestos'
  AND p.slug IN (N'bateria-auto-60ah-540a-mf', N'filtro-aceite-universal')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === DESPENSA ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Despensa'
  AND p.slug IN (N'arroz-extra-largo-5kg-premium', N'aceite-girasol-extra-1l', N'espagueti-500g-bronce-x5')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === BEBIDAS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Bebidas'
  AND p.slug IN (N'agua-mineral-500ml-x12', N'jugo-natural-naranja-100-1l', N'cafe-molido-arabica-500g')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === SNACKS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Snacks'
  AND p.slug IN (N'papas-fritas-natural-150g', N'galletas-chocolate-x6-200g')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === LACTEOS Y HUEVOS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Lacteos y Huevos'
  AND p.slug IN (N'leche-entera-uht-1l-x6', N'yogur-natural-sin-azucar-x4')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ALIMENTO PERROS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Alimento Perros'
  AND p.slug IN (N'croquetas-perro-adulto-pollo-15k', N'comida-humeda-perro-res-400g-x6')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ALIMENTO GATOS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Alimento Gatos'
  AND p.slug IN (N'croquetas-gato-adulto-atun-8kg', N'pouch-atun-pollo-gato-x4')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === HIGIENE MASCOTAS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Higiene Mascotas'
  AND p.slug IN (N'shampoo-antipulgas-perro-500ml', N'arena-sanitaria-gato-aglom-10kg')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

-- === ACCESORIOS MASCOTAS ===
INSERT INTO inventario_product_category (product_id, category_id)
SELECT p.id, c.id FROM inventario_product p CROSS JOIN inventario_category c
WHERE c.name = N'Accesorios Mascotas'
  AND p.slug IN (N'collar-ajustable-placa-id', N'cama-ortopedica-mascotas-l', N'juguete-kong-relleno-perros-m')
  AND NOT EXISTS (SELECT 1 FROM inventario_product_category pc WHERE pc.product_id = p.id AND pc.category_id = c.id);

COMMIT;

-- =================================================================
-- VERIFICACION FINAL
-- =================================================================
SELECT COUNT(*) AS total_productos FROM inventario_product;
SELECT COUNT(*) AS total_relaciones FROM inventario_product_category;

-- Top 10 categorías por número de productos
SELECT TOP 10
    c.name AS categoria,
    COUNT(pc.product_id) AS num_productos
FROM inventario_category c
LEFT JOIN inventario_product_category pc ON c.id = pc.category_id
GROUP BY c.id, c.name
ORDER BY num_productos DESC;
