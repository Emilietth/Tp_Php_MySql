<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8" />
        <title>Page protégée par mot de passe</title>
    </head>

    <body>
		<?php
			if (!isset($_POST['mot_de_passe']) OR $_POST['mot_de_passe'] != "kangourou")
			{
				if (!isset($_POST['mot_de_passe']))
				{
					echo "<p>Veuillez entrer le mot de passe pour obtenir les codes d'accès au serveur central de la NASA :</p>";
				}		
				elseif ($_POST['mot_de_passe'] != "kangourou")
				{
					echo "<p>Mot de passe incorrect ! Veuillez entrer de nouveau le mot de passe :</p>";				
				}
		?>
		
        <form action="formulaire.php" method="post">
            <p>
            <label for="mot_de_passe">Mot de passe :</label><input type="password" name="mot_de_passe" id="mot_de_passe" />
            <input type="submit" value="Valider" />
            </p>
        </form>
        <p>Cette page est réservée au personnel de la NASA. Si vous ne travaillez pas à la NASA, inutile d'insister vous ne trouverez jamais le mot de passe ! ;-)</p>
		
		<?php
			}
			else		
			{
		?>
				<h1>Voici le code d'accès : </h1>
				<p><strong>GDFTYF-UIGU9B6-JI86HTG89</strong></p>
		<?php
			}
		?>
	</body>
</html>