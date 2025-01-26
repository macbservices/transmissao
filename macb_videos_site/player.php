<?php
// Conectar ao banco de dados
$conn = new mysqli('localhost', 'admin', 'b18073518B@123', 'macb_videos');
if ($conn->connect_error) {
    die('Erro na conexão: ' . $conn->connect_error);
}

// Pegar o link do vídeo mais recente do banco de dados
$result = $conn->query("SELECT link FROM videos ORDER BY created_at DESC LIMIT 1");
if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $link = $row['link'];
} else {
    $link = '';
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Player</title>
</head>
<body>
    <h1>Player de Vídeo</h1>
    <?php if ($link): ?>
        <iframe src="<?= htmlspecialchars($link) ?>" width="640" height="360" frameborder="0" allowfullscreen></iframe>
    <?php else: ?>
        <p>Não há vídeo para exibir.</p>
    <?php endif; ?>
</body>
</html>
