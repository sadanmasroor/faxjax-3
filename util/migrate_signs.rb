require "mysql"

# Connect to the old and new db's
old_db = Mysql.real_connect("localhost", "root", "jxtpse027792", "faxjaxc_faxjax")
new_db = Mysql.real_connect("localhost", "root", "jxtpse027792", "faxjax_development")

# Query the old signs
res = old_db.query("SELECT * FROM signs LIMIT 0,10000")

# Print the column names
keys = []
res.fetch_hash.each_key{|key| keys << key }
puts keys.join(", ")
# Go back to 0 position
res.data_seek(0)

sql_a = []
sql = "INSERT INTO signs (code, `key`) VALUES "
while row = res.fetch_hash do
  sql_a << "('"+row["code"]+"','"+row["activationKey"]+"')"
end
sql += "\n"+sql_a.join(",\n");
#puts sql
new_db.query(sql)
printf "%d rows were returned\n", res.num_rows

res.free

# try to close the connection
old_db.close unless old_db == nil
new_db.close unless new_db == nil

