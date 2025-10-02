# Restaurant_Database_Project_By_Sql
🍽️ Restaurant Database Management System
📌 Overview

This project is a Restaurant Database built using SQL Server.
It covers the full restaurant management cycle including:

Departments, job titles, and employees.

Customers, reservations, and tables.

Orders, menu, and categories.

Inventory, suppliers, and purchases.

Promotions and discounts.

Triggers for automated order calculations.

📂 Project Structure
Restaurant-DB/
│
├── README.md
│
├── schema/          # Database schema (CREATE TABLE scripts)
├── data/            # Seed data (INSERT INTO scripts)
├── triggers/        # Database triggers (CREATE TRIGGER scripts)
├── procedures/      # Stored procedures (optional)
├── views/           # Views (optional)
├── diagrams/        # ERD and database diagrams
└── utils/           # Utility scripts (optional)

▶️ How to Run

Open SQL Server Management Studio (SSMS).

Run all scripts inside schema/ in order (01, 02, …).

Run scripts inside data/ to populate seed data.

Run scripts inside triggers/.

(Optional) Run procedures/ and views/ if available.

🗂️ Folder Details

schema/ → All CREATE TABLE scripts.

data/ → All INSERT INTO seed data (employees, customers, menu, etc.).

triggers/ → Business logic triggers (e.g., order calculations).

procedures/ → Stored procedures for reports and workflows.

views/ → Views for simplified queries.

diagrams/ → ERD (Entity Relationship Diagram) and database relationships.

utils/ → Additional helper scripts (if needed).

✨ Features

Fully modular structure (schema, data, triggers separated).

Ready-to-use with seed data included.

Includes business rules via triggers.

Scalable and extendable for a complete restaurant management system.
