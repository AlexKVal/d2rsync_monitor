$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
ROOT_DIR ||= File.expand_path(File.join(File.dirname(__FILE__), '..')) #.tr('/', '\\')

DEBUG = false

def run_on(node, remote_cmd)
  identity_file = to_cygwin_path(File.join(ROOT_DIR, 'id_rsa'))
  cygwin_run("ssh -o LogLevel=quiet -i #{identity_file} #{node} '#{remote_cmd} 2>&1'")
end

def get_backup_nodes_for(node)
  remote_cmd = "cat #{to_cygwin_path("c:/d2rsync/config.yml")}"

  remote_reply, success = run_on node, remote_cmd

  return remote_reply unless success

  YAML.load(remote_reply)['nodes_up']
end


############################
def before_all
	cygwin_run "rm -f /home/#{ENV['User']}/.ssh/known_hosts"
end

CONFIG_PATH = File.join(ROOT_DIR, 'config.yml')

def job_on_node(ip, t_id)
  node = "Admin@#{ip}"

  # return "cannot connect" unless is_connection_ok(node)

  res = get_backup_nodes_for node

  return res unless res.is_a? Array # some error

  return "The list of nodes is empty. Fix it!" if res.empty?

  puts "#{res.length} #{ip}"

  return :ok
end

require "parallel_runner"
