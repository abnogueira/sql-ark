# SQL Murder Mystery 🕵️‍♀️

![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

A crime has taken place and the detective needs your help. The detective gave you the crime scene report, but you somehow lost it. You vaguely remember that the crime was a ​murder​ that occurred sometime on ​Jan.15, 2018​ and that it took place in ​SQL City​. Start by retrieving the corresponding crime scene report from the police department’s database.

## Solution - A. Find the murderer

### Find the Crime Scene Report

```sql
SELECT *
FROM crime_scene_report
WHERE city = 'SQL City' AND TYPE = 'murder'
```

A month before the Jan.15, 2018, there was a murder with the following information:

> Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".

### Finding the Witnesses

```sql
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1
```

```sql
SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave' AND NAME LIKE '%Annabel%'
```

The witnesses are Morty Schapiro and Annabel Miller. Next, we need to read the transcripts of their interviews.

### Read the Transcripts of Interviews from Witnesses

```sql
SELECT *
FROM interview
WHERE person_id IN (
    SELECT id
    FROM (SELECT id FROM person
        WHERE address_street_name = 'Northwestern Dr'
        ORDER BY address_number DESC
        LIMIT 1)
    UNION ALL
    SELECT id
    FROM (SELECT id FROM person
        WHERE address_street_name = 'Franklin Ave' AND NAME LIKE '%Annabel%')
);
```

First witness gave information about the perpetrator:
> He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

And the second witness said:
> I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

### Finding the guy from the gym

```sql
WITH cte_suspect AS (
    SELECT *
    FROM get_fit_now_check_in
    WHERE check_in_date = '20180109'
)
SELECT p.*, dl.plate_number
FROM cte_suspect_1 s
JOIN get_fit_now_member mb
    ON s.membership_id = mb.id
JOIN person p
    ON p.id = mb.person_id
JOIN drivers_license dl
    ON p.license_id = dl.id
WHERE mb.membership_status = 'gold'
    AND dl.plate_number LIKE '%H42W%';
```

And the murderer is Jeremy Bowers, who has a gold status in the gym membership and a plate number `0H42W2`, all thanks to the information from the witness. After confirming if the murderer was the right suspect, we have a new quest: finding who hired him.

## Solution - B. Finding the Muder for Hire

> If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries. Challenged Accepted!

### Reading the Interview from the Murderer

```sql
WITH cte_murder AS (
    SELECT mb.person_id, p.*, dl.plate_number
    FROM get_fit_now_check_in s
    JOIN get_fit_now_member mb
        ON s.membership_id = mb.id
    JOIN person p
        ON p.id = mb.person_id
    JOIN drivers_license dl
        ON p.license_id = dl.id
    WHERE s.check_in_date = '20180109' 
        AND mb.membership_status = 'gold'
        AND dl.plate_number LIKE '%H42W%'
)
SELECT i.*
FROM cte_murder m
JOIN interview i
WHERE m.person_id = i.person_id
```

We got the following information:

> I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.

### Finding the Murderer for Hire

```sql
SELECT p.*, 
    i.annual_income,
    COUNT(fb.event_name) AS concert_times
FROM drivers_license dl
JOIN person p
    ON p.license_id = dl.id
LEFT JOIN income i
    ON i.ssn = p.ssn
LEFT JOIN facebook_event_checkin fb
    ON fb.person_id = p.id
WHERE dl.hair_color = 'red'
  AND dl.gender = 'female'
  AND dl.car_make = 'Tesla'
  AND dl.car_model = 'Model S'
  AND dl.height <= 67
  AND dl.height >= 65
  AND fb.event_name = 'SQL Symphony Concert'
```

Only one name appeared: Miranda Priestly, based on the information on hair color, gender, height, car model, car make, and to filter which women adding the information of the event attended. Time to break out the champagne!
