<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Page protégée par mot de passe</title>
    </head>

    <body>
        <form action="formulaire.php" method="post">
            <p>
            <label for="mot_de_passe">Mot de passe :</label><input type="password" name="mot_de_passe" id="mot_de_passe" />
            <input type="submit" value="Valider" />
            </p>
        </form>
        <p>Cette page est réservée au personnel de la NASA. Si vous ne travaillez pas à la NASA, inutile d'insister vous ne trouverez jamais le mot de passe ! ;-)</p>
	</body>
</html>