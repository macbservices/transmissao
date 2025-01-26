#!/bin/bash

set -e

echo "Iniciando a instalação do site Transmissao..."

# Atualizando pacotes
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalando dependências essenciais
echo "Instalando dependências..."
sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server unzip curl wget

# Configurando o Apache
echo "Configurando o Apache..."
sudo systemctl enable apache2
sudo systemctl start apache2

# Instalando e configurando o MySQL
echo "Configurando o MySQL..."
sudo systemctl enable mysql
sudo systemctl start mysql

DB_NAME="transmissao_db"
DB_USER="admin"
DB_PASS="b18073518B@123"

# Configurando o banco de dados
echo "Criando banco de dados e usuário..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configurando o PHP
echo "Configurando o PHP..."
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php/7.4/apache2/php.ini
sudo systemctl restart apache2

# Baixando os arquivos do site
echo "Baixando os arquivos do site do GitHub..."
cd /var/www/html
sudo rm -rf *
sudo curl -sSL https://github.com/macbservices/transmissao/archive/refs/heads/main.zip -o site.zip
sudo unzip site.zip
sudo mv transmissao-main/* .
sudo rm -rf transmissao-main site.zip

# Configurando permissões do Apache
echo "Ajustando permissões..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Configurando o VirtualHost do Apache
echo "Configurando o VirtualHost do Apache..."
VHOST="
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
"

echo "$VHOST" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
sudo systemctl restart apache2

# Instalando Certbot para SSL (opcional)
read -p "Deseja configurar o SSL com Certbot? (s/n): " configure_ssl
if [[ "$configure_ssl" == "s" || "$configure_ssl" == "S" ]]; then
    echo "Instalando Certbot..."
    sudo apt install -y certbot python3-certbot-apache
    read -p "Informe o domínio para configurar o SSL (ex: livefut.macbvendas.com.br): " domain
    if [ -n "$domain" ]; then
        sudo certbot --apache -d "$domain" -d "www.$domain"
        sudo systemctl reload apache2
        echo "SSL configurado com sucesso!"
    else
        echo "Domínio não informado. Pulando configuração de SSL..."
    fi
fi

# Conclusão
echo "Instalação concluída com sucesso!"
echo "O site está disponível em http://$(curl -s ifconfig.me)"
