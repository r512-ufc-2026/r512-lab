<?php
// Application de galerie volontairement simplifiee.
// Le formulaire d'upload ne filtre pas l'extension des fichiers,
// ce qui constitue la vulnerabilite exploitee dans le scenario.
$page = $_GET['page'] ?? 'list';
echo "<h1>Galerie Photo</h1>";
if ($page === 'upload') {
    echo '<form method="post" action="/gallery.php?page=upload" enctype="multipart/form-data">';
    echo '<input type="file" name="photo"><button type="submit">Envoyer</button></form>';
} else {
    echo "<p>Aucune photo pour le moment.</p>";
}
