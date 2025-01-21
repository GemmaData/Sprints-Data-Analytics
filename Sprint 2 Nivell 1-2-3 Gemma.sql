## NIVELL 1 ##

# Exercici 1
-- A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules.
-- Mostra les característiques principals de l'esquema creat i explica les diferents taules i variables que existeixen.
-- Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

       -#- Veure resposta en el document apart -#-

# Exercici 2
-- Utilitzant JOIN realitzaràs les següents consultes:
 --  Llistat dels països que estan fent compres.
SELECT DISTINCT country AS "Paisos amb compres"
FROM company
RIGHT JOIN transaction				#RIGHT JOIN Per a tenir en compte les empreses que tenen transaccions realitzades
ON company.id=transaction.company_id;

 -- Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) AS "Num de paisos amb compres"
FROM company
RIGHT JOIN transaction
ON company.id=transaction.company_id;

 -- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name AS "Companyia amb major mitjana de vendes", round(avg(amount),2) AS "Mitjana vendes"
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE declined=0				#Per a tenir en compte les vendes realitzades però no les transaccions que estan declinades
GROUP BY company_name
ORDER BY avg(amount) DESC
LIMIT 1;


# Exercici 3
-- Utilitzant només subconsultes (sense utilitzar JOIN):
 -- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
	FROM company
	WHERE country = "Germany");

 -- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT DISTINCT id, company_name
FROM company
WHERE id IN (
	SELECT company_id
    FROM transaction
    WHERE amount > (
		SELECT avg(amount)
		FROM transaction));

 -- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT DISTINCT id, company_name
FROM company
WHERE id NOT IN (
	SELECT company_id
    FROM transaction
    WHERE company.id=transaction.company_id);
    
    
## NIVELL 2 ##

# Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT DATE(timestamp) AS Data, SUM(amount) AS Ingressos      #També es pot posar "CAST(timestamp AS DATE) AS Data" per a passar a format Data
FROM transaction
WHERE declined = 0
GROUP BY Data
ORDER BY Ingressos DESC
LIMIT 5;


# Exercici 2
-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, round(avg(amount),2) AS "Mitjana de vendes"
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE declined = 0
GROUP BY country
ORDER BY avg(amount) DESC;


# Exercici 3
-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute".
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
 -- Mostra el llistat aplicant JOIN i subconsultes.
 SELECT transaction.*
 FROM transaction
 JOIN company
 ON transaction.company_id = company.id
 WHERE company_name != "Non Institute" AND country = (
	SELECT country
    FROM company
    WHERE company_name = "Non Institute");

 -- Mostra el llistat aplicant solament subconsultes.
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT id
    FROM company
    WHERE company_name != "Non Institute" AND country = (
		SELECT country
		FROM company
		WHERE company_name = "Non Institute"));



## NIVELL 3 ##

# Exercici 1
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.
SELECT company_name, phone, country, DATE(timestamp) AS Data, amount      #Si volem veure la data amb hora escriurem només "timestamp AS Data" per a la 4a columna
FROM company
JOIN transaction
ON company.id = transaction.company_id
WHERE (amount BETWEEN 100 AND 200) AND DATE(timestamp) IN ("20210429", "20210720", "20220313")
ORDER BY amount DESC;


# Exercici 2
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen
-- la informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol
-- un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
SELECT company_name, IF(COUNT(transaction.id)>4, "Més de 4", "Menys de 4") AS "Nombre de transaccions"
FROM company
JOIN transaction
ON company.id = transaction.company_id
GROUP BY company_name;