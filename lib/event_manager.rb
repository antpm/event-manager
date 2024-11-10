require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zip(zip)
  # if zip.nil?
  #	"00000"
  # elsif zip.length < 5
  #	zip.rjust(5, '0')
  # elsif zip.length > 5
  #	zip[0..4]
  # else
  #	zip
  # end

  # do everything from previous version in one line
  zip.to_s.rjust(5, '0')[0..4]
end

def legislator_by_zip(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('secret.key').strip

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(phone)
  cleaned = phone.tr('^0-9^', '')
  unless cleaned.length == 10 or cleaned.length == 11
    return "Invalid Phone Number"
  end

  if cleaned.start_with?('1') and cleaned.length == 11
    return cleaned[1..10]
  else
    return cleaned
  end
end

def tally_registration_hours(registrations)
  hours = Hash.new(0)
  registrations.each do |register|
    time = Time.strptime(register, "%m/%d/%Y %k:%M")
    hours[time.strftime("%k")] += 1
  end
  sorted_hours = hours.sort_by { |_, value| -value }.to_h
  sorted_hours
end

def tally_registration_days(registrations)
  days = Hash.new(0)
  registrations.each do |register|
    date = Date.strptime(register, "%D")
    days[Date::DAYNAMES[date.wday]] += 1
  end
  sorted_days = days.sort_by {|_, value| -value}.to_h
  sorted_days
end

puts 'Event Manager Initialized'
if File.exist? 'event_attendees.csv'
  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter
  contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
  registrations = []
  contents.each do |row|
    id = row[0]
    name = row[:first_name]
    phone = clean_phone_number(row[:homephone].to_s)
    zip = clean_zip(row[:zipcode])
    registrations.append(row[:regdate])
    legislators = legislator_by_zip(zip)
    form_letter = erb_template.result(binding)
    #save_thank_you_letter(id,form_letter)
  end
  registration_hours = tally_registration_hours(registrations)
  registration_days = tally_registration_days(registrations)
  p registration_hours
  p registration_days

  
else
  'File Not Found'
end
