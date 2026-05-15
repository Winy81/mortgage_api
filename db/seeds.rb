puts "Seeding database..."

user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "Successfully seeded user: #{user.email} (Password: password123)"
