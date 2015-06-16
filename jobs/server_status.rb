#!/usr/bin/env ruby
require 'net/https'
require 'uri'
require 'time'



servers = [
	{name: 'Loan UAT', url: 'https://uat.loanlist.qwinixtech.com', method: 'https'},
	{name: 'Loan IT', url: 'http://it.loanlist.qwinixtech.com', method: 'http'}
]


SCHEDULER.every '1s', :first_in => 0 do |job|

	statuses = Array.new
	
	# check status for each server
	servers.each do |server|
		if server[:method] == 'https' || 'http' 
			uri = URI.parse(server[:url])
			http = Net::HTTP.new(uri.host, uri.port)
			if uri.scheme == "https"
				http.use_ssl=true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			if response.code == "200"
				result = 1
			else
				result = 0
			end
		elsif server[:method] == 'ping'
			ping_count = 10
			result = `ping -q -c #{ping_count} #{server[:url]}`
			if ($?.exitstatus == 0)
				result = 1
			else
				result = 0
			end
		end

		if result == 1
			arrow = "icon-ok-sign"
			color = "green"
		else
			arrow = "icon-warning-sign"
			color = "red"
		end

		statuses.push({label: server[:name], value: result, arrow: arrow, color: color})
	end

	# print statuses to dashboard
	send_event('server_status', {items: statuses})
end