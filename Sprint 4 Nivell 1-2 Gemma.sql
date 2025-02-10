---------------------------------
## NIVELL 1 ##
---------------------------------
-- Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules
-- de les quals puguis realitzar les següents consultes:
CREATE SCHEMA Sprint4;

USE Sprint4;

CREATE TABLE users (
	id INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR (50),
    Surname VARCHAR (50),
    Phone VARCHAR (15),
    Email VARCHAR (70),
    Birth_date VARCHAR (30),
    Country VARCHAR (20),
    City VARCHAR (30),
    Postal_Code VARCHAR (15),
    Address VARCHAR (100)
    );

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#He col·locat l'arxiu en aquesta ubicació després de mirar-ho amb "SHOW VARIABLES LIKE "secure_file_priv";"
#per evitar l'error 1290. Teoricament, alternativament, enlloc de moure'l, es podrien utilitzar els comandaments: 
#SHOW VARIABLES LIKE 'secure_file_priv';
#SHOW VARIABLES LIKE 'local_infile';
#SHOW VARIABLES LIKE 'basedir';
#SET GLOBAL local_infile = 1;
#SHOW GLOBAL VARIABLES LIKE 'local_infile';
#I a "Database--Manage Connections--Advanced" afegir "OPT_LOCAL_INFILE=1" per a poder agafar els documents de la ubicació que vulgui,
#pero a mi em dona error igualment

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM users;

CREATE TABLE companies (
	Company_id VARCHAR (10) PRIMARY KEY,
    Company_name VARCHAR (100),
    Phone VARCHAR (15),
    Email VARCHAR (70),
    Country VARCHAR (30),
    Website VARCHAR (100)
    );

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM companies;


CREATE TABLE credit_cards (
	id VARCHAR (10) PRIMARY KEY,
    User_id INT,
    Iban VARCHAR (40),
    Pan VARCHAR (20),
    Pin VARCHAR (10),
    CVV VARCHAR (3),
    Track1 VARCHAR (50),
    Track2 VARCHAR (50),
    Expiring_date VARCHAR (10)
    );

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

SELECT *
FROM credit_cards;


CREATE TABLE transactions (
	id VARCHAR (40) PRIMARY KEY,
    Card_id VARCHAR (10),
    Business_id VARCHAR (10),
    Timestamp TIMESTAMP,
    Amount DECIMAL (7,2),
    Declined TINYINT NOT NULL DEFAULT 0,
    Product_ids VARCHAR (20),
    User_id INT,
    Lat FLOAT (14,12),
    Longitude FLOAT (15,12),
    CONSTRAINT FKUserTrans FOREIGN KEY (User_id) REFERENCES users (id),
    CONSTRAINT FKCompTrans FOREIGN KEY (Business_id) REFERENCES companies (Company_id),
    CONSTRAINT FKCCTrans FOREIGN KEY (Card_id) REFERENCES credit_cards (id)
    );

LOAD DATA
INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT *
FROM transactions;


## Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
SELECT id AS "ID usuaris amb +30 transaccions", Name, Surname
FROM users
WHERE id IN (
	SELECT user_id
	FROM transactions
	GROUP BY user_id
    HAVING COUNT(id)>30);


## Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
SELECT iban AS "iban de Donec Ltd", round(avg(amount),2) AS "Mitjana de compres per CC"
FROM credit_cards AS cc
JOIN transactions AS tr
ON cc.id = tr.card_id
JOIN companies AS co
ON tr.Business_id = co.company_id
WHERE Company_name = "Donec Ltd" AND declined = 0
GROUP BY iban;

### Només hi ha 1 targeta amb 1 operació acceptada de Donec Ltd



---------------------------------
## NIVELL 2 ##
---------------------------------
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i
-- genera la següent consulta:
CREATE TABLE CCStatus (
SELECT Card_id, IF(SUM(Declined)=3,"Cancel·lada","Activa") AS Estat
FROM (
	SELECT Card_id, Declined,
		ROW_NUMBER () OVER (PARTITION BY Card_id ORDER BY Timestamp DESC) AS TransOrd
	FROM transactions) AS TransTime
WHERE TransOrd <= 3
GROUP BY Card_id);

#Com la nova taula no té PK ni està relacionada amb la resta de taules amb FK, fem un ALTER TABLE per afegir aquesta informació
ALTER TABLE CCStatus
ADD PRIMARY KEY (Card_id),
ADD CONSTRAINT FKStatusCC FOREIGN KEY (Card_id) REFERENCES credit_cards (id);

## Exercici 1
-- Quantes targetes estan actives?
SELECT COUNT(Card_id) AS "Número de targetes actives"
FROM CCStatus
WHERE Estat = "Activa";
