-- Rename delivery_time_hours to delivery_time_days
ALTER TABLE templates RENAME COLUMN delivery_time_hours TO delivery_time_days;

-- Adjust data if necessary (e.g. if you want to convert hours to days, but since we're pivoting, we might just start fresh or keep values)
-- For now, we'll just rename to match the user's preference for units.
