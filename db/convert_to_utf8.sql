ALTER TABLE `connections` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `credentials` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `kvstores` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `push_users` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `schema_migrations` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `users` CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;

ALTER TABLE `connections` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `credentials` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `kvstores` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `push_users` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `schema_migrations` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
ALTER TABLE `users` CHARACTER SET utf8 COLLATE utf8_unicode_ci;

ALTER DATABASE `zazo` CHARACTER SET utf8 COLLATE utf8_unicode_ci;
