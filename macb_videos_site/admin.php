<?php
// Conectar ao banco de dados
$conn = new mysqli('localhost', 'admin', 'b18073518B@123', 'macb_videos');
if ($conn->connect_error) {
    die('Erro na conexão: ' . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Salvar o link no banco de dados
    if (isset($_POST['link'])) {
        $link = $_POST['link'];
        $stmt = $conn->prepare("INSERT INTO videos (link) VALUES (?)");
        $stmt->bind_param("s", $link);
        $stmt->execute();
        $stmt->close();
    }
}
?>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel</title>
</head>
<body>
    <h1>Admin Panel</h1>
    <h2>Insira o link do vídeo</h2>
    <form action="admin.php" method="POST">
        <input type="text" name="link" required placeholder="Cole o link do vídeo">
        <button type="submit">Salvar Link</button>
    </form>
</body>
</html>

