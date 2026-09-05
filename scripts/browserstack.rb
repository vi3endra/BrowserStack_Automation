require 'yaml'
require 'rspec'
require 'selenium-webdriver'
require 'dotenv'
Dotenv.load

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'single'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../config/#{CONFIG_NAME}.config.yml")))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || CONFIG['key']


RSpec.configure do |config|
  config.around(:each) do |example|
    # 1. Fetch capabilites for .yml file
    raw_capabilities = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])

    # 2. Extract and remove the browser name so it doesn't leak into bstack:options
    browser_name = raw_capabilities.delete('browser') || raw_capabilities.delete('browserName') || 'chrome'

    # 3. Dynamically create the modern Selenium 4 Options class
    options = case browser_name.to_s.downcase
              when 'chrome' then Selenium::WebDriver::Chrome::Options.new
              when 'firefox' then Selenium::WebDriver::Firefox::Options.new
              when 'edge', 'microsoftedge' then Selenium::WebDriver::Edge::Options.new
              when 'safari' then Selenium::WebDriver::Safari::Options.new
              else Selenium::WebDriver::Chrome::Options.new
              end

    # Set the W3C compliant browser name
    options.browser_name = browser_name

    # 4. AUTOMATICALLY CONVERT LEGACY KEYS TO W3C KEYS
    w3c_bstack_options = {}
    raw_capabilities.each do |key, value|
      case key.to_s
      when 'build'
        w3c_bstack_options['buildName'] = value
      when 'name'
        w3c_bstack_options['sessionName'] = value
      when 'browserstack.debug'
        w3c_bstack_options['debug'] = value
      when 'browserstack.source'
        w3c_bstack_options['source'] = value
      else
        # Keep any other W3C keys like 'os', 'osVersion', 'browserVersion', etc.
        w3c_bstack_options[key] = value
      end
    end

    # 5. Attach the strictly validated options block
    options.add_option('bstack:options', w3c_bstack_options)

    $driver = Selenium::WebDriver.for(:remote,
      :url => "https://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
      :options => options)

    begin
      example.run
      if example.exception.nil?
        $driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "All steps executed cleanly!"}}')
      else
        # Capture the raw error message
        raw_error = example.exception.message
        # THE CRITICAL FIX: Replace all newlines/carriage returns with a space,
        # and escape any double quotes so it won't break the JSON structure.
        clean_error = raw_error.gsub(/[\r\n]+/, " ").gsub('"', "'")
        # Send the safely single-lined payload to BrowserStack
        $driver.execute_script("browserstack_executor: {\"action\": \"setSessionStatus\", \"arguments\": {\"status\":\"failed\", \"reason\": \"#{clean_error}\"}}")
      end
    rescue StandardError => e
      puts "Encountered a runtime driver script error: #{e.message}"
    ensure
      puts "Safely closing the BrowserStack remote session..."
      $driver.quit if $driver
    end
  end
end
