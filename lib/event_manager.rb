require 'csv'

def clean_zip(zip)
	if zip.nil?
		"00000"
	elsif zip.length < 5 
		zip.rjust(5, '0')
	elsif zip.length > 5
		zip[0..4]
	else
		zip
	end
end

puts 'Event Manager Initialized'
if File.exist? "event_attendees.csv"
	contents = CSV.open("event_attendees.csv", headers:true, header_converters: :symbol)
	contents.each do |row|
		name = row[:first_name]
		zip = clean_zip(row[:zipcode])

		puts "#{name} #{zip}"
	end
else
	"File Not Found"
end