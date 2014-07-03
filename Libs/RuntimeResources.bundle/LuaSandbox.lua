-- This file is loaded before any user scripts, removing unsafe environment functions

------------------------------------------------
-- Block out any dangerous or insecure functions
------------------------------------------------

arg=nil

os.execute=nil
os.exit=nil
