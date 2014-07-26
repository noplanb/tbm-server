# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([
  {first_name: 'Admin', last_name: 'User' },
  {first_name: 'Farhad', last_name: 'Farzaneh', mobile_number: '14156020256'},
  {first_name: 'Sani', last_name: 'ElFishawy', mobile_number: '16502453537'},
  {first_name: 'Jill', last_name: 'Wernicke', mobile_number: '16502453539'},
  {first_name: 'Konstantin', last_name: 'Othmer', mobile_number: '16502484331'},
  {first_name: 'MotoG', last_name: 'Test', mobile_number: 'mg'},
  {first_name: 'Iphone5c', last_name: 'Test', mobile_number: 'ic'},
  {first_name: 'NexusRed', last_name: 'Test', mobile_number: 'nr'},
  {first_name: 'NexusBlack', last_name: 'Test', mobile_number: 'nb'},
  {first_name: 'Burns', last_name: 'Israelson', mobile_number: '0000000005'},
  {first_name: 'Mike', last_name: 'Ruf', mobile_number: '0000000006'},
  {first_name: 'Eva', last_name: 'Elfishawy', mobile_number: '0000000007'},
  {first_name: 'Deborah', last_name: 'Thornton', mobile_number: '0000000008'},
])


def connected_ids(first_name)
  connected_names = case first_name
    when 'Farhad'
      %w{Sani Konstantin NexusRed NexusBlack Iphone5c MotoG}
    when 'Sani'
      %w{Jill Eva Konstantin Farhad Burns Mike NexusBlack Iphone5c}
    when 'Jill'
      %w{Sani Eva}
    when 'Konstantin'
      %w{Sani Deborah Mike NexusRed NexusBlack MotoG Iphone5c Konstantin}
    when 'MotoG'
      %w{Konstantin NexusRed NexusBlack Iphone5c MotoG}
    when 'Iphone5c'
      %w{Sani Konstantin NexusRed NexusBlack MotoG Iphone5c}
    when 'NexusRed'
      %w{Sani Konstantin Iphone5c NexusBlack MotoG NexusRed}
    when 'NexusBlack'
      %w{Sani Konstantin Iphone5c NexusRed MotoG NexusBlack}
    when 'Burns'
      %w{Sani}
    when 'Mike'
      %w{Konstantin Sani}
    when 'Eva'
      %w{Jill Sani}
    when 'Deborah'
      %w{Konstantin}
    else
     []
  end
  connected_names.map{|n| puts n; User.find_by_first_name(n).id}
end

User.all.each do |u|
  puts "Creating connections for #{u.first_name}"
  connected_ids(u.first_name).each do |id|
    c = Connection.find_or_create(u.id, id)
    c.update_attribute(:status, :established)
  end
end