class LogParserController

    def initialize
        @log_file = LogFile.new
        @current_view = FileDialogView.new
        @current_view.clear_display
        @current_view.set_cursor
        @current_view.display @log_file
    end

    def run
        while user_input = $stdin.getch do
            begin
                while next_chars = $stdin.read_nonblock(10) do
                    user_input = "#{user_input}#{next_chars}"
                end
            rescue IO::WaitReadable
            end 
            if @current_view.quittable? && user_input == "\e"
                break
            else
                parse_input user_input
            end
        end
    end

    def parse_input user_input
        case user_input
            when "\n", "\r"
                case @current_view.class.to_s
                    when "FileDialogView"
                        file_dialog_select
                end
            when "\e[A"
                case @current_view.class.to_s
                    when "FileDialogView"
                        file_dialog_move (-1)
                    when "LogListView"
                        log_list_move (-1)
                    when "SortFilterView"
                        move_filter_selection (-1)
                end
            when "\e[B"
                case @current_view.class.to_s
                    when "FileDialogView"
                        file_dialog_move 1
                    when "LogListView"
                        log_list_move 1
                    when "SortFilterView"
                        move_filter_selection 1
                end
            when "\t"
                case @current_view.class.to_s
                    when "SortFilterView"
                        move_filter_field 1
                end
            when "\e[C"
            when "\e[D"
            else
        end
    end

    def file_dialog_move increment
        @log_file.directory_index += increment

        if @log_file.directory_index < 0
            @log_file.directory_index = 0
        end

        if @log_file.directory_index > @log_file.directory.entries.length - 1
            @log_file.directory_index = @log_file.directory.entries.length - 1
        end

        if @log_file.directory_index < @log_file.list_start
            @log_file.list_start = @log_file.directory_index - $stdin.winsize[0] + 3
        elsif @log_file.directory_index > @log_file.list_start + $stdin.winsize[0] - 3
            @log_file.list_start = @log_file.directory_index
        end

        @current_view.update @log_file
    end

    def file_dialog_select
        case @log_file.select_directory_or_load_file
            when :directory
                @current_view.update @log_file
            when :file
                @current_view = LogListView.new
                @current_view.display @log_file
        end
    end

    def log_list_move increment
        @log_file.log_entry_index += increment

        if @log_file.log_entry_index < 0
            @log_file.log_entry_index = 0
        end

        if @log_file.log_entry_index > @log_file.log_entries.length - 1
            @log_file.log_entry_index = @log_file.log_entries.length - 1
        end

        if @log_file.log_entry_index < @log_file.list_start
            @log_file.list_start = @log_file.log_entry_index - $stdin.winsize[0] + 3
        elsif @log_file.log_entry_index > @log_file.list_start + $stdin.winsize[0] - 3
            @log_file.list_start = @log_file.log_entry_index
        end

        @current_view.update @log_file
    end

    def sort_select
        @current_view = SortFilterView.new
        @current_view.display @log_file.sort_fitler
    end
    
    def escape_sort_fitler
        @current_view = LogListView.new
        @current_view.display @log_file
    end

    def move_filter_field increment
        @log_file.sort_fitler.field_name_index += increment
        
        if @log_file.sort_filter.field_name_index >= @log_file.sort_filter.field_list.length
            @log_file.sort_filter.field_name_index = 0
        end

        @current_view.update @log_file.sort_filter
    end

    def move_filter_selection increment
        current_field = @log_file.sort_filter.field_name_index
        field_list = @log_file.sort_filter.field_list

        if field_list[current_field][1] != nil && field_list[current_field][1].class != String
            @log_file.sort_filter.field_selection[current_field] += increment

            if @log_file.sort_filter.field_selection[current_field] >= field_list[current_field][1].length
                @log_file.sort_filter.field_selection[current_field] = field_list[current_field][1].length - 1
            end

            if @log_file.sort_filter.field_selection[current_field] < 0
                @log_file.sort_filter.field_selection[current_field] = 0
            end

            @current_view.update @log_file.sort_filter
        end
    end

    def input_filter_field user_input
        current_field = @log_file.sort_filter.field_name_index

        if @log_file.sort_filter.field_list[current_field][1] == nil
            @log_file.sort_filter.field_list[current_field][1] = user_input
        elsif @log_file.sort_filter.field_list[current_field][1].class == String
            if user_input == "\u007F"
                @log_file.sort_filter.field_list[current_field][1].gsub!(/.$/, "")
            else
                @log_file.sort_filter.field_list[current_field][1] += user_input
            end
        end

        @current_view.update @log_file.sort_filter
    end
end