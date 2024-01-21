use ig_clone;

select * from photos;
select * from users;
select * from likes;


-- 1 Create an ER diagram or draw a schema for the given database.



-- 2 We want to reward the user who has been around the longest, Find the 5 oldest users
SELECT * FROM users
ORDER BY created_at ASC
LIMIT 5;



-- 3 To target inactive users in an email ad campaign, 
-- find the users who have never posted a photo.

select * from users where id not in (select user_id from photos);

SELECT users.id,username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;


-- 4  Suppose you are running a contest to find out who got the most likes on a photo. 
-- Find out who won?

select p.id,username,p.image_url,count(*) as Total_likes from photos as p
inner join likes as l 
on p.id = l.photo_id
inner join users as u
on u.id=p.user_id
group by p.id,username
order by Total_likes desc
limit 1;
use ig_clone;
SELECT distinct
    username,
    COUNT(*) AS most_likes
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id,username
ORDER BY most_likes DESC
LIMIT 1;



WITH A AS
     (SELECT USER_ID, COUNT(PHOTO_ID), DENSE_RANK() OVER (ORDER BY COUNT(PHOTO_ID) DESC) AS MORE_LIKES FROM LIKES  GROUP BY USER_ID  ORDER BY COUNT(PHOTO_ID) DESC)
     SELECT * FROM A WHERE MORE_LIKES = 1;


SELECT p.id,user_id,UserName FROM photos p
      INNER JOIN users u 
      ON p.user_id = u.id
      WHERE p.id = (SELECT photo_id FROM  
                              (SELECT photo_id, COUNT(l.user_id) FROM likes l
                               GROUP BY photo_id
		       ORDER BY count(user_id) DESC
		       LIMIT 1)p) ;


SELECT users.username,COUNT(*) AS Total_Likes
FROM likes
INNER JOIN photos ON photos.id = likes.photo_id
INNER JOIN users ON photos.user_id = users.id
GROUP BY users.username
ORDER BY Total_Likes DESC
limit 1;


SELECT
    users.id AS user_id,
    username,
	photos.id AS photo_id,
    photos.image_url,
    COUNT(*) AS total_likes_count
FROM photos
    JOIN likes
        ON photos.id = likes.photo_id
    JOIN users
        ON users.id = photos.user_id
    GROUP BY photos.id
    ORDER BY total_likes_count DESC
    LIMIT 1;


-- 5 The investors want to know how many times does the average user post.
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),0) as num_of_times;




WITH CTC AS (SELECT USER_ID, COUNT(IMAGE_URL) AS NO_OF_POSTS FROM PHOTOS GROUP BY USER_ID)
     SELECT ROUND(AVG(NO_OF_POSTS)) FROM CTC;


-- 6 A brand wants to know which hashtag to use on a post, and 
-- find the top 5 most used hashtags.
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
INNER JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
LIMIT 5;

  SELECT T.TAG_NAME, COUNT(T.ID) FROM PHOTO_TAGS AS PT INNER JOIN TAGS AS T ON T.ID = PT.TAG_ID 
	 GROUP BY TAG_NAME ORDER BY COUNT(T.ID) DESC LIMIT 5;

-- 7 To find out if there are bots, find users who have liked every single photo on the site.
SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos);

SELECT photos.user_id, count(photos.user_id) AS users_in_photos, count(likes.user_id) AS users_in_likes
FROM photos
INNER JOIN likes
ON photos.user_id = likes.user_id
group by photos.user_id;

SELECT username,user_id, MAX(photo_id) FROM likes l
INNER JOIN users u 
ON u.id=l.user_id
WHERE photo_id=(SELECT max(photo_id) FROM likes)
                GROUP BY  user_id
                ORDER BY  MAX(photo_id) DESC;




 select user_id from likes group by user_id 
 having count(distinct photo_id) = (select count(*) from photos);


-- 8 Find the users who have created instagramid in may and 
-- select top 5 newest joinees from it?
SELECT * FROM users
where month(created_at)="05"
ORDER BY created_at desc
limit 5;

select * from users where monthname(created_at) = 'may' 
order by created_at desc limit 5;


-- 9) Can you help me find the users whose name starts with c and ends with any number 
-- and have posted the photos as well as liked the photos?

SELECT DISTINCT username,users.id from users 
LEFT JOIN likes ON likes.user_id = users.id
INNER JOIN photos ON photos.id = likes.photo_id
where username regexp '^C.*[0-9]$';

select distinct username from users u 
left join photos p 
on u.id=p.user_id
where u.id= (select distinct id from users u 
             inner join likes l
             on u.id=l.user_id
             where username regexp '^C.*[0-9]$');

select distinct(u.id), u.username from users as u 
inner join photos as p on p.user_id = u.id
inner join likes as l on l.user_id = p.user_id 
where username regexp '^c.*[0-9]$';

with user_s as
(
select * from users
where username regexp '^c.*[0-9]$'
),
 user_s_pg as
 ( select u.id as user_id from  user_s as u
   inner join photos as p
   on u.id = p.user_id
   inner join likes l 
   on u.id = l.user_id
) 
 select distinct u.id, u.username from user_s  u
 inner join user_s_pg as pcg 
 on u.id = pcg.user_id;
         

-- 10 Demonstrate the top 30 usernames to the company who have
--  posted photos in the range of 3 to 5.

SELECT username, count(photos.id) as posted_photos FROM users 
INNER JOIN photos on users.id = photos.user_id 
GROUP BY username
HAVING (count(photos.id)>=3 AND count(photos.id)<=5) 
ORDER BY posted_photos ASC
limit 30;


