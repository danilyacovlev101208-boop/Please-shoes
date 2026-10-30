-- SQL-запросы для приложения магазина обуви «Воздух».
-- Знак ? — место, куда C#-код подставит значение из формы (параметр запроса).
USE vozduh;

-- =====================================================================
-- Вход в приложение (пункты 2.5, 2.6, 3.17)
-- Пустой результат — «неверный логин или пароль».
-- =====================================================================
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

-- =====================================================================
-- Каталог товаров для Гостя и Администратора (пункты 2.7–2.11)
-- =====================================================================
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id;

-- =====================================================================
-- Поиск, фильтр и сортировка одновременно (пункты 3.2–3.6)
-- Поиск по названию + фильтр по поставщику + сортировка по остатку.
-- =====================================================================
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c    ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s     ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%') AND p.supplier_id = ?
ORDER BY p.stock_qty DESC;

-- Сортировка по остатку по возрастанию (пункты 3.2–3.3)
SELECT p.id, p.article, p.name, p.price, p.stock_qty
FROM products p
ORDER BY p.stock_qty ASC;

-- Только фильтр по поставщику (пункты 3.4–3.5)
SELECT p.id, p.article, p.name, p.price, p.stock_qty, s.name AS supplier
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.supplier_id = ?;

-- =====================================================================
-- Справочники для выпадающих списков в форме товара (пункты 3.7, 3.10)
-- =====================================================================
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- =====================================================================
-- Добавление товара (пункты 3.7, 3.10)
-- =====================================================================
INSERT INTO products
  (article, name, unit, price, discount, stock_qty, description, photo,
   category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- =====================================================================
-- Открыть товар для редактирования — заполнить все поля формы (пункты 3.12, 3.19)
-- =====================================================================
SELECT * FROM products WHERE id = ?;

-- =====================================================================
-- Сохранить изменения товара (пункты 3.12, 3.19)
-- =====================================================================
UPDATE products
SET article = ?, name = ?, unit = ?, price = ?, discount = ?, stock_qty = ?,
    description = ?, photo = ?,
    category_id = ?, manufacturer_id = ?, supplier_id = ?
WHERE id = ?;

-- =====================================================================
-- Удаление товара (пункт 3.16)
-- Сначала проверка: если товар есть в заказах (результат > 0),
-- приложение показывает предупреждение и не удаляет.
-- =====================================================================
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

-- Удаление. Для купленного товара база сама откажет:
-- «Cannot delete or update a parent row: a foreign key constraint fails».
DELETE FROM products WHERE id = ?;
