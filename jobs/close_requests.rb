require 'octokit'
require 'time'
SCHEDULER.every '10m', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => "d04734e9f5a7d1cc9d81eaa5f987eb5f324edb28")
  my_organization = "Qwinix"
  repo_name = []
  client.organization_repositories(my_organization).map do |repo| 
    repo_name << repo.name if repo.name == 'loan_list'
  end

  close_pull_requests = repo_name.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'close').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
        creator: "@" + pull.user.login,
        })
    end
    pulls[0..2]
  }
  send_event('closedPrs', { header: "Close Pull Requests", pulls: close_pull_requests })
end