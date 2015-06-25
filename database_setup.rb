CONNECTION=SQLite3::Database.new("/Users/gwendolyn/code/06-23-wellness_tracker/wellness_tracker.db")
CONNECTION.results_as_hash = true
CONNECTION.execute("PRAGMA foreign_keys = ON;")


CONNECTION.execute("CREATE TABLE IF NOT EXISTS people (id INTEGER PRIMARY KEY, name TEXT NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS durations (id INTEGER PRIMARY KEY, name TEXT NOT NULL, num_quarter_hours INTEGER NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS intensities (id INTEGER PRIMARY KEY, name TEXT NOT NULL, point_adjustment INTEGER NOT NULL);")
CONNECTION.execute("CREATE TABLE IF NOT EXISTS exercise_types (id INTEGER PRIMARY KEY, name TEXT NOT NULL, point_base INTEGER NOT NULL);")