INSERT IGNORE INTO roles (name, description, created_by, created_at)
VALUES
  ('SUPER_ADMIN', 'System Super Administrator', 0, NOW()),
  ('ADMIN', 'System Administrator', 0, NOW()),
  ('USER', 'Standard User', 0, NOW()),
  ('MANAGER', 'Project Manager', 0, NOW()),
  ('MEMBER', 'Project Member', 0, NOW()),
  ('VIEWER', 'Read-only Viewer', 0, NOW());
