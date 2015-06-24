#Wellness Tracker

Build a wellness tracker for corporate challenges.  For example, a company wants to have a challenge where employees track their exercise for one month.  Employees earn points for exercises of different types and intensities.  If at the end of the month, they have earned enough points, they "win" the challenge.


#Model Diagrams

Exercise Types, Intensity, and Duration are static tables that help determine how many points a particular exercise event is worth.

People have names and IDs.

Exercise events are the description of a particular persons's exercise of a particular type, of a particular intensity and duration, on a specific date.  They are worth a certain number of points.


#Description

The Wellness Tracker contains the following:

 - Some number of users
 - Some number of exercise types
 - Intensities and durations are statically defined tables.
 - Users can have many exercise events, and exercise events can have many exercise types.  
 
A single exercise event only has one user and one exercise type.

The points are calculated based on the exercise type, duration, and intensity.  A user's total points are the sum of the points from all exercise events.  

The wellness tracker should have a web ux.

##Should cases

Here's what we should be able to do:

  1. Create new users
  2. Delete users
  3. Create new exercise events
  4. Edit existing exercise events
  5. Delete exercise events
  6. Show all of a user's exercise events
  7. Calculate a user's total points
  8. Determine if a user has "won" the challenge
  
##Should not cases

Here's what you should not be able to do:

  1. Create an exercise event for a user who does not exist
  2. Create an exercise event for an exercise type that does not exist
  3. Create an exercise event for a duration that does not exist
  4. Create an exercise event for an intensity that does not exist
  5. Allow users to edit an exercise from more than a week ago
  6. Allow more than one date-exercise type-user combination in the exercise event table.

##Stretches

If I have time, I will try to make a Rule table and an Achievement Table.  The Rule table will indicate how many points are needed within a particular timeframe.  The Achievement table will combine the user with the rule and will indicate if the user "passed".


#ORM  - Object Relationship Model
Person Table  | Description
------------- | ---------------------------                                        
id            |  Integer PRIMARY KEY                                        
name          |  Text


Exercise Types | Description
-------------- | ------------
id             | Integer PRIMARY KEY
name           | Text
`point_base`   | Integer


Intensity           | Description
------------------  | ----------------
id                  | Integer PRIMARY KEY
name                | Text
`point_adjustment`  | Integer                     


Duration            | Description
------------------- | ------------------
id                  | Integer PRIMARY KEY
name                | Text NOT NULL
`num_quarter_hours` | Integer NOT NULL


Exercise Event      | Description
------------------- | -------------------
id                  | Integer PRIMARY KEY
`person_id`         | Integer FOREIGN KEY NOT NULL
`exercise_type`     | Integer FOREIGN KEY NOT NULL
date                | Integer NOT NULL
intensity           | Integer FOREIGN KEY NOT NULL
duration            | Integer FOREIGN KEY NOT NULL
points              | Integer DEFAULT 0

Within the Exercise Event table, the combination of `user_id`, `exercise_type` and date should be unique.