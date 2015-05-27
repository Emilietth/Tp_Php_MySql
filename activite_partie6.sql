-- 1)Sur la page d’accueil, on affiche le nombre de commentaires de chaque article. On veut éviter de calculer cela à chaque affichage de la page. Il faut donc stocker ce nombre quelque part, et automatiser sa mise à jour afin que l’information soit toujours exacte.

-- Ajout de la colonne nb_commentaires dans la table Article pour stocker le nombre de commentaires de chaque article
ALTER TABLE Article
ADD COLUMN nb_commentaires INT NOT NULL;

-- Mise à jour de la colonne nb_commentaires au nombre de commentaires présents pour chaque article
UPDATE Article a 
SET nb_commentaires = (SELECT COUNT(*) FROM Commentaire WHERE article_id = a.id);

-- Création du trigger after_insert_commentaire pour augmenter de 1 la colonne nb_commentaires de la table Article après chaque insertion dans la table Commentaire
DELIMITER |
CREATE TRIGGER after_insert_commentaire AFTER INSERT
ON Commentaire FOR EACH ROW
BEGIN
	UPDATE Article
	SET nb_commentaires = nb_commentaires + 1
	WHERE id = NEW.article_id;
END |
DELIMITER ;

-- 2)Chaque article doit contenir un résumé (ou extrait), qui sera affiché sur la page d’accueil. Mais certains auteurs oublient parfois d’en écrire un. Il faut donc s’arranger pour créer automatiquement un résumé en prenant les 150 premiers caractères de l’article, si l’auteur n’en a pas écrit.

-- Création du trigger before_insert_article pour mettre 150 premiers caractères du NEW.contenu dans NEW.resume avant chaque insertion dans la table Article si NEW.resume n'est pas renseignée (NULL)
DELIMITER |
CREATE TRIGGER before_insert_article BEFORE INSERT
ON Article FOR EACH ROW
BEGIN
	IF NEW.resume IS NULL
	THEN
		SET NEW.resume = LEFT(NEW.contenu,150);
	END IF;
END |
DELIMITER ;

-- 3)Enfin, les administrateurs du site veulent connaître quelques statistiques sur les utilisateurs enregistrés : le nombre d’articles écrits, la date du dernier article, le nombre de commentaires écrits et la date du dernier commentaire. Ces informations doivent être stockées pour ne pas devoir les recalculer chaque fois. Par contre, elles ne doivent pas nécessairement être à jour à tout moment. On doit disposer d’un outil pour faire les mises à jour à la demande.

-- Création de la vue matérialisée
CREATE TABLE VM_stat_utilisateurs (   
	id INT UNSIGNED,
	pseudo VARCHAR(100) NOT NULL,
	nb_articles INT UNSIGNED NOT NULL,
	date_dernier_article DATETIME,
	nb_commentaires INT UNSIGNED NOT NULL,
	date_dernier_commentaire DATETIME,
	PRIMARY KEY(id)
);

-- Création de la procédure stockée pour mettre à jour la vue matérialisée VM_stat_utilisateurs
DELIMITER |
CREATE PROCEDURE maj_vm_stat_utilisateurs()  
BEGIN
    DECLARE v_id INT;
	
	DECLARE fin BOOLEAN DEFAULT FALSE; 

    DECLARE curs_utilisateurs CURSOR
        FOR SELECT id FROM VM_stat_utilisateurs
        ORDER BY id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = TRUE;
	
	TRUNCATE TABLE VM_stat_utilisateurs; -- Vider la vue matérialisée
	
	INSERT INTO VM_stat_utilisateurs  -- Remplir la vue matérialisée
	SELECT u.id, u.pseudo, COUNT( DISTINCT a.id ), MAX( a.date_publication ), 0, NULL
	FROM Utilisateur u
	LEFT JOIN Article a ON u.id = a.auteur_id
	GROUP BY u.id, u.pseudo;
	
    OPEN curs_utilisateurs;  -- Ouverture du curseur
	
	WHILE NOT Fin DO
		FETCH curs_utilisateurs INTO v_id;  
		
		-- Pour chaque utilisateur enregistré, mettre à jour nb_commentaires et date_dernier_commentaire
		UPDATE VM_stat_utilisateurs  
		SET nb_commentaires = (SELECT COUNT(*) FROM Commentaire WHERE auteur_id = v_id),
			date_dernier_commentaire = (SELECT MAX(date_commentaire) FROM Commentaire WHERE auteur_id = v_id)		
		WHERE id = v_id;
	END WHILE;

    CLOSE curs_utilisateurs;     -- Fermeture du curseur
END|
DELIMITER ;

CALL maj_vm_stat_utilisateurs();










