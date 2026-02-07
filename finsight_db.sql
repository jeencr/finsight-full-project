/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 8.0.33 : Database - finsight_db
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`finsight_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `finsight_db`;

/*Data for the table `auth_group` */

insert  into `auth_group`(`id`,`name`) values 
(1,'admin'),
(2,'expert'),
(3,'user');

/*Data for the table `auth_group_permissions` */

/*Data for the table `auth_permission` */

insert  into `auth_permission`(`id`,`name`,`content_type_id`,`codename`) values 
(1,'Can add log entry',1,'add_logentry'),
(2,'Can change log entry',1,'change_logentry'),
(3,'Can delete log entry',1,'delete_logentry'),
(4,'Can view log entry',1,'view_logentry'),
(5,'Can add permission',2,'add_permission'),
(6,'Can change permission',2,'change_permission'),
(7,'Can delete permission',2,'delete_permission'),
(8,'Can view permission',2,'view_permission'),
(9,'Can add group',3,'add_group'),
(10,'Can change group',3,'change_group'),
(11,'Can delete group',3,'delete_group'),
(12,'Can view group',3,'view_group'),
(13,'Can add user',4,'add_user'),
(14,'Can change user',4,'change_user'),
(15,'Can delete user',4,'delete_user'),
(16,'Can view user',4,'view_user'),
(17,'Can add content type',5,'add_contenttype'),
(18,'Can change content type',5,'change_contenttype'),
(19,'Can delete content type',5,'delete_contenttype'),
(20,'Can view content type',5,'view_contenttype'),
(21,'Can add session',6,'add_session'),
(22,'Can change session',6,'change_session'),
(23,'Can delete session',6,'delete_session'),
(24,'Can view session',6,'view_session'),
(25,'Can add expert',7,'add_expert'),
(26,'Can change expert',7,'change_expert'),
(27,'Can delete expert',7,'delete_expert'),
(28,'Can view expert',7,'view_expert'),
(29,'Can add investment',8,'add_investment'),
(30,'Can change investment',8,'change_investment'),
(31,'Can delete investment',8,'delete_investment'),
(32,'Can view investment',8,'view_investment'),
(33,'Can add notification',9,'add_notification'),
(34,'Can change notification',9,'change_notification'),
(35,'Can delete notification',9,'delete_notification'),
(36,'Can view notification',9,'view_notification'),
(37,'Can add forex_predection',10,'add_forex_predection'),
(38,'Can change forex_predection',10,'change_forex_predection'),
(39,'Can delete forex_predection',10,'delete_forex_predection'),
(40,'Can view forex_predection',10,'view_forex_predection'),
(41,'Can add investers',11,'add_investers'),
(42,'Can change investers',11,'change_investers'),
(43,'Can delete investers',11,'delete_investers'),
(44,'Can view investers',11,'view_investers'),
(45,'Can add feed_back',12,'add_feed_back'),
(46,'Can change feed_back',12,'change_feed_back'),
(47,'Can delete feed_back',12,'delete_feed_back'),
(48,'Can view feed_back',12,'view_feed_back'),
(49,'Can add complaints',13,'add_complaints'),
(50,'Can change complaints',13,'change_complaints'),
(51,'Can delete complaints',13,'delete_complaints'),
(52,'Can view complaints',13,'view_complaints'),
(53,'Can add tips',14,'add_tips'),
(54,'Can change tips',14,'change_tips'),
(55,'Can delete tips',14,'delete_tips'),
(56,'Can view tips',14,'view_tips'),
(57,'Can add assgin_expert',15,'add_assgin_expert'),
(58,'Can change assgin_expert',15,'change_assgin_expert'),
(59,'Can delete assgin_expert',15,'delete_assgin_expert'),
(60,'Can view assgin_expert',15,'view_assgin_expert'),
(61,'Can add capital',16,'add_capital'),
(62,'Can change capital',16,'change_capital'),
(63,'Can delete capital',16,'delete_capital'),
(64,'Can view capital',16,'view_capital'),
(65,'Can add chat',17,'add_chat'),
(66,'Can change chat',17,'change_chat'),
(67,'Can delete chat',17,'delete_chat'),
(68,'Can view chat',17,'view_chat'),
(69,'Can add user_request',18,'add_user_request'),
(70,'Can change user_request',18,'change_user_request'),
(71,'Can delete user_request',18,'delete_user_request'),
(72,'Can view user_request',18,'view_user_request'),
(73,'Can add user portfolio',19,'add_userportfolio'),
(74,'Can change user portfolio',19,'change_userportfolio'),
(75,'Can delete user portfolio',19,'delete_userportfolio'),
(76,'Can view user portfolio',19,'view_userportfolio');

/*Data for the table `auth_user` */

insert  into `auth_user`(`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`) values 
(1,'pbkdf2_sha256$1000000$HbZTQvdMTm7IQabxVW3Qct$JR/y6mPI7d6qpqHj/ksEgGRM9m8+BNjKUDOKLpw7+vo=','2026-01-28 04:26:15.471059',1,'admin','','','',1,1,'2026-01-23 04:04:43.000000'),
(2,'pbkdf2_sha256$1000000$xTKjIYE6D7fPFlB5wF0sqM$GwDtXp8yTg/edwCQTEO/vC9n/O9uFYE7FmXyNxnPRu0=','2026-01-29 07:04:52.045227',0,'expert1','','','',0,1,'2026-01-23 05:52:52.106839'),
(3,'pbkdf2_sha256$1000000$5sNhaLGVRui5dzVjns4CyH$V5wo7eoFeJK8dOPPVsZgzaMABJnnY2G7KAIqa9FM5pE=',NULL,0,'demo_user','','','',0,1,'2026-01-23 08:00:56.649487');

/*Data for the table `auth_user_groups` */

insert  into `auth_user_groups`(`id`,`user_id`,`group_id`) values 
(1,1,1),
(2,2,2),
(3,3,3);

/*Data for the table `auth_user_user_permissions` */

/*Data for the table `django_admin_log` */

insert  into `django_admin_log`(`id`,`action_time`,`object_id`,`object_repr`,`action_flag`,`change_message`,`content_type_id`,`user_id`) values 
(1,'2026-01-23 04:06:25.909928','1','admin',1,'[{\"added\": {}}]',3,1),
(2,'2026-01-23 04:06:32.636183','2','expert',1,'[{\"added\": {}}]',3,1),
(3,'2026-01-23 04:06:38.855202','3','user',1,'[{\"added\": {}}]',3,1),
(4,'2026-01-23 04:06:49.387952','1','admin',2,'[{\"changed\": {\"fields\": [\"Groups\"]}}]',4,1);

/*Data for the table `django_content_type` */

insert  into `django_content_type`(`id`,`app_label`,`model`) values 
(1,'admin','logentry'),
(3,'auth','group'),
(2,'auth','permission'),
(4,'auth','user'),
(5,'contenttypes','contenttype'),
(15,'myapp','assgin_expert'),
(16,'myapp','capital'),
(17,'myapp','chat'),
(13,'myapp','complaints'),
(7,'myapp','expert'),
(12,'myapp','feed_back'),
(10,'myapp','forex_predection'),
(11,'myapp','investers'),
(8,'myapp','investment'),
(9,'myapp','notification'),
(14,'myapp','tips'),
(18,'myapp','user_request'),
(19,'myapp','userportfolio'),
(6,'sessions','session');

/*Data for the table `django_migrations` */

insert  into `django_migrations`(`id`,`app`,`name`,`applied`) values 
(1,'contenttypes','0001_initial','2026-01-23 04:02:26.095261'),
(2,'auth','0001_initial','2026-01-23 04:02:26.530784'),
(3,'admin','0001_initial','2026-01-23 04:02:26.642178'),
(4,'admin','0002_logentry_remove_auto_add','2026-01-23 04:02:26.647680'),
(5,'admin','0003_logentry_add_action_flag_choices','2026-01-23 04:02:26.653533'),
(6,'contenttypes','0002_remove_content_type_name','2026-01-23 04:02:26.718371'),
(7,'auth','0002_alter_permission_name_max_length','2026-01-23 04:02:26.771765'),
(8,'auth','0003_alter_user_email_max_length','2026-01-23 04:02:26.796126'),
(9,'auth','0004_alter_user_username_opts','2026-01-23 04:02:26.802362'),
(10,'auth','0005_alter_user_last_login_null','2026-01-23 04:02:26.892005'),
(11,'auth','0006_require_contenttypes_0002','2026-01-23 04:02:26.893634'),
(12,'auth','0007_alter_validators_add_error_messages','2026-01-23 04:02:26.898980'),
(13,'auth','0008_alter_user_username_max_length','2026-01-23 04:02:26.951779'),
(14,'auth','0009_alter_user_last_name_max_length','2026-01-23 04:02:27.005476'),
(15,'auth','0010_alter_group_name_max_length','2026-01-23 04:02:27.020267'),
(16,'auth','0011_update_proxy_permissions','2026-01-23 04:02:27.027288'),
(17,'auth','0012_alter_user_first_name_max_length','2026-01-23 04:02:27.079314'),
(18,'myapp','0001_initial','2026-01-23 04:02:27.158961'),
(19,'myapp','0002_expert_name','2026-01-23 04:02:27.181530'),
(20,'myapp','0003_investment_notification_forex_predection_investers_and_more','2026-01-23 04:02:27.503686'),
(21,'myapp','0004_feed_back_expert_assgin_expert_capital_chat_and_more','2026-01-23 04:02:27.875576'),
(22,'sessions','0001_initial','2026-01-23 04:02:27.905033'),
(23,'myapp','0005_user_request_expert_alter_investers_photo_and_more','2026-01-23 10:04:23.035406'),
(24,'myapp','0006_tips_company_tips_recommendation_tips_sector','2026-01-24 04:59:21.311814'),
(25,'myapp','0007_userportfolio_date_userportfolio_number_of_stocks_and_more','2026-01-24 09:30:20.623797'),
(26,'myapp','0008_alter_chat_date','2026-01-27 11:54:31.450914');

/*Data for the table `django_session` */

insert  into `django_session`(`session_key`,`session_data`,`expire_date`) values 
('7psdfeap4yyhoay4ea10isms3r8gt3tg','.eJxVjDsOwjAQBe_iGln-fyjpOYO167VxADlSnFSIu0OkFNC-mXkvlmBbW9pGWdJE7MwUO_1uCPlR-g7oDv028zz3dZmQ7wo_6ODXmcrzcrh_Bw1G-9YIyrjopUTQwjpwrkTSQQRrIBbrCUKtjqoqlSpYiMKTz9rboCUajOz9AeHROBc:1vkHFg:Y9aryFFwqwuORtWRR2pw9zgaobxNlGyni-28csQvvYo','2026-02-09 07:43:12.446814'),
('kwkpj5vc7duw7ypdtwhhd62n134sgdfa','.eJxVjDsOwjAQBe_iGln-fyjpOYO167VxADlSnFSIu0OkFNC-mXkvlmBbW9pGWdJE7MwUO_1uCPlR-g7oDv028zz3dZmQ7wo_6ODXmcrzcrh_Bw1G-9YIyrjopUTQwjpwrkTSQQRrIBbrCUKtjqoqlSpYiMKTz9rboCUajOz9AeHROBc:1vlM5E:THMKC_C0EmacmPj8FyPhq2rVosVFb6JHTkCUF0AYbF8','2026-02-12 07:04:52.105938'),
('v563lkdpzcvxqxxhtqr1slm78jbsm7r6','.eJxVjDsOwyAQBe9CHSG-BlKm9xnQsizBSYQlY1dR7h5bcpG0b2bem0XY1hq3TkucMrsyyS6_WwJ8UjtAfkC7zxznti5T4ofCT9r5OGd63U7376BCr3tNRuokAiB5cEYKQSpA0ejcgA5EQauksDnhkINC6ZJxfge2aOuNVsg-X-W_N8U:1vkHP2:gu1O1idSrlruRn491Hf-8iHIQHIeOBvH1RVSW0k0z5U','2026-02-09 07:52:52.015536');

/*Data for the table `myapp_assgin_expert` */

insert  into `myapp_assgin_expert`(`id`,`Expert_id`,`Investers_id`) values 
(1,1,1);

/*Data for the table `myapp_capital` */

/*Data for the table `myapp_chat` */

insert  into `myapp_chat`(`id`,`message`,`date`,`from_id_id`,`to_id_id`) values 
(1,'hghg','2026-01-24 00:00:00.000000',2,3),
(2,'gfhj','2026-01-24 00:00:00.000000',2,3),
(3,'JB jjbbu','2026-01-27 00:00:00.000000',3,2),
(4,'ghknb','2026-01-27 00:00:00.000000',3,2),
(5,'fffgff','2026-01-27 00:00:00.000000',3,2),
(6,'BK bjbbib','2026-01-27 00:00:00.000000',3,2),
(7,'sndjnskdjn','2026-01-27 00:00:00.000000',2,3),
(8,'vhbubhb','2026-01-27 17:25:06.808899',3,2),
(9,'hghg','2026-01-27 17:25:44.715528',2,3),
(10,'hi','2026-01-27 17:54:44.969029',3,2),
(11,'shukj','2026-01-27 17:55:11.826978',3,2),
(12,'scvgg','2026-01-27 17:55:19.289949',3,2),
(13,'hiiiilioi','2026-01-27 17:55:35.771920',3,2),
(14,'hghuuuhgg','2026-01-27 17:55:43.600133',2,3);

/*Data for the table `myapp_complaints` */

insert  into `myapp_complaints`(`id`,`conplaint`,`replay`,`date`,`Investers_id`) values 
(1,'rhfhfjfnffbbdbfcbdb','hgchgv','2026-01-28',1);

/*Data for the table `myapp_expert` */

insert  into `myapp_expert`(`id`,`specilization`,`photo`,`experiance`,`status`,`phone`,`email`,`LOGIN_id`,`name`) values 
(1,'gsdh','expert_photo/Screenshot_2026-01-22_162311.png','3','accepted','798999788','expert1@gmail.com',2,'Expert1');

/*Data for the table `myapp_feed_back` */

/*Data for the table `myapp_forex_predection` */

/*Data for the table `myapp_investers` */

insert  into `myapp_investers`(`id`,`name`,`place`,`photo`,`age`,`phone`,`nationality`,`email`,`LOGIN_id`) values 
(1,'demo  v s','Ernakulam ','invester_photo/1000410882.jpg','40','6484946161','india','demo@gmail.com',3);

/*Data for the table `myapp_investment` */

/*Data for the table `myapp_notification` */

insert  into `myapp_notification`(`id`,`title`,`description`,`date`) values 
(1,'bsdjhsdjk','sdfwefgergf','2026-01-24');

/*Data for the table `myapp_tips` */

insert  into `myapp_tips`(`id`,`tips`,`description`,`Expert_id`,`company`,`recommendation`,`sector`) values 
(1,'Buy','Best buy',1,'Asian Paints','Low Risk','FMCG'),
(2,'Buy','sensex best but',1,'Bajaj Finance','Medium Risk','Finance'),
(3,'Hold','hgjugj',1,'TCS','Medium Risk','Tech');

/*Data for the table `myapp_user_request` */

insert  into `myapp_user_request`(`id`,`amount`,`income`,`occupation`,`status`,`Investers_id`,`Expert_id`) values 
(2,'10000','1000','software Engineer ','accepted',1,1);

/*Data for the table `myapp_userportfolio` */

insert  into `myapp_userportfolio`(`id`,`company`,`Expert_id`,`Investers_id`,`date`,`number_of_stocks`,`price_per_stock_when_bought`) values 
(5,'ICICIBANK',1,1,'2026-01-27 10:01','1558.33','1361.4'),
(6,'ICICIBANK',1,1,'2026-01-27 10:03','55670.56','1361.4'),
(7,'TCS',1,1,'2026-01-27 10:10','24.0','3158.0');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
