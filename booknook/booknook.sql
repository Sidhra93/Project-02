CREATE DATABASE booknook;

CREATE TABLE books(
  id SERIAL4 PRIMARY KEY,
  title VARCHAR(200),
  author VARCHAR(100),
  date_published VARCHAR(50),
  decription VARCHAR(2000),
  image_url VARCHAR(500)
);

ALTER TABLE books ADD COLUMN volume_id VARCHAR (100);

CREATE TABLE users(
  id SERIAL4 PRIMARY KEY,
  username VARCHAR(100),
  password_digest VARCHAR(400)
);
