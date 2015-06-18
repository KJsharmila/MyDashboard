require 'octokit'
require 'time'
SCHEDULER.every '10s', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => "c7f5649dffba2fe5b2483f473e7381bf3263b6ba")
  my_organization = "Qwinix"
  repo_name = []

  
  client.organization_repositories(my_organization).map do |repo| 
    repo_name << repo.name if repo.name == 'loan_list'
  end

  open_pull_requests = repo_name.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'open').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
        creator: "@" + pull.user.login,
        })
    end
    pulls
  }
  send_event('openPrs', { header: "Open Pull Requests", pulls: open_pull_requests })
end