# nice -n19 the least priority on windows system
def bash_cmd(unix_cmd)
  "c:\\cygwin\\bin\\bash -l -c \"nice -n19 #{unix_cmd}\""
end

def cygwin_run(unix_cmd)
  puts "#{unix_cmd}"

  `#{bash_cmd(unix_cmd)}`
  puts "[ #{$?} ]"
  $? == 0 # was it OK?
end

def to_cygwin_path(win_path)
	drive, path = win_path.downcase.split(':')
	"/cygdrive/#{drive}#{path.tr('\\','/')}"
end

def check_connection_cmd(node)
  login_server, _ = node.split(':')
  "ssh #{login_server} echo ok"
end

# def run_on_remote(node, cmd)
#   login_server, rsynced_dir = node.split(':')
#   "ssh #{login_server} nice -n19 rm -rf #{rsynced_dir}/#{dirname}"
# end
