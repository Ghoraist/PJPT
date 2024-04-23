import mysql.connector
 
mydb = mysql.connector.connect(
    host = "192.168.0.1",
    user = "root",
    password = "MySuperSecretPassword",
    database = "geeksforgeeks"
)
 
cursor = mydb.cursor()
 
# Show existing tables
cursor.execute("SHOW TABLES")
 
for x in cursor:
  print(x)
