require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key =  File.read('secret.key').strip

def clean_zip(zip)
	#if zip.nil?
	#	"00000"
	#elsif zip.length < 5 
	#	zip.rjust(5, '0')
	#elsif zip.length > 5
	#	zip[0..4]
	#else
	#	zip
	#end
	
	#do everything from previous version in one line
	zip.to_s.rjust(5, '0')[0..4]
end

puts 'Event Manager Initialized'
if File.exist? "event_attendees.csv"
	contents = CSV.open("event_attendees.csv", headers:true, header_converters: :symbol)
	contents.each do |row|
		name = row[:first_name]
		zip = clean_zip(row[:zipcode])

		begin
		legislators = civic_info.representative_info_by_address(
    		address: zip,
    		levels: 'country',
    		roles: ['legislatorUpperBody', 'legislatorLowerBody']
  		)
  		legislators = legislators.officials
		rescue
			"You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
		end

		puts "#{name} #{zip} #{legislators}"
	end
else
	"File Not Found"
end