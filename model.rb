require "io/console"
require "ipaddr"

class LogFile
    attr_accessor   :file_name, :file_path, :log_entries, :directory, 
                    :directory_index, :log_entry_index, :list_start, :sort_filter

    def initialize
        cd "./"
        @log_entries = Array.new
        @sort_filter = SortFilter.new
    end

    def cd path
        if Dir.exist?(path)
            @file_path = path
            @directory = Dir.new(@file_path)
            @directory_index = 0
            @list_start = 0
            true
        else
            false
        end
    end

    def select_directory_or_load_file
        if cd(
            @file_path + 
            @directory.entries[@directory_index] + 
            "/"
        )
            :directory
        else
            if load_file
                :file
            end
        end
    end

    def load_file
        if File.file?(
            @file_path +
            @directory.entries[@directory_index]
        )
            @file_name = @directory.entries[@directory_index]

            log_array = IO.readlines(@file_path + @file_name)

            log_array.each_with_index do |log, index|
                @log_entries[index] = LogEntry.new log
            end

            @log_entry_index = 0

            @list_start = 0

            true
        else
            false
        end
    end
end

class LogEntry
    attr_accessor   :ip_address, :time_stamp, :request,
                    :response_code, :file_size, :http_referer,
                    :user_agent

    def initialize row=nil
        if row
            row.gsub!(/[ \t]+/, ' ')
            match_data = parse_row row
            set_properties match_data
        end
    end

    def parse_row row
        regex = /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\S*) (\S*) \[(\d\d)\/([^\/]*)\/(\d{4}):(\d\d):(\d\d):(\d\d) [\+-]\d{4}\] "([^"]*)" (\S+) (\S+)/

        regex.match row
    end

    def set_properties match_data
        unless match_data.nil?
            @time_stamp = Time.gm match_data[6], match_data[5], match_data[4], match_data[7], match_data[8], match_data[9]
            @ip_address = match_data[1].nil? ? "" : (IPAddr.new match_data[1])
            @request = match_data[10].nil? ? "" : match_data[10]
            @response_code = match_data[11].nil? ? "" : match_data[11]
            @file_size = match_data[12].nil? ? "" : match_data[12]
            @http_referer = ""
            @user_agent = ""
        end
    end
end

class SortFilter
    attr_accessor :field_list, :field_name_index, :field_selection

    def initialize
        @filed_list = [
            [:sort_by, [:non, :time_stamp, :ip_address, :file_size]],
            [:sort_direction, [:asc, :desc]],
            [:time_stamp],
            [:ip_address],
            [:request]
        ]
        @field_name_index = 0
        @field_selection = [0, 0]
    end

    def apply_selections log_file
        if @field_selection[0] != 0
            if @field_selection[1] == 0
                log_file.log_entries.sort! do |entry_a, entry_b|
                    entry_a.send(@field_list[0][1][@field_selection][0]).to_i
                end
            else
                log_file.log_entries.sort! do |entry_a, entry_b|
                    entry_b.send(@field_list[0][1][@field_selection[0]]).to_i <=> 
                    entry_a.send(@field_list[0][1][@field_selection[0]]).to_i
                end
            end
        end
    end
end