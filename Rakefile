require 'rake'
require 'parallel'
require 'rspec/core/rake_task'

# Define the number of parallel browser environments to spin up
NUM_PARALLEL = 3

# Create a single task that groups and executes all browser tasks concurrently
multitask :parallel => (1..NUM_PARALLEL).map { |id| "browser_thread:#{id}" }

namespace :browser_thread do
  (1..NUM_PARALLEL).each do |task_id|
    desc "Execute test suite on Browser Stack Target Profile ##{task_id}"
    task task_id.to_s.to_sym do
      # Isolate environment variables to this specific browser process shell
      task_env = {
        "TASK_ID"     => (task_id - 1).to_s,
        "name"        => "parallel_test",
        "CONFIG_NAME" => "parallel"
      }

      # ENV["TASK_ID"] = (task_id - 1).to_s
      # ENV['name'] = "parallel_test"
      # ENV['CONFIG_NAME'] = "parallel"

      puts "🚀 Spinning up Browser Thread ##{task_id} (TASK_ID: #{task_env['TASK_ID']})..."

      # Run rspec as an isolated system shell command. 
      # If one browser thread encounters a test failure, it will NOT abort the others.
      # Instruct RSpec to find and execute ALL .rb files within the spec directory
      success = system(task_env, "bundle exec rspec spec/*.rb --format documentation")
      
      unless success
        puts "❌ Browser Thread ##{task_id} finished with test execution failures."
      end
    end
  end
end

# Make :parallel the default action when you just type 'rake'
task :default => :parallel
