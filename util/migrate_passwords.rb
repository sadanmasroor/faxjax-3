#  Migrate plaintext passwords to salted hashes
# ./script/runner -e development util/migrate_passwords.rb
# change -e production on live site

User.find(:all).each do |u|
  print "#{u.name}: #{u.password}"
  u.set_password
  u.has_read_tos = true
  u.password_confirmation = u.password
  u.save!
  p "  ...Done"
end