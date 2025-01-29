## NIVELL 1 ##

-- Exercici 1
-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit.
-- La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company").
-- Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR (255) NOT NULL,
    iban VARCHAR (255) NULL,
    pan VARCHAR (255) NULL,
    pin INT NULL,
    cvv INT NULL,
    expiring_date DATE NULL,
    PRIMARY KEY (id)
    );

SELECT *
FROM credit_card;

LOAD DATA
INFILE "C:\Users\alexb\Desktop\Gemma\IT Academy\Data Analytics\SQL\datos_introducir_credit.sql"
INTO TABLE credit_card;

