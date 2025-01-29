---------------------------------
## NIVELL 1 ##
---------------------------------
## Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.

CREATE TABLE credit_card (
	id VARCHAR (15) PRIMARY KEY,
    iban VARCHAR (100) NULL,
    pan VARCHAR (100) NULL,
    pin INT NULL,
    cvv INT NULL,
    expiring_date VARCHAR (100) NULL
    );

ALTER TABLE transaction
ADD CONSTRAINT FK_CCTransaction FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

SELECT *
FROM credit_card;

## Exercici 2
-- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938.
-- La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card AS cc
SET iban = "R323456312213576817699999"
WHERE cc.id = "CcU-2938";

#Per mostrar el canvi:
SELECT *
FROM credit_card
WHERE id="CcU-2938";

## Exercici 3
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:
  #Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
  #credit_card_id	CcU-9999
  #company_id	b-9999
  #user_id	9999
  #lat	829.999
  #longitude	-117.999
  #amount	111.11
  #declined	0

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99", "CcU-9998", "b-9999", "9999", "829.999", "-117.999", "111.11", "0");

#Tambien podriem haver ponsat:
#INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined)
#VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99", "CcU-9998", "b-9999", "9999", "829.999", "-117.999", current_timestamp, "111.11", "0");
#Així ens posaria la información actual en el camp "timestamp"

SELECT *
FROM transaction;


## Exercici 4
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card
DROP COLUMN pan;

DESCRIBE credit_card;


---------------------------------
## NIVELL 2 ##
---------------------------------
## Exercici 1
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

#Per comprovar que ja no està:
SELECT *
FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

## Exercici 2
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives.
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions.
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació:
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia.
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT company_name, phone, co.country, round(avg(amount),2) AS Mitjana_de_compres
FROM company AS co
JOIN transaction AS tr
ON co.id = tr.company_id
WHERE declined = 0
GROUP BY 1, 2, 3;

SELECT *
FROM VistaMarketing
ORDER BY Mitjana_de_compres DESC;


## Exercici 3
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT *
FROM VistaMarketing
WHERE country = "Germany";


------------------------------------
## NIVELL 3 ##
------------------------------------
## Exercici 1
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de
-- dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama: (veure pdf)

#1) Treure la columna "website" de Company
ALTER TABLE company
DROP COLUMN website;

#2) Canviar el tipus de dades a la columna "pin" de Credit_card
ALTER TABLE credit_card
CHANGE pin pin VARCHAR(4);

#3) Afegir la columna "fecha_actual" a Credit_card
ALTER TABLE credit_card
ADD COLUMN fecha_actual date;

#4) Canviar el nom de la columna "email" a "personal_email" a la taula User
ALTER TABLE user
CHANGE email personal_email varchar(150);

#5) Corregir la Foreing Key que hi ha a "id" de user, que es Primary Key en aquesta taula i hauria de ser FK a transaction.
#Per a això miro com es diu aquesta relació i l'elimino. Després he d'afegir el user 9999, per llavors poder crear una relació
#nova amb PK a "id" de User i la FK a "user_id" a Transaction
ALTER TABLE user
DROP FOREIGN KEY user_ibfk_1;

INSERT INTO user (id)
VALUES ("9999");
#O també es pot fer:
INSERT INTO user
VALUES ("9999", null, null, null, null, null, null, null, null, null);

ALTER TABLE transaction
ADD CONSTRAINT FK_TransUser FOREIGN KEY (user_id) REFERENCES user(id);

#6) Canvio el nom de la taula User a Data_user
RENAME TABLE user TO data_user;


# Exercici 2
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
  # ID de la transacció
  # Nom de l'usuari/ària
  # Cognom de l'usuari/ària
  # IBAN de la targeta de crèdit usada.
  # Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.
CREATE VIEW InformeTecnico AS
SELECT tr.id AS "ID de la transacció", du.name AS "Nom usuari", du.surname AS "Cognom usuari", cc.iban, co.company_name AS "Nom de la companyia de la transacció realitzada"
FROM transaction AS tr
JOIN data_user AS du
ON tr.user_id = du.id
JOIN credit_card AS cc
ON tr.credit_card_id = cc.id
JOIN company AS co
ON tr.company_id = co.id;

SELECT *
FROM InformeTecnico
ORDER BY 1 DESC;
