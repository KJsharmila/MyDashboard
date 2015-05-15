require 'net/http'
require 'json'
require 'time'

#JENKINS_URI = URI.parse("http://d-aws1-jenkins-1.d.movetv.com:8080/")
JENKINS_URI = URI.parse("http://your-jenkins-instance:8080/api/json")

JENKINS_AUTH = {
   'name' => "harshithyc",
   'password' => "harshith@qwinix"
}

# the key of this mapping must be a unique identifier for your job, the according value must be the name that is specified in jenkins
job_mapping = {
  'stallone_integration' => { :job => 'stallone' },
  'stallone_dev_deploy' => { :job => 'stallone dev deploy' },
  'stallone_qa_deploy' => { :job => 'stallone qa deploy' },
  'stallone_all_branches' => { :job => 'stallone_test' },

  'ottweb_integration' => { :job => 'ottweb' },
  'ottweb_dev_deploy' => { :job => 'ottweb_development_deploy' },
  'ottweb_qa_deploy' => { :job => 'ottweb_qa_deploy' },
  'ottweb_all_branches' => { :job => 'ottweb_test' },

  'catalogue_integration' => { :job => 'Product-Catalog' },
  'catalogue_dev_deploy' => { :job => 'Product-Catalog develop deploy' },
  'catalogue_qa_deploy' => { :job => 'Product-Catalog qa deploy' },
  'catalogue_all_branches' => { :job => 'Product-Catalog-Test' },

  'synacor_integration' => {:job => "synacor"},
  'synacor_dev_deploy' => {:job => "synacor_dev_deploy"},
  'synacor_qa_deploy' => {:job => "synacor_qa_deploy"},
  'synacor_all_branches' => {:job => "synacor_test"}

}

def get_number_of_failing_tests(job_name)
  info = get_json_for_job(job_name, 'lastCompletedBuild')
  info['actions'][4]['failCount']
end

def get_completion_percentage(job_name)
  build_info = get_json_for_job(job_name)
  prev_build_info = get_json_for_job(job_name, 'lastCompletedBuild')

  return 0 if not build_info["building"]
  last_duration = (prev_build_info["duration"] / 1000).round(2)
  current_duration = (Time.now.to_f - build_info["timestamp"] / 1000).round(2)
  return 99 if current_duration >= last_duration
  ((current_duration * 100) / last_duration).round(0)
end

def get_json_for_job(job_name, build = 'lastBuild')
  job_name = URI.encode(job_name)
  http = Net::HTTP.new(JENKINS_URI.host, JENKINS_URI.port)
  request = Net::HTTP::Get.new("/job/#{job_name}/#{build}/api/json")
  if JENKINS_AUTH['name']
    request.basic_auth(JENKINS_AUTH['name'], JENKINS_AUTH['password'])
  end
  response = http.request(request)
  JSON.parse(response.body)
end

job_mapping.each do |title, jenkins_project|
  current_status = nil
  SCHEDULER.every '5s', :first_in => 0 do |job|
    last_status = current_status
    build_info = get_json_for_job(jenkins_project[:job])

    current_status = build_info["result"]
    if build_info["building"]
      current_status = "BUILDING"
      percent = get_completion_percentage(jenkins_project[:job])
    elsif jenkins_project[:pre_job]
      pre_build_info = get_json_for_job(jenkins_project[:pre_job])
      current_status = "PREBUILD" if pre_build_info["building"]
      percent = get_completion_percentage(jenkins_project[:pre_job])
    end

    github_info = build_info["actions"].select{|s| s.has_key?("buildsByBranchName")}.first
    branch_info = github_info["lastBuiltRevision"]["branch"].first
    send_event(title, {
      currentResult: current_status,
      lastResult: last_status,
      timestamp: build_info["timestamp"],
      branch: branch_info["name"],
      sha1: branch_info["SHA1"].slice(0..8),
      url: build_info["url"],
      github: github_info["remoteUrls"].first.to_s,
      duration: (Time.mktime(0)+build_info["duration"].to_i/1000).strftime('%H:%M:%S'),
      value: percent
      })
  end
end
