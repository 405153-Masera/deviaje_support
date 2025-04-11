-- Base de Datos para Microservicio de Soporte (reviews, notificaciones)

CREATE DATABASE IF NOT EXISTS deviaje_support;

USE deviaje_support;

-- Tabla de Reviews de Plataforma
CREATE TABLE reviews (
                         id INT PRIMARY KEY AUTO_INCREMENT,
                         user_id INT NOT NULL,
                         rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
                         title VARCHAR(100),
                         comment TEXT,
                         booking_id INT,
                         created_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                         created_user INT,
                         last_updated_datetime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         last_updated_user INT
);

-- Tabla de Respuestas a Reviews
CREATE TABLE review_responses (
                                  id INT PRIMARY KEY AUTO_INCREMENT,
                                  review_id INT NOT NULL,
                                  response_text TEXT NOT NULL,
                                  responded_by_user_id INT NOT NULL,
                                  created_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                                  created_user INT,
                                  last_updated_datetime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  last_updated_user INT,
                                  FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE
);

-- Tabla de Notificaciones
CREATE TABLE notifications (
                               id INT PRIMARY KEY AUTO_INCREMENT,
                               user_id INT NOT NULL,
                               notification_type VARCHAR(50) NOT NULL,
                               title VARCHAR(100) NOT NULL,
                               message TEXT NOT NULL,
                               is_read BOOLEAN DEFAULT FALSE,
                               sent_at DATETIME,
                               created_datetime DATETIME DEFAULT CURRENT_TIMESTAMP,
                               created_user INT,
                               last_updated_datetime DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               last_updated_user INT
);

-- Tabla de Auditoría para platform_reviews
CREATE TABLE reviews_audit (
                               version_id INT AUTO_INCREMENT PRIMARY KEY,
                               id INT,
                               version INT,
                               user_id INT,
                               rating TINYINT,
                               title VARCHAR(100),
                               comment TEXT,
                               booking_id INT,
                               created_datetime DATETIME,
                               created_user INT,
                               last_updated_datetime DATETIME,
                               last_updated_user INT
);

-- Tabla de Auditoría para review_responses
CREATE TABLE review_responses_audit (
                                        version_id INT AUTO_INCREMENT PRIMARY KEY,
                                        id INT,
                                        version INT,
                                        review_id INT,
                                        response_text TEXT,
                                        responded_by_user_id INT,
                                        created_datetime DATETIME,
                                        created_user INT,
                                        last_updated_datetime DATETIME,
                                        last_updated_user INT
);

-- Tabla de Auditoría para notifications
CREATE TABLE notifications_audit (
                                     version_id INT AUTO_INCREMENT PRIMARY KEY,
                                     id INT,
                                     version INT,
                                     user_id INT,
                                     notification_type VARCHAR(50),
                                     title VARCHAR(100),
                                     message TEXT,
                                     is_read BOOLEAN,
                                     sent_at DATETIME,
                                     created_datetime DATETIME,
                                     created_user INT,
                                     last_updated_datetime DATETIME,
                                     last_updated_user INT
);

DELIMITER $$

-- Triggers para reviews
CREATE TRIGGER trg_reviews_insert
    AFTER INSERT ON reviews
    FOR EACH ROW
BEGIN
    INSERT INTO reviews_audit (id, version, user_id, rating, title, comment, booking_id, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, 1, NEW.user_id, NEW.rating, NEW.title, NEW.comment, NEW.booking_id, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

CREATE TRIGGER trg_reviews_update
    AFTER UPDATE ON reviews
    FOR EACH ROW
BEGIN
    DECLARE latest_version INT;
    SELECT MAX(version) INTO latest_version FROM reviews_audit WHERE id = NEW.id;
    SET latest_version = IFNULL(latest_version, 0) + 1;

    INSERT INTO reviews_audit (id, version, user_id, rating, title, comment, booking_id, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, latest_version, NEW.user_id, NEW.rating, NEW.title, NEW.comment, NEW.booking_id, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

-- Triggers para review_responses
CREATE TRIGGER trg_review_responses_insert
    AFTER INSERT ON review_responses
    FOR EACH ROW
BEGIN
    INSERT INTO review_responses_audit (id, version, review_id, response_text, responded_by_user_id, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, 1, NEW.review_id, NEW.response_text, NEW.responded_by_user_id, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

CREATE TRIGGER trg_review_responses_update
    AFTER UPDATE ON review_responses
    FOR EACH ROW
BEGIN
    DECLARE latest_version INT;
    SELECT MAX(version) INTO latest_version FROM review_responses_audit WHERE id = NEW.id;
    SET latest_version = IFNULL(latest_version, 0) + 1;

    INSERT INTO review_responses_audit (id, version, review_id, response_text, responded_by_user_id, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, latest_version, NEW.review_id, NEW.response_text, NEW.responded_by_user_id, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

-- Triggers para notifications
CREATE TRIGGER trg_notifications_insert
    AFTER INSERT ON notifications
    FOR EACH ROW
BEGIN
    INSERT INTO notifications_audit (id, version, user_id, notification_type, title, message, is_read, sent_at, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, 1, NEW.user_id, NEW.notification_type, NEW.title, NEW.message, NEW.is_read, NEW.sent_at, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

CREATE TRIGGER trg_notifications_update
    AFTER UPDATE ON notifications
    FOR EACH ROW
BEGIN
    DECLARE latest_version INT;
    SELECT MAX(version) INTO latest_version FROM notifications_audit WHERE id = NEW.id;
    SET latest_version = IFNULL(latest_version, 0) + 1;

    INSERT INTO notifications_audit (id, version, user_id, notification_type, title, message, is_read, sent_at, created_datetime, created_user, last_updated_datetime, last_updated_user)
    VALUES (NEW.id, latest_version, NEW.user_id, NEW.notification_type, NEW.title, NEW.message, NEW.is_read, NEW.sent_at, NEW.created_datetime, NEW.created_user, NEW.last_updated_datetime, NEW.last_updated_user);
END $$

DELIMITER $$
