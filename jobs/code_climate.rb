require 'net/http'
require 'json'

SCHEDULER.every  '1m', :first_in => 0 do |job|
  repo_id = "5508fdbe695680039a004191" 
  api_token = "255887c05d5a64ea167e4d3455f63d8f71574536"

  uri = URI.parse("https://codeclimate.com/api/repos/#{repo_id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.set_form_data({api_token: api_token})
  response = http.request(request)
  stats = JSON.parse(response.body)
  current_gpa = stats['last_snapshot']['gpa'].to_f
  app_name = stats['name']
  covered_percent = stats['last_snapshot']['covered_percent'].to_f
  last_gpa = stats['previous_snapshot']['gpa'].to_f
  send_event("code-climate", {current: current_gpa, last: last_gpa, name: app_name, percent_covered: covered_percent })
end