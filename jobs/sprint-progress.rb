require 'jira'
  require 'time'
  require 'net/http'
  require 'json'
  require 'time'
  require 'open-uri'
  require 'cgi'
  host = "https://qwinix.atlassian.net"
  username = "akumar"
  password = "Qwinix123"
  project = "LOAN"
  resolved = "RESOLVED"
  done = "DONE"
  closed = "CLOSED"

  sprint_name = "Sprint 6"

  options = {
    :username => username,
    :password => password,
    :context_path => '',
    :site     => host,
    :auth_type => :basic
  }

 SCHEDULER.every '1h', :first_in => 0 do |job|

    client = JIRA::Client.new(options)
    total_points = 0;
    client.Issue.jql("PROJECT = \"#{project}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
      total_points+=1
    end
    closed_points = 0;
    client.Issue.jql("PROJECT = \"#{project}\" AND SPRINT = \"#{sprint_name}\" AND STATUS = \"#{resolved}\"").each do |issue|
      closed_points+=1
    end
    client.Issue.jql("PROJECT = \"#{project}\" AND SPRINT = \"#{sprint_name}\" AND STATUS = \"#{done}\"").each do |issue|
      closed_points+=1
    end
    client.Issue.jql("PROJECT = \"#{project}\" AND SPRINT = \"#{sprint_name}\" AND STATUS = \"#{closed}\"").each do |issue|
      closed_points+=1
    end

    if total_points == 0
      percentage = 0
      moreinfo = "No sprint currently in progress"
    else
      percentage = (((closed_points/1.0)/(total_points/1.0))*100).to_i
      moreinfo = "#{closed_points.to_i} / #{total_points.to_i}"
    end

    send_event("sprint_progress", { title: "Sprint Progress", min: 0, value: percentage, max: 100, moreinfo: moreinfo })
  end