DEFAULT_RETRY_COUNT = 10
DEFAULT_LESS_WAIT = 3 # in seconds
DEFAULT_MORE_WAIT = 5 # in seconds
DEFAULT_WAIT_LOOP_ITERATION = 10

##########################################
# Wait functions
##########################################
def com_wait_less
  sleep DEFAULT_LESS_WAIT
end

def com_wait_more
  sleep DEFAULT_MORE_WAIT
end

#Function to find and return element
def com_find_element obj_locator, do_iteration = "yes"
    raise "Object property is missing in helper file" if obj_locator.nil?
    i = 0
	if do_iteration.to_s.downcase == ("yes")
		itr_value = DEFAULT_RETRY_COUNT
	else
		itr_value = 1
	end
	while i < itr_value
		if (obj_locator.start_with?("//") or obj_locator.start_with?("./") or obj_locator.start_with?("(./") or obj_locator.start_with?("(/"))
			elementObj = $driver.find_element(:xpath, obj_locator)
			return elementObj
		elsif !(obj_locator.start_with?("//") or obj_locator.start_with?("./") or obj_locator.start_with?("(./") or obj_locator.start_with?("(/"))
			elementObj = $driver.find_element(obj_locator)
			return elementObj
		end
		i += 1
		com_wait_less
	end
    raise "No Element (#{obj_locator}) found in all #{i} iteration." if elementObj.nil?
end

#Function to click on elements
def com_click obj_locator, obj_name
	com_find_element(obj_locator).click
	puts "Successfully clicked on - #{obj_name} = #{obj_locator}"
end

#Function to set value on elements
def com_set obj_locator, obj_name, value
	element = com_find_element(obj_locator)
	element.clear
	element.send_keys(value)
    if obj_name.downcase == "password"
        puts "Successfully set Password - Encrypted on - #{obj_name} = #{obj_locator}"
    else
	    puts "Successfully set #{value} on - #{obj_name} = #{obj_locator}"
    end
end

#Function to get text of element
def com_get_text obj_locator
	return com_find_element(obj_locator).text
end

#Function to verify locator
def com_verify_element obj_locator, do_iteration: 'yes'
    i = 0
    if do_iteration.to_s.downcase == ("yes")
		itr_value = DEFAULT_WAIT_LOOP_ITERATION
	else
		itr_value = 1
	end
    ele = nil
	while i < itr_value
        begin
	        ele = com_find_element(obj_locator)
            return true if !ele.nil?
        rescue
        end
        i+=1
    end
    return false if ele.nil?
end

#Function to compare to values
def com_compare expected, actual, msg
  if (([true, false].include? expected) && ([true, false].include? actual))
    if (expect(actual).to be(expected))
      puts "Successfully passed #{msg}." + "<b> Actual Result: #{actual}, Expected Result: #{expected}</b>"
    end
  elsif (((expected.is_a? Integer) && (actual.is_a? Integer)) || ((expected.is_a? Float) && (actual.is_a? Float)))
    if (expect(actual).to eql(expected))
      puts "Successfully passed #{msg}." + "<b> Actual Result: #{actual}, Expected Result: #{expected}</b>"
    end
  elsif (expect(actual).to eq(expected))
    puts "Successfully passed #{msg}." + "<b> Actual Result: #{actual}, Expected Result: #{expected}</b>"
  end
end
