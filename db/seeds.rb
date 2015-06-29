# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all

(1..16).each { |n| User.create first_name: "T#{n}", last_name: "L#{n}", mobile_number: "#{n}" }

User.create first_name: 'NexusBlack', last_name: 'Test', mobile_number: 'nb'
User.create first_name: 'NexusRed', last_name: 'Test', mobile_number: 'nr'

def connected_ids(first_name)
  connected_names = case first_name
                    when 'NexusBlack'
                      %w(NexusRed)
                    else
                      []
                    end
  connected_names.map do |n|
    puts n
    User.find_by_first_name(n).id
  end
end

User.all.each do |u|
  puts "Creating connections for #{u.first_name}"
  connected_ids(u.first_name).each { |id| Connection.find_or_create(u.id, id) }
end

nr = User.find_by_first_name('NexusRed')
User.all.each { |u| Connection.find_or_create(nr.id, u.id) if u.last_name.match(/L\d/) }
