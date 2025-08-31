#!/bin/bash

# Drupal 10.3 + CiviCRM 6.5.5 Installation Script

set -e

echo "🚀 Setting up Drupal 10.3 + CiviCRM 6.5.5..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# CiviCRM will be installed via Composer during container startup
echo "✅ CiviCRM will be installed via Composer"

# Create data directories
echo "📁 Creating data directories..."
mkdir -p drupal-data
mkdir -p mysql-data

# Build and start containers
echo "🔨 Building and starting containers..."
docker-compose up --build -d

echo "⏳ Waiting for containers to be ready..."
sleep 30

echo "🔧 Installing Drupal and CiviCRM..."
echo "Setting up Drupal settings files..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal/web/sites/default && cp /var/www/html/drupal/web/core/assets/scaffold/files/default.settings.php . && cp default.settings.php settings.php && chmod 666 settings.php"

echo "Installing Drupal..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush site:install standard --db-url=mysql://drupal_user:drupal_user_password@database:3306/drupal10 --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name='Drupal 10 + CiviCRM' --yes --root=/var/www/html/drupal/web"

echo "Installing CiviCRM..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && composer config extra.enable-patching true && composer config allow-plugins.cweagans/composer-patches true && composer config allow-plugins.civicrm/civicrm-asset-plugin true && composer config allow-plugins.civicrm/composer-downloads-plugin true && composer config allow-plugins.civicrm/composer-compile-plugin true && composer config extra.compile-mode all && composer require civicrm/civicrm-{core,packages,drupal-8} --no-interaction && composer require civicrm/cli-tools --no-interaction"
docker-compose exec -T drupal bash -c "curl -Ls https://download.civicrm.org/cv/cv.phar -o /usr/local/bin/cv && chmod +x /usr/local/bin/cv"
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush en civicrm -y --root=/var/www/html/drupal/web -l http://localhost:8080"

echo "🔧 Installing CiviCRM core..."
docker-compose exec -T drupal cv core:install -f --cms-base-url='http://localhost:8080/' --db='mysql://drupal_user:drupal_user_password@database:3306/drupal10' --src-path='/var/www/html/drupal/vendor/civicrm/civicrm-core'

echo "🔧 Installing CiviCRM Entity module..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && composer require drupal/civicrm_entity:^4.0 --no-interaction"

echo "🔧 Clearing caches after CiviCRM core installation..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush cr --root=/var/www/html/drupal/web"

echo "🔧 Enabling CiviCRM Entity module..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush en civicrm_entity -y --root=/var/www/html/drupal/web"

echo "🔧 Final cache clear to ensure all modules are properly loaded..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush cr --root=/var/www/html/drupal/web"

echo "🔧 Setting up CiviCRM navigation menu..."
docker-compose exec -T drupal cv api3 Navigation.create label="🛠️ Admin Console" url="civicrm/admin?reset=1" weight=100 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="⚙️ System Settings" url="civicrm/admin/setting?reset=1" weight=101 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="👥 Users & Permissions" url="civicrm/admin/access?reset=1" weight=102 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="🔌 Extensions" url="civicrm/admin/extensions?reset=1" weight=103 is_active=1

echo "🔧 Creating collapsible CiviCRM admin block..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush eval \"\\Drupal::entityTypeManager()->getStorage('block_content')->create(['type' => 'basic', 'info' => 'CiviCRM Admin Links (Collapsible)', 'body' => ['value' => '<div class=\\\"civicrm-admin-collapsible\\\"><button class=\\\"civicrm-toggle-btn\\\" onclick=\\\"toggleCiviCRM()\\\">🛠️ CiviCRM Admin Links ▼</button><div class=\\\"civicrm-menu-content\\\" style=\\\"display: none;\\\"><ul><li><a href=\\\"/civicrm/admin?reset=1\\\">🛠️ CiviCRM Admin</a></li><li><a href=\\\"/civicrm/admin/component?reset=1\\\">📧 Headers & Messages</a></li><li><a href=\\\"/civicrm/admin/paymentProcessor?reset=1\\\">💳 Payment Processors</a></li><li><a href=\\\"/civicrm/admin/extensions?reset=1\\\">🔌 Extensions</a></li></ul></div></div><script>function toggleCiviCRM() { var content = document.querySelector(\\\".civicrm-menu-content\\\"); var btn = document.querySelector(\\\".civicrm-toggle-btn\\\"); if (content.style.display === \\\"none\\\") { content.style.display = \\\"block\\\"; btn.innerHTML = \\\"🛠️ CiviCRM Admin Links ▲\\\"; } else { content.style.display = \\\"none\\\"; btn.innerHTML = \\\"🛠️ CiviCRM Admin Links ▼\\\"; } }</script>', 'format' => 'full_html']])->save();\" --root=/var/www/html/drupal/web"
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush config:set block.block.civicrmadminlinkscollapsible status 1 --root=/var/www/html/drupal/web"
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush config:set block.block.civicrmadminlinkscollapsible region content --root=/var/www/html/drupal/web"

echo "🔧 Note: CiviCRM admin links are now in a collapsible block in the content area"

echo "🔧 Enabling main menu block..."
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush config:set block.block.olivero_main_menu status 1 --root=/var/www/html/drupal/web"
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush config:set block.block.olivero_main_menu region primary_menu --root=/var/www/html/drupal/web"

echo "✅ CiviCRM installation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to http://localhost:8080 and log in as admin (admin/admin)"
echo "2. Navigate to http://localhost:8080/civicrm to access CiviCRM"
echo "3. Configure CiviCRM settings via the web interface:"
echo "   - Organization settings: /civicrm/admin/domain"
echo "   - Debug mode: /civicrm/admin/setting/debug"
echo "   - Mail settings: /civicrm/admin/mailSettings"
echo "4. Explore CiviCRM Entity integration:"
echo "   - Create Views of CiviCRM data: /admin/structure/views"
echo "   - Add CiviCRM fields to content types: /admin/structure/types"
echo "   - Access CiviCRM entities via Drupal's Entity API"
echo "5. Navigation menu:"
echo "   - Custom admin links are available in the CiviCRM navigation menu"
echo "   - See navigation_menu.md for detailed management instructions"
echo ""
echo "🔧 Optional: Run 'docker-compose exec drupal cv api System.check' to check system status"

echo "✅ Setup complete!"
echo ""
echo "🌐 Access your application at: http://localhost:8080"
echo ""
echo "📋 Installation complete!"
echo "🌐 Access your site at: http://localhost:8080"
echo "👤 Admin login: admin / admin"
echo ""
echo "Database credentials:"
echo "   - Host: database"
echo "   - Database: drupal10"
echo "   - Username: drupal_user"
echo "   - Password: drupal_user_password"
echo ""
echo "🔧 To stop the containers: docker-compose down"
echo "🔧 To view logs: docker-compose logs -f"
