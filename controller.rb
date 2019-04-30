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
            if @current_view.quittable? && user_input == 'q'
                break
            else
                parse_input user_input
            end
        end
    end

    def parse_input user_input
        case user_input
            when "\n"
            when "\e[A"
                case @current_view.class.to_s
                    when "FileDialogView"
                        file_dialog_move (-1)
                end
            when "\e[B"
                case @current_view.class.to_s
                    when "FileDialogView"
                        file_dialog_move 1
                end
            when "\e[C"
            when "\e[D"
            else
        end
    end

    def file_dialog_move increment
        @log_file.directory_index += increment

        if @log_file.directory_index < @log_file.list_start
            @log_file.list_start = @log_file.directory_index - $stdin.winsize[0] + 3
        elsif @log_file.directory_index > @log_file.list_start + $stdin.winsize[0] - 3
            @log_file.list_start = @log_file.directory_index
        end

        @current_view.update @log_file
    end
end