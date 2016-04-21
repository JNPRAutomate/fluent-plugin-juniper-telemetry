
##############################
## Supporting functions     ##
##############################

def epoc_to_sec(epoc)

  # Check if sec, usec or msec
  nbr_digit = epoc.to_s.size

  if nbr_digit == 10
    return epoc.to_i
  elsif nbr_digit == 13
    return (epoc.to_i/1000).to_i
  elsif nbr_digit == 16
    return (epoc.to_i/1000000).to_i
  end
  
  return epoc
end

def clean_up_name(name)

    ## Create a clean copy of Name and convert to string
    tmp = name.to_s.dup

    ## Clean up device name and interface name to remove restricted caracter
    tmp.gsub!('/', '_')
    tmp.gsub!(':', '_')
    tmp.gsub!('.', '_')

    return tmp
end

def build_record(type, data_to_build)

  if type.to_s == 'flat'

    record = {}

    # initialize variables
    name = ""
    sensor_value = ""

    ## Concatene all key/value into a string and stop at "value"
    data_to_build.each do |entry|
      entry.each do |key, value|

        if key == "value"
          sensor_value = value
          next
        end

        if name == ""
          name = key + "." + clean_up_name(value)
        else
          name = name + "." + key + "." + clean_up_name(value)
        end
      end
    end

    record = { name => sensor_value }
    return record

  elsif output_format.to_s == 'structured'

    record = {}
    ## Convert list into Hash
    ## Each entry on the list is a hash with 1 key/value
    data_to_build.each do |entry|
      entry.each do |key, value|
        record[key] = value
      end
    end

    return record

  elsif output_format.to_s == 'statsd'

      record = {}

      # initialize variables
      name = ""
      sensor_value = ""

      ## Concatene all key/value into a string, exclude device & stop at "value"
      data_to_build.each do |entry|
        entry.each do |key, value|

          if key == "value"
            sensor_value = value
            next
          elsif key == "device"
            next
          else
            if name == ""
              name = key + "." + clean_up_name(value)
            else
              name = name + "." + key + "." + clean_up_name(value)
            end
          end
        end
      end

      record[:statsd_type] = 'gauge'
      record[:statsd_key] = name.downcase
      record[:statsd_gauge] = sensor_value

      return record
  else
    $log.warn "Output_format '#{type.to_s}' not supported"
  end
end
