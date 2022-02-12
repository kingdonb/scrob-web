#!/usr/bin/env ruby
# builder.rb - generate k8s.yml in manifests/

require 'yaml'
require './lib/splat/splat'

command = 'bundle exec kuby -e production resources'

# from: https://coderedirect.com/questions/353836/fork-child-process-with-timeout-and-capture-output
array = []

# stdout, stderr pipes
rout, wout = IO.pipe
rerr, werr = IO.pipe

pid = Process.spawn(command, :out => wout, :err => werr)
_, status = Process.wait2(pid)

# close write ends so we could read them
wout.close
werr.close

@stdout = rout.readlines.join
@stderr = rerr.readlines.join

# dispose the read ends of the pipes
rout.close
rerr.close

@last_exit_status = status.exitstatus

if 0 == @last_exit_status && @stderr == ""
  YAML.load_stream(@stdout) { |doc| array << doc }

  # Filter any secrets and regular manifests into separate partitions
  secrets, manifests = array.partition { |x| x["kind"] == "Secret" }

  cluster_issuers, manifests =
    manifests.partition do |x|
      x["kind"] == "ClusterIssuer" ||
        x["kind"] == "Namespace"
    end

  # Discard the cluster issuer since we will be operating as a tenant
  cluster_issuers = ''

  # Write the secret files out
  Splat.write_namespaces_into_folder(target_dir: './secrets',
    namespaces_arr: Splat.sort_into_namespaces(secrets))

  # Write the manifest files out
  Splat.write_namespaces_into_folder(target_dir: './manifests/k8s',
    namespaces_arr: Splat.sort_into_namespaces(manifests))
else
  puts @stderr
  Kernel.exit(@last_exit_status)
end
