

require 'jira'
require 'pry'
require 'time'
require 'net/http'
require 'json'
require 'time'
require 'open-uri'
require 'cgi'
host ="https://qwinix.atlassian.net"
    username = "Ravi Shankar"
    password = "Qwinix123"
    project = "LOAN"
     to_do = "TO DO"
    open = "OPEN"
    reopened = "REOPENED"
    in_progress = "IN PROGRESS"
    dev_done = "DEV DONE"
    qa = "READY FOR QA"
    uat = "UAT"
    resolved = "RESOLVED"
    done = "DONE"
    closed = "CLOSED"

    sprint_name ="Sprint 0"

    options = {
      :username => username,
      :password => password,
      :context_path => '',
      :site     => host,
      :auth_type => :basic
    }

    SCHEDULER.every '1m', :first_in => 0 do |job|

      client = JIRA::Client.new(options)
      todo_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{to_do}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        todo_count+=1
      end
      open_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{open}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        open_count+=1
      end
      reopened_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{reopened}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        reopened_count+=1
      end
      in_progress_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{in_progress}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        in_progress_count+=1
      end
      dev_done_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{dev_done}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        dev_done_count+=1
      end
      qa_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{qa}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        qa_count+=1
      end
      uat_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{uat}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        uat_count+=1
      end
      resolved_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{resolved}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        resolved_count+=1
      end
      done_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{done}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        done_count+=1
      end
      closed_count = 0;
      client.Issue.jql("PROJECT = \"#{project}\" AND STATUS = \"#{closed}\" AND SPRINT = \"#{sprint_name}\"").each do |issue|
        closed_count+=1
      end
      total_points = todo_count + open_count + reopened_count + in_progress_count + done_count + dev_done_count + qa_count + uat_count + resolved_count + closed_count
      send_event("jira", { title: "Jira Story Details", todo: todo_count, open: open_count, reopened: reopened_count, inprogress: in_progress_count, qa: qa_count, uat: uat_count, dev_done: dev_done_count, resolved:resolved_count, done: done_count, closed: closed_count, total: total_points })
    end
  
    