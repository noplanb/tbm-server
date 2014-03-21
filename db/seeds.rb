# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users = User.create([
  {first_name: 'Admin', last_name: 'User' },
  {first_name: 'Farhad', last_name: 'Farzaneh', mobile_number: '4156020256'},
  {first_name: 'Sani', last_name: 'ElFishawy', mobile_number: '6502453537'},
  {first_name: 'Jill', last_name: 'Wernicke', mobile_number: '6502453539'},
  {first_name: 'Konstantin', last_name: 'Othmer', mobile_number: '6502484331'}
])