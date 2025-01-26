#!/bin/bash

# Atualizar pacotes e instalar dependências
echo "Atualizando pacotes e instalando dependências..."
sudo apt update -y
sudo apt upgrade -y
sudo apt install apache2 unzip curl php php-mysql libapache2-mod-php -y

# Configurar o Apache
echo "Configurando Apache..."
sudo systemctl enable apache2
sudo systemctl start apache2

# Baixar e descompactar os arquivos do repositório
echo "Baixando arquivos do site..."
cd /tmp
curl -L -o site.tar.gz https://github.com/macbservices/transmissao/archive/refs/heads/main.tar.gz

# Extrair arquivos no diretório temporário
echo "Descompactando arquivos..."
sudo tar -xvf site.tar.gz -C /tmp/
cd /tmp/transmissao-main/

# Mover os arquivos diretamente para /var/www/html
echo "Movendo arquivos para o diretório do Apache..."
sudo rm -rf /var/www/html/*  # Remove arquivos existentes no diretório
sudo mv * /var/www/html/

# Ajustar permissões
echo "Ajustando permissões..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Configurar o banco de dados
echo "Configurando banco de dados..."
sudo mysql -u root -p -e "
DROP DATABASE IF EXISTS site_transmissao;
CREATE DATABASE site_transmissao;
CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'b18073518B@123';
GRANT ALL PRIVILEGES ON site_transmissao.* TO 'admin'@'localhost';
FLUSH PRIVILEGES;"

# Importar o banco de dados
if [ -f /var/www/html/site_transmissao.sql ]; then
  echo "Importando o banco de dados..."
  sudo mysql -u admin -pb18073518B@123 site_transmissao < /var/www/html/site_transmissao.sql
  sudo rm /var/www/html/site_transmissao.sql  # Remove o arquivo após a importação
else
  echo "Arquivo site_transmissao.sql não encontrado. Certifique-se de adicioná-lo ao repositório."
fi

# Reiniciar o Apache
echo "Reiniciando Apache..."
sudo systemctl restart apache2

echo "Instalação concluída! Acesse o site no navegador."
