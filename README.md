# Drupal 10.3 + CiviCRM 6.5.5 Docker Setup

A complete Docker-based development environment for Drupal 10.3 and CiviCRM 6.5.5 with full automation and integration.

## 🚀 Features

- **Drupal 10.3.0** - Latest stable Drupal version
- **CiviCRM 6.5.5** - Full-featured CRM system
- **CiviCRM Entity Module 4.0.0** - Drupal-CiviCRM integration
- **Docker & Docker Compose** - Containerized development environment
- **MySQL 8.0** - Database backend
- **PHP 8.3** - Modern PHP runtime
- **Apache 2.4** - Web server
- **Automated Installation** - One-command setup
- **Custom Navigation Menu** - Quick admin access
- **Greenwich Theme** - Modern CiviCRM interface

## 📋 Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Git
- At least 4GB RAM available for Docker
- Port 8080 available on your system

## 🛠️ Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd drupal10civicrm6
```

### 2. Run the Installation

```bash
./install.sh
```

This single command will:
- Build the Docker containers
- Install Drupal 10.3
- Install CiviCRM 6.5.5
- Install CiviCRM Entity module
- Configure all necessary settings
- Set up the database

### 3. Access Your Site

- **Main Site**: http://localhost:8080
- **Admin Login**: admin / admin
- **CiviCRM**: http://localhost:8080/civicrm (while logged in)

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Drupal 10.3   │    │  CiviCRM 6.5.5  │    │   MySQL 8.0     │
│                 │    │                 │    │                 │
│ - Web Interface │◄──►│ - CRM System    │◄──►│ - Database      │
│ - Content Mgmt  │    │ - Contact Mgmt  │    │ - Data Storage  │
│ - Views         │    │ - Contributions │    │ - User Data     │
│ - Entity API    │    │ - Events        │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
         CiviCRM Entity Module
         (Drupal-CiviCRM Bridge)
```

## 📁 Project Structure

```
drupal10civicrm6/
├── docker-compose.yml          # Docker services configuration
├── Dockerfile                  # Drupal container definition
├── install.sh                  # Automated installation script
├── README.md                   # This documentation
├── drupal-data/                # Drupal files (mounted volume)
├── mysql-data/                 # MySQL data (mounted volume)
└── civicrm-6.5.0-drupal.tar.gz # CiviCRM source files
```

## 🔧 Configuration

### Database Settings

- **Host**: database
- **Database**: drupal10
- **Username**: drupal_user
- **Password**: drupal_user_password
- **Port**: 3306

### CiviCRM Settings

- **Site URL**: http://localhost:8080
- **Theme**: Greenwich (modern interface)
- **Debug Mode**: Enabled (for development)

## 🎯 CiviCRM Entity Integration

### Navigation Menu Setup

The installation automatically creates a custom CiviCRM navigation menu with quick access to administrative functions:

- **🛠️ Admin Settings** - Main CiviCRM administration panel
- **⚙️ System Settings** - Direct access to system configuration  
- **👥 User Management** - User and permission management

For detailed navigation menu management, see [navigation_menu.md](navigation_menu.md).

## 🧭 Navigation Menu Management

The CiviCRM Entity module provides powerful integration between Drupal and CiviCRM:

### Features
- **Views Integration**: Create Drupal Views of CiviCRM data
- **Entity API**: Access CiviCRM data via Drupal's Entity API
- **Field System**: Add CiviCRM fields to Drupal content types
- **Content Management**: Create Drupal content types referencing CiviCRM entities
- **Search Integration**: Include CiviCRM data in Drupal search

### Available CiviCRM Entities
- Contacts
- Contributions
- Events
- Memberships
- Activities
- Cases
- And more...

### Usage Examples

#### Create a View of CiviCRM Contacts
1. Go to `/admin/structure/views`
2. Add new view
3. Select "CiviCRM Contact" as the base table
4. Configure fields, filters, and display options

#### Add CiviCRM Fields to Content Types
1. Go to `/admin/structure/types`
2. Edit a content type
3. Add fields
4. Select CiviCRM field types

## 🛠️ Management Commands

### Start/Stop Services

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f
```

### Database Operations

```bash
# Access MySQL
docker-compose exec database mysql -u drupal_user -p drupal10

# Backup database
docker-compose exec database mysqldump -u drupal_user -p drupal10 > backup.sql

# Restore database
docker-compose exec -T database mysql -u drupal_user -p drupal10 < backup.sql
```

### Drupal Commands

```bash
# Clear Drupal cache
docker-compose exec drupal vendor/bin/drush cr --root=/var/www/html/drupal/web

# Update Drupal
docker-compose exec drupal vendor/bin/drush updb --root=/var/www/html/drupal/web

# Export configuration
docker-compose exec drupal vendor/bin/drush cex --root=/var/www/html/drupal/web
```

### CiviCRM Commands

```bash
# Check CiviCRM system status
docker-compose exec drupal cv api System.check

# Clear CiviCRM cache
docker-compose exec drupal cv flush

# Run CiviCRM cron
docker-compose exec drupal cv api Job.execute
```

## 🔍 Troubleshooting

### Common Issues

#### Port 8080 Already in Use
```bash
# Check what's using the port
lsof -i :8080

# Kill the process or change the port in docker-compose.yml
```

#### Database Connection Issues
```bash
# Check if MySQL is running
docker-compose ps

# Restart the database service
docker-compose restart database
```

#### CiviCRM Not Loading
```bash
# Check CiviCRM status
docker-compose exec drupal cv api System.check

# Clear all caches
docker-compose exec drupal vendor/bin/drush cr --root=/var/www/html/drupal/web
docker-compose exec drupal cv flush
```

#### Permission Issues
```bash
# Fix file permissions
docker-compose exec drupal chown -R www-data:www-data /var/www/html/drupal/web/sites/default/files
```

### Reset Everything

```bash
# Complete reset (WARNING: This will delete all data)
docker-compose down
rm -rf drupal-data mysql-data
./install.sh
```

## 🔒 Security Considerations

### Development Environment
- Debug mode is enabled for development
- Default admin credentials (admin/admin)
- No SSL/TLS encryption
- Exposed database port

### Production Deployment
Before deploying to production:

1. **Disable Debug Mode**
   - Go to `/civicrm/admin/setting/debug`
   - Set debug_enabled to 0

2. **Change Default Passwords**
   - Update admin password
   - Change database passwords
   - Use strong, unique passwords

3. **Enable SSL/TLS**
   - Configure HTTPS
   - Update site URLs to use HTTPS

4. **Configure Mail Settings**
   - Set up proper email configuration
   - Configure bounce handling

5. **Set Up Cron Jobs**
   - Configure CiviCRM cron jobs
   - Set up Drupal cron

## 📚 Additional Resources

### Documentation
- [Drupal 10 Documentation](https://www.drupal.org/docs/10)
- [CiviCRM Documentation](https://docs.civicrm.org/)
- [CiviCRM Entity Module](https://www.drupal.org/project/civicrm_entity)

### Community
- [Drupal Community](https://www.drupal.org/community)
- [CiviCRM Community](https://civicrm.org/community)

### Support
- [Drupal Support](https://www.drupal.org/support)
- [CiviCRM Support](https://civicrm.org/support)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the GPL v2 or later - see the LICENSE file for details.

## 🙏 Acknowledgments

- Drupal community for the excellent CMS
- CiviCRM community for the powerful CRM
- Docker team for containerization technology
- All contributors to the CiviCRM Entity module

---

**Note**: This is a development environment. For production use, please follow security best practices and configure appropriate security measures.
