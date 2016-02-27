$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
ROOT_DIR ||= File.expand_path(File.join(File.dirname(__FILE__), '..')).tr('/', '\\')

require 'logger'
require 'yaml'
require "cygwin"

def log
	unless @logger
		@logger = Logger.new(File.join(ROOT_DIR, "run.log"), 3, 1024000)
		@logger.level = Logger::DEBUG
		@logger.datetime_format = "%Y-%m-%d %H:%M:%S "
		@logger.info {''}
		@logger.info {'-----------------------'}
		@logger.info {''}
	end
	@logger
end

def run_jobs(branches, job, log_prefix)
  threads = []
  branches.each do |branch_name, node|
  	sleep 0.5
    t_id = "#{log_prefix}#{threads.size}"
    threads << Thread.new(job, t_id) do |job, t_id|
      Thread.current[:id]   = t_id
      Thread.current[:node] = node
			Thread.current[:branch_name] = branch_name
      Thread.current[:res]  = job.call node, t_id
    end
  end
  threads
end

def main_job(branches)
	threads_for_sync = run_jobs(branches, method(:job_on_node), 's')

	# wait for jobs to end
	threads_for_sync.map &:join

	log.info('PARALLEL END') {'all jobs are done now'}

	donts = []
	# and finally get results for all jobs
	threads_for_sync.each do |t|
	  puts "THREAD[#{t[:id]}] #{t[:branch_name]} #{t[:res]}"

	  case t[:res]
	  when :ok
	    # node_is_up t[:node]
	  when :notok
	    donts << t[:branch_name]
	  end
	end

	if donts.empty?
		puts "All done OK."
	else
		puts "Donts: #{donts.size}/#{branches.size}"
		donts.each do |name|
			puts name
		end
		IO.write('donts.txt', donts.join("\n"))
	end

	puts "The End."
end


def run
  before_all
	main_job YAML.load_file(CONFIG_PATH)['branches']
  log.info('END') {"== the end of iteration =="}
end

def for_one_node(node)
  before_all
	branches = {'alone' => node}
	main_job branches
  log.info('END') {"== the end of iteration =="}
end

################
case ARGV[0]
when '-run'
	run
when nil
	puts "Usage:"
	puts "main.rb -run"
	puts "main.rb user@ip"
else
	for_one_node(ARGV[0])
end
