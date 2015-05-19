require 'octokit'

SCHEDULER.every '10m', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => "d47e6387d6ddc4437707eaa439643a8460f91f69")
  my_organization = "Qwinix"
  repo_name = []
  client.organization_repositories(my_organization).map do |repo| 
    repo_name << repo.name if repo.name == 'loan_list'
  end
  repos = client.organization_repositories(my_organization).map { |repo| repo.name }

  open_pull_requests = repos.inject([]) { |pulls, repo|
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