$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
ROOT_DIR ||= File.expand_path(File.join(File.dirname(__FILE__), '..')) #.tr('/', '\\')

DEBUG = false

def run_on(node, remote_cmd)
  identity_file = to_cygwin_path(File.join(ROOT_DIR, 'id_rsa'))
  cygwin_run("ssh -o LogLevel=quiet -i #{identity_file} #{node} '#{remote_cmd} 2>&1'")
end

def get_backup_nodes_for(node)
  remote_cmd = "cat #{to_cygwin_path("c:/d2rsync/config.yml")}"

  puts "server: #{node.split('@')[1]}"
  remote_reply, success = run_on node, remote_cmd

  return remote_reply unless success

  begin
    remoteConfig = YAML.load(remote_reply)
  rescue
    puts "server: #{node.split('@')[1]} has wrong config"
    return []
  end

  remoteConfig['nodes_up']
end

def get_link_date_for(station)
  node, cygwin_path = station.split(':')

  remote_cmd = "stat -c %x #{cygwin_path}" # get time of last access

  puts "station: #{node.split('@')[1]}"
  remote_reply, success = run_on node, remote_cmd

  return Date.parse('1980-01-01') unless success

  begin
    Date.parse(remote_reply)
  rescue ArgumentError
    Date.parse('1980-02-02')
  end
end

def check_link_dates(stations)
  stations_with_dates = stations.map do |station|
    _, ip = station.split(':')[0].split('@')
    {ip: ip, date: get_link_date_for(station)}
  end

  stations_with_dates.select {|st| st[:date] != Date.today}
end

def format_unconfirmed(unconfirmed)
  "Unconfirmed:\n  " + unconfirmed.map {|st| st.values.join(' ')}.join("\n  ")
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

  puts "#{res.length} #{ip}" if DEBUG

  unconfirmed = check_link_dates(res)
  return format_unconfirmed(unconfirmed) if unconfirmed.length > 0

  return :ok
end

require "parallel_runner"
