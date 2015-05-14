require 'jira'
host = "https://qwinix.atlassian.net/secure/RapidBoard.jspa?rapidView=77&projectKey=Loan"
username = "aKumar"
password = "Qwinix123"
project = "Loan"
status = "UAT"
options = {
  :username => username,
  :password => password,
  :context_path => '',
  :site     => host,
  :auth_type => :basic
}

SCHEDULER.every'1m', :first_in => 0 do |job|
  client = JIRA::Client.new(options)
  num = 0;
  
  client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{status}\" AND sprint in openSprints(\"Loan\")").each do |issue|
    num+=1
  end
  send_event('jira1', { current: num})
end
