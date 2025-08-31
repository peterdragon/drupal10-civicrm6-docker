# CiviCRM Navigation Menu Management

This document covers how to set up, customize, and manage the CiviCRM navigation menu for quick access to administrative functions.

## 📋 Overview

The CiviCRM navigation menu provides quick access to various administrative functions and can be customized to include frequently used links. This setup uses a dual approach:

1. **CiviCRM Navigation Menu Items** - Added to CiviCRM's internal navigation system
2. **Drupal Custom Block** - A custom block with CiviCRM admin links displayed in the header region on both Drupal and CiviCRM pages

The custom block approach ensures the admin links are always visible, regardless of CiviCRM theme or navigation configuration issues.

## 🚀 Installation

The navigation menu items and custom block are automatically created during the installation process via the `install.sh` script.

### Default Navigation Items Created

1. **🛠️ Admin Settings**
   - **URL**: `/civicrm/admin?reset=1`
   - **Weight**: 100
   - **Description**: Main CiviCRM administration panel

2. **⚙️ System Settings**
   - **URL**: `/civicrm/admin/setting?reset=1`
   - **Weight**: 101
   - **Description**: Direct access to system configuration

3. **👥 User Management**
   - **URL**: `/civicrm/admin/user?reset=1`
   - **Weight**: 102
   - **Description**: User and permission management

### Custom Block Created

A custom Drupal block named "CiviCRM Admin Links" is created and placed in the header region, providing consistent access to admin functions on both Drupal and CiviCRM pages.

## 🔧 Manual Setup

### Creating Navigation Menu Items

If you need to manually create these navigation items, use the following commands:

```bash
# Access the Drupal container
docker-compose exec -T drupal bash

# Create Admin Settings link
cv api3 Navigation.create label="🛠️ Admin Settings" url="/civicrm/admin?reset=1" parent_id=1 weight=100 is_active=1

# Create System Settings link
cv api3 Navigation.create label="⚙️ System Settings" url="/civicrm/admin/setting?reset=1" parent_id=1 weight=101 is_active=1

# Create User Management link
cv api3 Navigation.create label="👥 User Management" url="/civicrm/admin/user?reset=1" parent_id=1 weight=102 is_active=1
```

### Creating Custom Block

To manually create the custom block for consistent admin access:

```bash
# Access the Drupal container
docker-compose exec -T drupal bash

# Create the custom block
cd /var/www/html/drupal && vendor/bin/drush eval "
\\Drupal::entityTypeManager()->getStorage('block_content')->create([
  'type' => 'basic', 
  'info' => 'CiviCRM Admin Links', 
  'body' => [
    'value' => '<ul><li><a href=\"/civicrm/admin?reset=1\">🛠️ CiviCRM Admin</a></li><li><a href=\"/civicrm/admin/setting?reset=1\">⚙️ System Settings</a></li><li><a href=\"/civicrm/admin/user?reset=1\">👥 User Management</a></li></ul>', 
    'format' => 'full_html'
  ]
])->save();
" --root=/var/www/html/drupal/web

# Enable and place the block
vendor/bin/drush config:set block.block.civicrmadminlinks status 1 --root=/var/www/html/drupal/web
vendor/bin/drush config:set block.block.civicrmadminlinks region header --root=/var/www/html/drupal/web
vendor/bin/drush cr --root=/var/www/html/drupal/web

## 📊 Navigation Menu Management

### View All Navigation Items

```bash
# View all navigation items in table format
docker-compose exec -T drupal cv api3 Navigation.get --out=table

# View all navigation items in JSON format
docker-compose exec -T drupal cv api3 Navigation.get --out=json-pretty

# View specific navigation item
docker-compose exec -T drupal cv api3 Navigation.get id=247
```

### Add New Navigation Items

```bash
# Basic syntax
docker-compose exec -T drupal cv api3 Navigation.create label="Your Label" url="/civicrm/your-url" parent_id=1 weight=103 is_active=1

# Example: Add Reports link
docker-compose exec -T drupal cv api3 Navigation.create label="📊 Reports" url="/civicrm/report/list?reset=1" parent_id=1 weight=103 is_active=1

# Example: Add Extensions link
docker-compose exec -T drupal cv api3 Navigation.create label="🔌 Extensions" url="/civicrm/admin/extensions?reset=1" parent_id=1 weight=104 is_active=1
```

### Update Existing Navigation Items

```bash
# Update an existing item (replace 247 with the actual ID)
docker-compose exec -T drupal cv api3 Navigation.create id=247 label="New Label" url="/civicrm/new-url" parent_id=1 weight=100 is_active=1

# Example: Update Admin Settings label
docker-compose exec -T drupal cv api3 Navigation.create id=247 label="🔧 Administration" url="/civicrm/admin?reset=1" parent_id=1 weight=100 is_active=1
```

### Delete Navigation Items

```bash
# Delete a navigation item (replace 247 with the actual ID)
docker-compose exec -T drupal cv api3 Navigation.delete id=247
```

### Disable Navigation Items

```bash
# Disable an item without deleting it
docker-compose exec -T drupal cv api3 Navigation.create id=247 is_active=0
```

## 🎨 Customization Options

### Navigation Item Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `label` | Display text for the menu item | `"🛠️ Admin Settings"` |
| `url` | URL the menu item links to | `"/civicrm/admin?reset=1"` |
| `parent_id` | Parent menu item (1 = main menu) | `1` |
| `weight` | Display order (lower = first) | `100` |
| `is_active` | Whether item is visible (1/0) | `1` |
| `permission` | Required permission to see item | `"administer CiviCRM"` |
| `icon` | CSS class for icon | `"crm-i fa-cog"` |
| `has_separator` | Add separator after item (1/0) | `1` |

### Useful CiviCRM Admin URLs

| Function | URL |
|----------|-----|
| Main Admin | `/civicrm/admin?reset=1` |
| System Settings | `/civicrm/admin/setting?reset=1` |
| User Management | `/civicrm/admin/user?reset=1` |
| Extensions | `/civicrm/admin/extensions?reset=1` |
| Reports | `/civicrm/report/list?reset=1` |
| Custom Fields | `/civicrm/admin/custom/group?reset=1` |
| Mail Settings | `/civicrm/admin/mailSettings?reset=1` |
| Payment Processors | `/civicrm/admin/paymentProcessor?reset=1` |
| Message Templates | `/civicrm/admin/messageTemplates?reset=1` |
| Scheduled Jobs | `/civicrm/admin/job?reset=1` |

### Icon Options

You can use emoji or FontAwesome icons:

```bash
# Emoji examples
label="🛠️ Admin Settings"
label="⚙️ System Settings"
label="👥 User Management"
label="📊 Reports"
label="🔌 Extensions"

# FontAwesome examples (requires icon parameter)
label="Admin Settings" icon="crm-i fa-cog"
label="User Management" icon="crm-i fa-users"
label="Reports" icon="crm-i fa-chart-bar"
```

## 🔒 Permission-Based Navigation

You can restrict navigation items based on user permissions:

```bash
# Only show to users with admin permission
docker-compose exec -T drupal cv api3 Navigation.create label="🔒 Admin Only" url="/civicrm/admin?reset=1" parent_id=1 weight=105 is_active=1 permission="administer CiviCRM"

# Only show to users with specific permission
docker-compose exec -T drupal cv api3 Navigation.create label="💰 Contributions" url="/civicrm/contribute?reset=1" parent_id=1 weight=106 is_active=1 permission="access CiviContribute"
```

## 📁 Sub-Menu Creation

You can create sub-menus by using different parent_id values:

```bash
# Create a parent menu item
docker-compose exec -T drupal cv api3 Navigation.create label="🔧 Administration" url="" parent_id=1 weight=100 is_active=1

# Create sub-menu items (replace PARENT_ID with the ID from above)
docker-compose exec -T drupal cv api3 Navigation.create label="System Settings" url="/civicrm/admin/setting?reset=1" parent_id=PARENT_ID weight=1 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="User Management" url="/civicrm/admin/user?reset=1" parent_id=PARENT_ID weight=2 is_active=1
```

## 🧹 Maintenance

### Clear Navigation Cache

If navigation changes don't appear immediately:

```bash
# Clear Drupal cache
docker-compose exec -T drupal bash -c "cd /var/www/html/drupal && vendor/bin/drush cr --root=/var/www/html/drupal/web"

# Clear CiviCRM cache
docker-compose exec -T drupal cv flush
```

### Backup Navigation Configuration

To backup your navigation configuration:

```bash
# Export all navigation items
docker-compose exec -T drupal cv api3 Navigation.get --out=json > navigation_backup.json

# Export specific items
docker-compose exec -T drupal cv api3 Navigation.get "id[IN]"="247,248,249" --out=json > custom_navigation_backup.json
```

## 🐛 Troubleshooting

### Common Issues

1. **Navigation items not appearing**
   - Check if `is_active=1`
   - Verify user has required permissions
   - Clear cache: `docker-compose exec -T drupal cv flush`

2. **Wrong order**
   - Adjust `weight` parameter (lower numbers appear first)
   - Reorder items by updating weights

3. **Broken links**
   - Verify URL format: `/civicrm/path?reset=1`
   - Test URLs manually in browser

4. **Permission issues**
   - Check user permissions in CiviCRM
   - Verify `permission` parameter is correct

### Debug Commands

```bash
# Check if CiviCRM is accessible
docker-compose exec -T drupal cv api3 System.check

# View user permissions
docker-compose exec -T drupal cv api3 Contact.get id=1 return=permissions

# Check navigation structure
docker-compose exec -T drupal cv api3 Navigation.get parent_id=1 --out=table
```

## 📚 Additional Resources

- [CiviCRM API Documentation](https://docs.civicrm.org/dev/en/latest/api/)
- [CiviCRM Navigation API](https://docs.civicrm.org/dev/en/latest/api/navigation/)
- [CiviCRM Permissions](https://docs.civicrm.org/user/en/latest/initial-set-up/permissions-and-access-control/)

## 🔄 Script Integration

The navigation menu setup is integrated into the `install.sh` script and will be automatically created during installation. To modify the default navigation items, edit the following section in `install.sh`:

```bash
echo "🔧 Setting up CiviCRM navigation menu..."
docker-compose exec -T drupal cv api3 Navigation.create label="🛠️ Admin Settings" url="/civicrm/admin?reset=1" parent_id=1 weight=100 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="⚙️ System Settings" url="/civicrm/admin/setting?reset=1" parent_id=1 weight=101 is_active=1
docker-compose exec -T drupal cv api3 Navigation.create label="👥 User Management" url="/civicrm/admin/user?reset=1" parent_id=1 weight=102 is_active=1
```

---

*Last updated: $(date)*
*CiviCRM Version: 6.5.5*
*Drupal Version: 10.3*
