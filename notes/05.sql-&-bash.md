# SQL Field Guide: Normalization, SQL Injection, and the N+1 Problem

Three database ideas that separate "it works on my machine" from "it survives production". Each concept follows the same breakdown: **What it is**, **The Everyday Analogy**, **Why it matters**, and a **Quick Example**. Every major section ends with a Production Pitfall or Dev Tip.

## Table of Contents

1. [Normalization](#1-normalization)
   - [1NF](#first-normal-form-1nf) | [Keys](#superkeys-candidate-keys-and-primary-keys) | [2NF](#second-normal-form-2nf) | [3NF](#third-normal-form-3nf) | [BCNF](#boyce-codd-normal-form-bcnf) | [Denormalization](#bonus-when-to-break-the-rules-denormalization)
2. [SQL Injection](#2-sql-injection)
3. [The N+1 Problem](#3-the-n1-problem)
4. [Cheat Sheet](#4-cheat-sheet)
5. [Quick Check](#5-quick-check)

---

## 1. Normalization

### What it is

**Normalization** is the process of organizing a relational database into smaller, focused tables, following a set of rules called **normal forms**. You split big messy tables apart and connect them with **primary keys** and **foreign keys**. No data is lost, it is just stored in the right place.

### The Everyday Analogy

Think of a **contacts app on your phone**. You do not retype your friend's address into every text conversation. You store it once in their contact card, and every conversation just points to that card. If they move, you update one place and everything stays correct.

### Why it matters

- **Less redundancy:** Each fact is stored once, which saves space.
- **Fewer inconsistencies:** A customer's address changes in one row, not in every order record.
- **Data integrity:** Primary and foreign key constraints enforce the relationships for you.
- **No anomalies:** Avoids _insertion_, _update_, and _deletion_ anomalies (bugs caused by duplicated data getting out of sync).
- **Easier maintenance:** Small focused tables are simpler to understand and change.

### Quick Example: Before and After

```sql
-- BEFORE: customer data repeated on every order
-- orders(order_id, product, customer_name, customer_address)

-- AFTER: split into two tables, linked by a foreign key
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  address     TEXT NOT NULL
);

CREATE TABLE orders (
  order_id    SERIAL PRIMARY KEY,
  product     TEXT NOT NULL,
  customer_id INT NOT NULL REFERENCES customers(customer_id)
);
```

> **Each normal form builds on the previous one.** To be in 3NF you must already satisfy 2NF, which requires 1NF.

---

### First Normal Form (1NF)

#### What it is

The most basic rule set: make every value **simple and atomic**.

A table is in 1NF if:

- **Each cell holds exactly one value.** No comma-separated lists.
- **Every row is unique.** No duplicate rows.
- **Order does not matter.** Your data should not depend on which row or column comes first.

#### The Everyday Analogy

A **mailing address book** where each field holds one thing: one phone number per line, not three numbers crammed into a single box.

#### Why it matters

- You can **search and filter** by a single value (try querying for one phone number inside a comma-separated string, it is painful).
- You can add a fourth phone number without redesigning the table.

#### Quick Example

```sql
-- NOT 1NF: multiple values in one cell
-- students(student_id, name, phone_numbers)
-- 1 | Thandi | '082 111 1111, 071 222 2222'

-- 1NF: one value per cell, extra table for the repeating data
CREATE TABLE students (
  student_id INT PRIMARY KEY,
  name       TEXT NOT NULL
);

CREATE TABLE phone_numbers (
  phone_id   SERIAL PRIMARY KEY,
  student_id INT NOT NULL REFERENCES students(student_id),
  phone      TEXT NOT NULL
);
```

---

### Superkeys, Candidate Keys, and Primary Keys

You need these terms to understand 2NF and BCNF.

#### What they are

- **Superkey:** _Any_ set of columns that uniquely identifies each row. It may contain extra, unnecessary columns.
- **Candidate key:** A **minimal** superkey. Every column in it is needed to identify the row.
- **Primary key:** The one candidate key you choose as the official identifier.

#### The Everyday Analogy

Identifying a person at a conference:

- **Superkey:** "ID number, plus their shoe size, plus their favourite colour". It works, but most of that is noise.
- **Candidate key:** "ID number" or "email address". Each one alone is enough.
- **Primary key:** The badge number you decide to print on the lanyard.

#### Why it matters

- Choosing a good primary key is the foundation of every table design.
- BCNF is defined in terms of superkeys.

#### Quick Example

Table `customers(customer_id, name, email)` where `customer_id` and `email` are both unique:

| Key set                      | Superkey? | Candidate key?            |
| ---------------------------- | --------- | ------------------------- |
| `{customer_id}`              | Yes       | **Yes**                   |
| `{email}`                    | Yes       | **Yes**                   |
| `{customer_id, name}`        | Yes       | No (`name` is not needed) |
| `{customer_id, name, email}` | Yes       | No (extra columns)        |

> **Every candidate key is a superkey, but not every superkey is a candidate key.**

---

### Second Normal Form (2NF)

#### What it is

A table is in 2NF if it is in 1NF **and** has **no partial dependencies**.

A **partial dependency** is when a non-key column depends on only _part_ of a **composite primary key** (a primary key made of multiple columns).

#### The Everyday Analogy

A **restaurant receipt**. The receipt has a table number and a date (info about the _whole order_), and then a list of dishes (info about _each item_). If you wrote the table number next to every dish on the list, you would be repeating order-level info on item-level lines.

#### Why it matters

- Stops order-level facts from being repeated for every item in the order.
- Prevents update anomalies (change the shipping city on one row and forget the others).

#### Quick Example

```sql
-- PROBLEM: primary key is (order_id, item_id)
-- orders(order_id, item_id, order_date, quantity, order_shipping_city)
--
-- order_shipping_city depends only on order_id (part of the key), not on item_id.
-- That is a partial dependency.

-- FIX: split into two tables
CREATE TABLE order_header (
  order_id            INT PRIMARY KEY,
  order_date          DATE NOT NULL,
  order_shipping_city TEXT NOT NULL
);

CREATE TABLE order_items (
  order_id INT REFERENCES order_header(order_id),
  item_id  INT,
  quantity INT NOT NULL,
  PRIMARY KEY (order_id, item_id)
);
```

> **Dev Tip:** 2NF only matters when you have a **composite** primary key. If your table has a single-column primary key and is in 1NF, it is automatically in 2NF.

---

### Third Normal Form (3NF)

#### What it is

A table is in 3NF if it is in 2NF **and** every non-key column depends **directly** on the primary key, with no non-key column depending on another non-key column.

The thing you are hunting for is a **transitive dependency**: a non-key column that depends on another non-key column, which in turn depends on the primary key.

#### The Everyday Analogy

A **school ID card** that lists the student's name, their class, _and_ the classroom teacher's phone number. The phone number is not really about the student. It is about the teacher. If the teacher changes their number, every student card is out of date.

#### Why it matters

- Eliminates repeated data (a postal code stored once per city, not once per order).
- A postal code change is **one update** instead of thousands.

#### Quick Example

```sql
-- PROBLEM: order_id > customer_id > customer_city > city_postal_code
-- orders(order_id, customer_id, customer_city, city_postal_code, order_date, quantity)
-- city_postal_code is determined by customer_city, not by order_id directly.

-- FIX: three tables
CREATE TABLE cities (
  city_name        TEXT PRIMARY KEY,
  city_postal_code TEXT NOT NULL
);

CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  city_name   TEXT NOT NULL REFERENCES cities(city_name)
);

CREATE TABLE orders (
  order_id    SERIAL PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  order_date  DATE NOT NULL,
  quantity    INT NOT NULL
);
```

---

### Boyce-Codd Normal Form (BCNF)

#### What it is

Also called **3.5NF**. A table is in BCNF if it is in 3NF **and** for every functional dependency (`X -> Y`), the left side (`X`) is a **superkey**.

In plain terms: **anything that determines something else must be able to uniquely identify a row.**

#### The Everyday Analogy

A **university timetable** where each teacher teaches exactly one course. If you know the teacher, you automatically know the course. But "teacher" alone cannot identify a single enrollment row, because many students sit in that class. That is a rule hiding in a table where it does not belong.

#### Why it matters

- Catches the rare anomalies that 3NF lets through.
- Gives you the strictest practical guarantee that dependencies are enforced by keys.

#### Quick Example

```sql
-- PROBLEM: enrollments(student_id, course, teacher)
-- Rule: each teacher teaches exactly one course, so teacher -> course.
-- But teacher is NOT a superkey, so this violates BCNF.

-- FIX: split so the rule lives in its own table
CREATE TABLE teacher_courses (
  teacher TEXT PRIMARY KEY,   -- teacher -> course, and teacher is now the key
  course  TEXT NOT NULL
);

CREATE TABLE student_teachers (
  student_id INT,
  teacher    TEXT REFERENCES teacher_courses(teacher),
  PRIMARY KEY (student_id, teacher)
);
```

---

### Normal Forms at a Glance

| Form     | Rule in one line                      | Fixes                                              |
| -------- | ------------------------------------- | -------------------------------------------------- |
| **1NF**  | One value per cell, unique rows       | Lists in cells, duplicate rows                     |
| **2NF**  | 1NF + no partial dependencies         | Data tied to only part of a composite key          |
| **3NF**  | 2NF + no transitive dependencies      | Non-key columns depending on other non-key columns |
| **BCNF** | 3NF + every determinant is a superkey | Leftover edge-case anomalies                       |

### Bonus: When to Break the Rules (Denormalization)

- **What it is:** Intentionally _adding back_ some redundancy to make reads faster.
- **Analogy:** A restaurant keeps a "specials" board at the entrance even though the full menu has the same information. It is duplicated, but it saves everyone a trip to the menu.
- **Why it matters:** Reporting dashboards and read-heavy systems often skip expensive JOINs by storing a precomputed value. The trade-off is that **you** now have to keep the copies in sync.

> **Dev Tip:** Normalize first, **denormalize deliberately** later, and only when you have measured a real performance problem. Aim for **3NF** as your default.

---

## 2. SQL Injection

### What it is

**SQL injection** is a web security vulnerability where an attacker slips their own SQL code into your queries through user input (login forms, search bars, URL parameters). It happens when you build SQL by **string concatenation or interpolation** with raw user input.

### The Everyday Analogy

Imagine you take a customer's handwritten note and read it **word for word** to the chef. If the note says "one pizza, and also give me the keys to the safe", the chef cannot tell which part is the order and which part is a command. **Parameterized queries** are like putting the customer's words in a sealed envelope that the chef is only allowed to treat as _data_.

### Why it matters

Attackers can:

- **Bypass authentication** (log in without a valid password)
- **Steal data** (dump your users table)
- **Modify or delete records** (including whole tables)

It is one of the most common web attacks, and entirely preventable.

### Quick Example: The Attack

```js
// VULNERABLE: user input is glued straight into the SQL string
const query =
  "SELECT * FROM users WHERE username = '" +
  usernameInput +
  "' AND password = '" +
  passwordInput +
  "';";
```

An attacker types this into the username field:

```text
' OR '1'='1' --
```

The final query becomes:

```sql
SELECT * FROM users WHERE username = '' OR '1'='1' --' AND password = '...';
```

- `'1'='1'` is **always true**
- `--` **comments out** the rest of the line, including the password check

So the `WHERE` clause is effectively `username = '' OR TRUE`, which can return the first user in the table (often an admin) and log the attacker in.

---

### Defense 1: Parameterized Queries (the main fix)

Parameterized statements (also called **prepared statements**) keep the **SQL structure** separate from the **user data**, so the database never treats input as executable code.

```js
// Node.js (node-postgres): SAFE
const result = await pool.query("SELECT * FROM users WHERE username = $1", [
  usernameInput,
]);
```

```python
# Python (sqlite3): SAFE
cursor.execute("SELECT * FROM users WHERE username = ?", (username_input,))
```

> **Rule of thumb:** If you see `+` or `${}` or an f-string building a SQL query from user input, stop and parameterize it.

### Defense 2: Input Validation (secondary layer)

Useful everywhere, but **critical** for the parts of a query that cannot be parameterized, like **table names, column names, and sort order**. Whenever possible, hardcode those in your code. If a user can pick one, check it against an **allowlist**.

```js
const allowedSortColumns = ["name", "created_at", "price"];
const sortBy = allowedSortColumns.includes(req.query.sort)
  ? req.query.sort
  : "created_at"; // safe default

const sql = `SELECT * FROM products ORDER BY ${sortBy}`;
```

### Defense 3: Limit Database Permissions (damage control)

If an attack gets through anyway, **least privilege** limits the blast radius. Give each database account only the permissions it needs, and **never** give application accounts admin rights.

```sql
-- A read-only account for a reporting service
CREATE USER report_reader WITH PASSWORD 'use-a-strong-secret';
GRANT SELECT ON orders, customers TO report_reader;

-- Notice what is NOT granted: INSERT, UPDATE, DELETE, DROP
```

### Extra Habits Worth Building

- **Hash passwords** (bcrypt or argon2). Never store them in plain text.
- **Do not show raw database errors** to users. They leak table and column names.
- **ORMs are not magic.** Prisma, Sequelize, and others are safe by default, but raw query escape hatches (`$queryRawUnsafe`, `sequelize.query` with concatenation) bring the risk back.

> **Production Pitfall:** Escaping or "sanitizing" quotes by hand is fragile and easy to bypass, so **always use parameterized queries** and treat validation as a backup, not the primary defense.

---

## 3. The N+1 Problem

### What it is

The **N+1 problem** is a performance bottleneck where your app runs **1 query** to fetch a list of records, then **N more queries** (one per record) to fetch related data.

- **The 1:** the initial query for the list
- **The N:** one extra query for each row in that list

### The Everyday Analogy

**Grocery shopping.** The N+1 way is driving to the store, buying one item, driving home, then repeating the trip for every other item on your list. The efficient way is to bring the **whole list** and make **one trip**. The drive (network round trip) is the expensive part, not the shopping.

### Why it matters

- **Slow page loads:** Every query costs a network round trip, a database lookup, and a response.
- **It does not scale:** 50 orders means 51 queries, 5,000 orders means 5,001.
- **Database strain:** Many tiny queries add up to heavy load.
- **Sneaky:** Works fine in development with 5 rows, then crawls in production with 5,000.

> **Quick math:** If each query takes about 50 ms round trip, 51 queries is about **2.5 seconds**. One JOIN query is about **50 ms**.

### Quick Example: The Problem

```js
// The "1": get the orders
const orders = await db.query("SELECT * FROM orders LIMIT 50");

// The "N": one query PER order (50 more queries)
for (const order of orders) {
  const customerData = await getCustomerData(order.customer_id);
  // Process the customer's data...
}
// Total: 1 + 50 = 51 queries
```

### The Fix: Let SQL Do the Work

Use a **JOIN** to fetch orders and their customers in a single query:

```sql
SELECT
  o.order_id,
  o.product,
  o.quantity,
  c.customer_id,
  c.name    AS customer_name,
  c.email   AS customer_email,
  c.address AS customer_address
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id
LIMIT 50;
```

It looks more complex, but it is **1 query instead of 51**.

> **Note:** A common variation puts `LIMIT` inside an `IN (SELECT ...)` subquery. Some databases (MySQL, for example) do not allow that. Using `ORDER BY` with `LIMIT` on the outer query, as above, works everywhere and gives predictable results.

### Other Ways to Avoid N+1

**Batch with `IN`** (2 queries total, useful when a JOIN gets awkward):

```js
const orders = await db.query("SELECT * FROM orders LIMIT 50");
const ids = orders.map((o) => o.customer_id);

const customers = await db.query(
  "SELECT * FROM customers WHERE customer_id = ANY($1)",
  [ids],
);
// Match customers to orders in memory using a Map keyed by customer_id
```

**Eager loading with an ORM** (the ORM builds the efficient query for you):

```js
// Prisma: fetches orders AND their customers together
const orders = await prisma.order.findMany({
  take: 50,
  include: { customer: true },
});
```

### How to Spot It

- **Enable query logging** and look for the same query repeating with different IDs.
- **Count queries per request** in development. If the count grows with the number of rows, you have N+1.
- Be suspicious of any `await` inside a `for` loop that touches the database.

> **Dev Tip:** A database call inside a loop is a red flag. Ask "can I fetch all of this in one query?" before you write the loop.

---

## 4. Cheat Sheet

| Concept             | One-liner                          | Remember                               |
| ------------------- | ---------------------------------- | -------------------------------------- |
| **Normalization**   | Split tables to remove redundancy  | Aim for **3NF**                        |
| **1NF**             | Atomic values, unique rows         | No comma-separated cells               |
| **2NF**             | No partial dependencies            | Only matters for composite keys        |
| **3NF**             | No transitive dependencies         | Non-key columns depend only on the key |
| **BCNF**            | Every determinant is a superkey    | The strictest practical form           |
| **SQL Injection**   | Attacker input becomes SQL code    | Parameterize everything                |
| **Least privilege** | Minimal DB permissions per account | Never give app accounts admin          |
| **N+1**             | 1 list query + N detail queries    | Use JOIN, batching, or eager loading   |

---

## 5. Quick Check

Test yourself, then check the answers.

1. Why is storing `'082 111 1111, 071 222 2222'` in one cell a 1NF violation?
2. What is the difference between a superkey and a candidate key?
3. When can a table even _have_ a partial dependency?
4. In `order_id > customer_id > customer_city > city_postal_code`, which column causes the 3NF violation, and why?
5. Why is `"SELECT ... WHERE name = '" + input + "'"` dangerous, and what replaces it?
6. Your page loads 200 orders and runs 201 queries. What is this called, and name two ways to fix it.

<details>
<summary>Answers</summary>

1. A cell must hold **one atomic value**. A separate `phone_numbers` table fixes it.
2. A candidate key is a **minimal** superkey, meaning it has no unnecessary columns.
3. Only when the primary key is **composite** (multiple columns).
4. `city_postal_code`. It depends on `customer_city` (a non-key column), not directly on `order_id`.
5. User input can change the query's structure. Use **parameterized queries**.
6. The **N+1 problem**. Fix with a **JOIN**, **batching with `IN`**, or **ORM eager loading**.

</details>

---

## Final Tips

- **Normalize by default, denormalize on purpose.**
- **Never trust user input**, and never build SQL with string concatenation.
- **Log your queries in development.** N+1 problems are easy to catch when you can see them.
- **Practice:** Take a messy spreadsheet from a real project, push it through 1NF, 2NF, and 3NF, then write the `CREATE TABLE` statements yourself. That is where this finally sticks.
