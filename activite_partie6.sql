-- 1)Sur la page d’accueil, on affiche le nombre de commentaires de chaque article. On veut éviter de calculer cela à chaque affichage de la page. Il faut donc stocker ce nombre quelque part, et automatiser sa mise à jour afin que l’information soit toujours exacte.

-- Ajout de la colonne nb_commentaires dans la table Article pour stocker le nombre de commentaires de chaque article
ALTER TABLE Article
ADD COLUMN nb_commentaires INT NOT NULL DEFAULT 0;

-- Mise à jour de la colonne nb_commentaires au nombre de commentaires présents pour chaque article
UPDATE Article a 
SET nb_commentaires = (SELECT COUNT(*) FROM Commentaire WHERE article_id = a.id);

-- Création du trigger after_insert_commentaire pour augmenter de 1 la colonne nb_commentaires de la table Article après chaque insertion dans la table Commentaire
DELIMITER |
CREATE TRIGGER after_insert_commentaire AFTER INSERT
ON Commentaire FOR EACH ROW
UPDATE Article SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.article_id|

CREATE TRIGGER after_delete_commentaire AFTER DELETE
ON Commentaire FOR EACH ROW
UPDATE Article SET nb_commentaires = nb_commentaires - 1 WHERE id = OLD.article_id|

CREATE TRIGGER after_update_commentaire AFTER UPDATE
ON Commentaire FOR EACH ROW
BEGIN
	IF NEW.article_id <> OLD.article_id THEN
		UPDATE Article SET nb_commentaires = nb_commentaires - 1 WHERE id = OLD.article_id;
		UPDATE Article SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.article_id;
	END IF;
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
CREATE TABLE VM_stat_utilisateurs
SELECT u.id, u.pseudo, COUNT(DISTINCT a.id) AS nb_articles, MAX(a.date_publication) AS dernier_article, COUNT(DISTINCT c.id) AS nb_commentaires, MAX(c.date_commentaire) AS dernier_commentaire
FROM Utilisateur AS u
LEFT JOIN Article AS a ON a.auteur_id = u.id
LEFT JOIN Commentaire AS c ON c.auteur_id = u.id
GROUP BY u.id, u.pseudo;

-- Création de la procédure stockée pour mettre à jour la vue matérialisée VM_stat_utilisateurs
DELIMITER |
CREATE PROCEDURE maj_vm_stat_utilisateurs()  
BEGIN
    TRUNCATE VM_stat_utilisateurs;

    INSERT INTO VM_stat_utilisateurs
    SELECT u.id, u.pseudo, COUNT(DISTINCT a.id) AS nb_articles, MAX(a.date_publication) AS dernier_article, COUNT(DISTINCT c.id) AS nb_commentaires, MAX(c.date_commentaire) AS dernier_commentaire
	FROM Utilisateur AS u
	LEFT JOIN Article AS a ON a.auteur_id = u.id
	LEFT JOIN Commentaire AS c ON c.auteur_id = u.id
	GROUP BY u.id, u.pseudo;
END |
DELIMITER ;











