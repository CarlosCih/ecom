USE ecomdb;

BEGIN TRAN;

------------------------------------------------------------
-- 1) CATEGORIAS EXISTENTES (Tecnología, Computo, Perifericos)
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Tecnología')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Tecnología', N'Productos tecnológicos', NULL, GETDATE(), GETDATE());

DECLARE @TecnologiaId INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Tecnología');

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Computo')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Computo', N'Equipos de cómputo', @TecnologiaId, GETDATE(), GETDATE());

DECLARE @ComputoId INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Computo');

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Perifericos')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Perifericos', N'Accesorios y periféricos', @ComputoId, GETDATE(), GETDATE());

DECLARE @PerifericosId INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Perifericos');

-- Corrige padres si estaban mal asignados
UPDATE inventario_category
SET parents_id = @TecnologiaId, updated_at = GETDATE()
WHERE name = N'Computo'
  AND (parents_id IS NULL OR parents_id <> @TecnologiaId);

UPDATE inventario_category
SET parents_id = @ComputoId, updated_at = GETDATE()
WHERE name = N'Perifericos'
  AND (parents_id IS NULL OR parents_id <> @ComputoId);

------------------------------------------------------------
-- 2) CATEGORIAS RAIZ NUEVAS
------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Telefonia')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Telefonia', N'Celulares y accesorios', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Hogar')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Hogar', N'Artículos para el hogar', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Cocina')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Cocina', N'Utensilios y electrodomésticos', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Moda')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Moda', N'Ropa, calzado y accesorios', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Belleza')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Belleza', N'Cuidado personal y cosmética', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Deportes')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Deportes', N'Implementos deportivos', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Juguetes')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Juguetes', N'Juguetes y entretenimiento', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Automotriz')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Automotriz', N'Productos para autos y motos', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Supermercado')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Supermercado', N'Consumo diario y alimentos', NULL, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Mascotas')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Mascotas', N'Productos para mascotas', NULL, GETDATE(), GETDATE());

------------------------------------------------------------
-- 3) VARIABLES ID PARA PADRES
------------------------------------------------------------
DECLARE @TelefoniaId    INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Telefonia');
DECLARE @HogarId        INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Hogar');
DECLARE @CocinaId       INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Cocina');
DECLARE @ModaId         INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Moda');
DECLARE @BellezaId      INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Belleza');
DECLARE @DeportesId     INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Deportes');
DECLARE @JuguetesId     INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Juguetes');
DECLARE @AutomotrizId   INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Automotriz');
DECLARE @SupermercadoId INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Supermercado');
DECLARE @MascotasId     INT = (SELECT TOP 1 id FROM inventario_category WHERE name = N'Mascotas');

------------------------------------------------------------
-- 4) SUBCATEGORIAS
------------------------------------------------------------

-- === Computo ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Laptops')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Laptops', N'Portátiles de uso personal y profesional', @ComputoId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'PC de Escritorio')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'PC de Escritorio', N'Computadores de escritorio', @ComputoId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Componentes PC')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Componentes PC', N'CPU, RAM, SSD, GPU y más', @ComputoId, GETDATE(), GETDATE());

-- === Perifericos ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Monitores')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Monitores', N'Monitores y pantallas', @PerifericosId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Teclados')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Teclados', N'Teclados mecánicos y membrana', @PerifericosId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Mouse')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Mouse', N'Mouse y apuntadores', @PerifericosId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Impresoras')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Impresoras', N'Impresoras y multifuncionales', @PerifericosId, GETDATE(), GETDATE());

-- === Tecnología ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Audio')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Audio', N'Parlantes y audífonos', @TecnologiaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Camaras')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Camaras', N'Cámaras fotográficas y video', @TecnologiaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Wearables')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Wearables', N'Relojes y bandas inteligentes', @TecnologiaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'TV y Video')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'TV y Video', N'Televisores y proyectores', @TecnologiaId, GETDATE(), GETDATE());

-- === Telefonia ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Smartphones')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Smartphones', N'Teléfonos inteligentes de todas las gamas', @TelefoniaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Fundas y Protectores')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Fundas y Protectores', N'Fundas y vidrios templados', @TelefoniaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Cargadores y Cables')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Cargadores y Cables', N'Carga rápida y conectividad', @TelefoniaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Audio Movil')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Audio Movil', N'Audífonos y manos libres', @TelefoniaId, GETDATE(), GETDATE());

-- === Hogar ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Muebles')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Muebles', N'Muebles para sala, comedor y dormitorio', @HogarId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Decoracion')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Decoracion', N'Cuadros, lámparas y artículos decorativos', @HogarId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Limpieza Hogar')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Limpieza Hogar', N'Productos e implementos de limpieza', @HogarId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Organizacion')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Organizacion', N'Cajas, estantes y soluciones de orden', @HogarId, GETDATE(), GETDATE());

-- === Cocina ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Electrodomesticos Cocina')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Electrodomesticos Cocina', N'Freidoras, licuadoras, microondas', @CocinaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Utensilios Cocina')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Utensilios Cocina', N'Cuchillos, tablas y herramientas', @CocinaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Vajilla')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Vajilla', N'Platos, vasos y cubiertos', @CocinaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Almacenamiento Cocina')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Almacenamiento Cocina', N'Recipientes y organizadores', @CocinaId, GETDATE(), GETDATE());

-- === Moda ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Ropa Hombre')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Ropa Hombre', N'Prendas y moda masculina', @ModaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Ropa Mujer')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Ropa Mujer', N'Prendas y moda femenina', @ModaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Calzado')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Calzado', N'Zapatos, tenis y sandalias', @ModaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Accesorios Moda')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Accesorios Moda', N'Bolsos, cinturones y relojes', @ModaId, GETDATE(), GETDATE());

-- === Belleza ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Maquillaje')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Maquillaje', N'Bases, labiales y sombras', @BellezaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Cuidado Facial')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Cuidado Facial', N'Limpieza e hidratación facial', @BellezaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Cuidado Capilar')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Cuidado Capilar', N'Shampoo, tratamientos y styling', @BellezaId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Perfumes')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Perfumes', N'Fragancias para hombre y mujer', @BellezaId, GETDATE(), GETDATE());

-- === Deportes ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Fitness')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Fitness', N'Pesas, bandas y accesorios de entrenamiento', @DeportesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Futbol')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Futbol', N'Balones, guayos y protecciones', @DeportesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Ciclismo')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Ciclismo', N'Bicicletas, cascos y accesorios', @DeportesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Outdoor')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Outdoor', N'Camping, trekking y aventura', @DeportesId, GETDATE(), GETDATE());

-- === Juguetes ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Juguetes Bebe')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Juguetes Bebe', N'Estimulación temprana y primera infancia', @JuguetesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Juegos de Mesa')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Juegos de Mesa', N'Juegos familiares y de estrategia', @JuguetesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Figuras y Coleccionables')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Figuras y Coleccionables', N'Figuras de acción y colección', @JuguetesId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Juguetes Educativos')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Juguetes Educativos', N'Aprendizaje y desarrollo cognitivo', @JuguetesId, GETDATE(), GETDATE());

-- === Automotriz ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Accesorios Auto')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Accesorios Auto', N'Tapetes, fundas y gadgets para auto', @AutomotrizId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Herramientas Taller')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Herramientas Taller', N'Herramientas para mantenimiento', @AutomotrizId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Lubricantes')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Lubricantes', N'Aceites, aditivos y líquidos', @AutomotrizId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Repuestos')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Repuestos', N'Partes y repuestos para vehículos', @AutomotrizId, GETDATE(), GETDATE());

-- === Supermercado ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Despensa')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Despensa', N'Arroz, pastas, granos y conservas', @SupermercadoId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Bebidas')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Bebidas', N'Gaseosas, jugos, agua y energizantes', @SupermercadoId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Snacks')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Snacks', N'Galletas, papas y pasabocas', @SupermercadoId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Lacteos y Huevos')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Lacteos y Huevos', N'Leche, yogur, quesos y huevos', @SupermercadoId, GETDATE(), GETDATE());

-- === Mascotas ===
IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Alimento Perros')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Alimento Perros', N'Concentrado y comida húmeda para perros', @MascotasId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Alimento Gatos')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Alimento Gatos', N'Concentrado y comida húmeda para gatos', @MascotasId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Higiene Mascotas')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Higiene Mascotas', N'Arena, shampoo y limpieza', @MascotasId, GETDATE(), GETDATE());

IF NOT EXISTS (SELECT 1 FROM inventario_category WHERE name = N'Accesorios Mascotas')
    INSERT INTO inventario_category (name, description, parents_id, created_at, updated_at)
    VALUES (N'Accesorios Mascotas', N'Collares, camas, juguetes y correas', @MascotasId, GETDATE(), GETDATE());

COMMIT;

------------------------------------------------------------
-- VERIFICACION
------------------------------------------------------------
SELECT COUNT(*) AS total_categorias FROM inventario_category;

SELECT
    c.id,
    c.name,
    ISNULL(p.name, '(raiz)') AS parent_name
FROM inventario_category c
LEFT JOIN inventario_category p ON c.parents_id = p.id
ORDER BY ISNULL(p.name, c.name), c.name;
