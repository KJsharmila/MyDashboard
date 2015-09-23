 require 'net/http'
require 'json'
require 'time'

JENKINS_URI ="http://jenkins.qwinixtech.com:8000/view/Loan%20List%20Project%20Pipeline/"

JENKINS_AUTH = {
  'name' => 'hshri',
  'password' => 'hema@qwinix!'
}

SCHEDULER.every '1s' do

  json = getFromJenkins(JENKINS_URI + 'api/json?pretty=true')

  failedJobs = Array.new
  succeededJobs = Array.new
  array = json['jobs']
  array.each {
    |job|

    next if job['color'] == 'disabled'
    next if job['color'] == 'notbuilt'
    next if job['color'] == 'blue'
    next if job['color'] == 'blue_anime'

    jobStatus = '';
    if job['color'] == 'yellow' || job['color'] == 'yellow_anime'
      jobStatus = getFromJenkins(job['url'] + 'lastUnstableBuild/api/json')
    elsif job['color'] == 'aborted'
      jobStatus = getFromJenkins(job['url'] + 'lastUnsuccessfulBuild/api/json')
    else
      jobStatus = getFromJenkins(job['url'] + 'lastFailedBuild/api/json')
    end

    culprits = jobStatus['culprits']

    culpritName = getNameFromCulprits(culprits)
    if culpritName != ''
     culpritName = culpritName.partition('<').first
   end

   failedJobs.push({ label: job['name'], value: culpritName})
 }
 
 failed = failedJobs.size > 0
 

 send_event('jenkinsBuildStatus', { failedJobs: failedJobs, succeededJobs: succeededJobs, failed: failed })

end

def getFromJenkins(path)

  uri = URI.parse(path)
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri.request_uri)
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)

  json = JSON.parse(response.body)
  return json
end

def getNameFromCulprits(culprits)
  culprits.each {
    |culprit|
    return culprit['fullName']
  }
  return ''
end