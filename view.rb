class BasicView
end

class FileDialogView < BasicView
    def display
        puts "Select an Apache log file."
    end
end

class LogListView < BasicView
end

class SortFilterView < BasicView
end 