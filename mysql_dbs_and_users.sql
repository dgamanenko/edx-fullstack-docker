CREATE DATABASE IF NOT EXISTS `edxapp` /*!40100 DEFAULT CHARACTER SET utf8 */;
CREATE DATABASE IF NOT EXISTS `edxapp_csmh` /*!40100 DEFAULT CHARACTER SET utf8 */;
CREATE DATABASE IF NOT EXISTS `xqueue` /*!40100 DEFAULT CHARACTER SET utf8 */;
CREATE DATABASE IF NOT EXISTS `discovery` /*!40100 DEFAULT CHARACTER SET utf8 */;

GRANT ALL ON `edxapp`.* to 'migrate'@'%' identified by 'SOME_SECRET_PASSWORD';
GRANT ALL ON `edxapp_csmh`.* to 'migrate'@'%' identified by 'SOME_SECRET_PASSWORD';
GRANT ALL ON `xqueue`.* to 'migrate'@'%' identified by 'SOME_SECRET_PASSWORD';
GRANT ALL ON `discovery`.* to 'migrate'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT ALL ON `xqueue`.* to 'xqueue'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT create user ON *.* to 'admin'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT ALL ON `edxapp_csmh`.* to 'edxapp_cmsh001'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT ALL ON `edxapp`.* to 'edxapp001'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT SELECT, LOCK TABLES, SHOW VIEW ON *.* to 'read_only'@'%' identified by 'SOME_SECRET_PASSWORD';

GRANT ALL ON `discovery`.* to 'discov001'@'%' identified by 'SOME_SECRET_PASSWORD';
