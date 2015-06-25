CONNECTION=SQLite3::Database.new("/Users/gwendolyn/code/06-23-wellness_tracker/wellness_tracker.db")
CONNECTION.results_as_hash = true
CONNECTION.execute("PRAGMA foreign_keys = ON;")


CONNECTION.execute("CREATE TABLE IF NOT EXISTS people (id INTEGER PRIMARY KEY, name TEXT NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS durations (id INTEGER PRIMARY KEY, name TEXT NOT NULL, num_quarter_hours INTEGER NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS intensities (id INTEGER PRIMARY KEY, name TEXT NOT NULL, point_adjustment INTEGER NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS exercise_types (id INTEGER PRIMARY KEY, name TEXT NOT NULL, point_base INTEGER NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS exercise_events (id INTEGER PRIMARY KEY, person_id INTEGER NOT NULL, exercise_type_id INTEGER NOT NULL, duration_id INTEGER NOT NULL, intensity_id INTEGER NOT NULL, date INTEGER NOT NULL, points INTEGER DEFAULT 0, FOREIGN KEY (person_id) REFERENCES people(id), FOREIGN KEY (duration_id) REFERENCES durations (id), FOREIGN KEY (intensity_id) REFERENCES intensities (id), FOREIGN KEY(exercise_type_id) REFERENCES exercise_types (id));")