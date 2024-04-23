import mysql.connector
 
mydb = mysql.connector.connect(
    host = "localhost",
    user = "root
    password = "1234",
    database = "geeksforgeeks"
)
 
cursor = mydb.cursor()
 
# Show existing tables
cursor.execute("SHOW TABLES")
 
for x in cursor:
  print(x)
