-- Music Streaming Analytics SQL Project

-- 1. Create Users table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50),
    signup_date DATE
);

-- 2. Create Artists table
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    debut_year INT,
    total_albums INT
);

-- 3. Create Songs table
CREATE TABLE Songs (
    song_id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    artist_id INT REFERENCES Artists(artist_id),
    album VARCHAR(100),
    genre VARCHAR(50),
    duration_sec INT
);

-- 4. Create Plays table
CREATE TABLE Plays (
    play_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    song_id INT REFERENCES Songs(song_id),
    play_time TIMESTAMP,
    device_type VARCHAR(50)
);

-- 5. Create Subscription table
CREATE TABLE Subscription (
    sub_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    plan_type VARCHAR(20), -- Free or Premium
    start_date DATE,
    end_date DATE
);

-- Sample Queries for Analysis

-- 1. Top 10 most played songs
SELECT s.title, COUNT(p.play_id) AS play_count
FROM Plays p
JOIN Songs s ON p.song_id = s.song_id
GROUP BY s.title
ORDER BY play_count DESC
LIMIT 10;

-- 2. Average play duration per user
SELECT u.name, AVG(s.duration_sec) AS avg_duration
FROM Plays p
JOIN Users u ON p.user_id = u.user_id
JOIN Songs s ON p.song_id = s.song_id
GROUP BY u.name;

-- 3. User churn analysis (users who downgraded from Premium to Free)
SELECT u.name, COUNT(*) AS downgrade_count
FROM Subscription s
JOIN Users u ON s.user_id = u.user_id
WHERE s.plan_type = 'Free'
  AND s.user_id IN (
    SELECT s2.user_id FROM Subscription s2 WHERE s2.plan_type = 'Premium'
  )
GROUP BY u.name;


-- 4. Most popular genre by country
SELECT u.country, s.genre, COUNT(*) AS play_count
FROM Plays p
JOIN Songs s ON p.song_id = s.song_id
JOIN Users u ON p.user_id = u.user_id
GROUP BY u.country, s.genre
ORDER BY u.country, play_count DESC;

-- 5. Monthly trend of plays per artist
SELECT a.name AS artist_name,
       DATE_TRUNC('month', p.play_time) AS play_month,
       COUNT(*) AS monthly_plays
FROM Plays p
JOIN Songs s ON p.song_id = s.song_id
JOIN Artists a ON s.artist_id = a.artist_id
GROUP BY a.name, play_month
ORDER BY a.name, play_month;


INSERT INTO Users (name, email, country, signup_date) VALUES
('Aditi Sharma', 'aditi@example.com', 'India', '2023-05-10'),
('Rahul Mehta', 'rahul@example.com', 'USA', '2023-03-12'),
('Emily Zhang', 'emily@example.com', 'Canada', '2022-11-25');

INSERT INTO Artists (name, debut_year, total_albums) VALUES
('Arijit Singh', 2010, 20),
('Taylor Swift', 2006, 15),
('The Weeknd', 2011, 9);

INSERT INTO Songs (title, artist_id, album, genre, duration_sec) VALUES
('Tum Hi Ho', 1, 'Aashiqui 2', 'Romantic', 240),
('Lover', 2, 'Lover', 'Pop', 210),
('Blinding Lights', 3, 'After Hours', 'Synthpop', 200);

INSERT INTO Plays (user_id, song_id, play_time, device_type) VALUES
(1, 1, '2024-06-01 09:00:00', 'Mobile'),
(1, 2, '2024-06-01 09:05:00', 'Mobile'),
(2, 3, '2024-06-02 10:00:00', 'Web'),
(3, 1, '2024-06-03 11:30:00', 'Tablet'),
(3, 3, '2024-06-04 12:15:00', 'Mobile');


INSERT INTO Subscription (user_id, plan_type, start_date, end_date) VALUES
(1, 'Free', '2023-05-10', '2023-09-10'),
(1, 'Premium', '2023-09-11', '2024-06-01'),
(2, 'Premium', '2023-03-12', '2024-06-01'),
(2, 'Free', '2024-06-02', NULL),
(3, 'Premium', '2022-11-25', NULL);

-- re-run the queries
