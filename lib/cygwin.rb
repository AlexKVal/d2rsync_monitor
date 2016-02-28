DEBUG = false

# nice -n19 the least priority on windows system
def bash_cmd(unix_cmd)
  "c:\\cygwin\\bin\\bash -l -c \"nice -n19 #{unix_cmd}\""
end

def cygwin_run(unix_cmd)
  puts "#{unix_cmd}" if DEBUG

  output = `#{bash_cmd(unix_cmd)}`

  if DEBUG
    puts "[ #{$?} ]"
    puts "  Reply: #{output}" unless output.to_s.strip.empty?
  end

  return output, $? == 0
end

def is_ok_cygwin_run(unix_cmd)
  cygwin_run unix_cmd
  $? == 0
end

def to_cygwin_path(win_path)
	drive, path = win_path.downcase.split(':')
	"/cygdrive/#{drive}#{path.tr('\\','/')}"
end

def check_connection_cmd(node)
  "ssh #{node} echo ok"
end

def is_connection_ok(node)
  is_ok_cygwin_run check_connection_cmd(node)
end
