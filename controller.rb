class LogParserController

    def initialize
        @log_file = LogFile.new
        @current_view = FileDialogView.new
    end

    def run
        while true do
            @current_view.display
            break
        end
    end
end