class BasicView
    def clear_display
        print "\e[2J"
    end

    def set_cursor row = 1, column = 1
        print "\e[#{row};#{column}H"
    end

    def red text
        "\e[31;40m#{text}\e[0m"
    end

    def center text
        columns = $stdin.winsize[1]
        text_length = text.length
        column_location = columns / 2 - text_length / 2
        "\e[#{column_location}G#{text}"
    end
end

class FileDialogView < BasicView
    def quittable?
        true
    end

    def display log_file
        clear_display
        set_cursor
        puts red(center("Select an Apache log file."))
        update log_file
    end

    def update log_file
        set_cursor 2, 1
        log_file.directory.each_with_index do |directory_entry, index|

            if index < log_file.list_start
                next
            end

            if index > log_file.list_start + $stdin.winsize[0] - 3
                break
            end

            directory_entry = directory_entry + "/" if Dir.exist? (log_file.file_path + directory_entry)
            directory_entry = red(directory_entry) if index == log_file.directory_index

            print directory_entry + "\e[K\n"
        end

        print "\e[J"

        set_cursor $stdin.winsize[0], 1

        print red("Type 'q' to exit; up/down to move; return to select")
    end
end

class LogListView < BasicView
    def quittable?
        true
    end

    def display log_file
        clear_display
        set_cursor
        print red(center(log_file.file_name)) + "\n"
        update log_file
    end

    def update log_file
        set_cursor 2, 1
        log_file.log_entries.each_with_index do |entry, index|
            if index < log_file.list_start
                next
            end

            if entry.nil? || index > log_file.list_start + $stdin.winsize[0] - 3
                break
            end

            total_columns = $stdout.winsize[1] - 44
            text_column_size = total_columns / 3
            row = "\e[K" + (entry.time_stamp.nil? ? "" : entry.time_stamp.strftime("%m-%d %H:%M:%S")) +
                "\e[16G" + (entry.ip_address.nil? ? "": entry.ip_address.to_s) +
                "\e[#{17 + 16}G" + (entry.request.nil? ? "": entry.request.slice(0, text_column_size)) +
                "\e[#{text_column_size + 17 + 1}G" + (entry.response_code.nil? ? "": entry.response_code) +
                "\e[#{text_column_size + 17 + 1 + 4}G" + (entry.http_referer.nil? ? "": entry.http_referer) +
                "\e[#{2 * text_column_size + 17 + 2 + 4}G" + (entry.user_agent.nil? ? "": entry.user_agent) + 
                "\e[#{3 * text_column_size + 17 + 3 + 4}G" + (entry.file_size.nil? ? "": entry.file_size.slice(0, 7)) +
                "\n"
    
            if index == log_file.log_entry_index
                row = red(row)
            end

            print row
        end

        print "\e[J"

        set_cursor $stdin.winsize[0], 1

        print red("Type 'q' to exit, up/down to move, 's' to sort or filter");
    end
end

class SortFilterView < BasicView
    def quittable?
        false
    end

    def display sort_filter
        clear_display
        set_cursor
        print red(center("Sort and Filter"))
        update sort_filter
    end

    def update sort_filter
        set_cursor 2,1
        sort_filter.field_list.each_with_index do |field, index|
            if field_name[1] != nil && field_name[1].class != String
                label = field_name[0].to_s.gsub(/_/, "").upcase + ":"

                if index == sort_filter.field_name_index
                    label = red(label)
                end

                puts label

                field_name[1].each_with_index do |option, opt_index|
                    if opt_index == sort_filter.field_selection[index]
                        option = red(option)
                    end

                    puts "\e[K" + option.to_s
                end

                print "\e[K\n\e[K\n"
            else
                input = ""

                if field_name[1] != nil
                    input = field_name[1]
                end

                row = "Show only records where #{field_name[0].to_s.gsub(/_/, " ").upcase} contains: #{input}"
                if index == sort_filter.field_name_index
                    row = red(row)
                end

                puts "\e[K" + row
            end
        end

        print "\e[J"

        set_cursor $stdin.winsize[0], 1

        pritn red("Esc to return, Move up/down to select, Tab to change focus, Return to Apply")
    end
end 