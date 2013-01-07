class ActiveRecordSorter
  # include Reloadable
  def self.sort(collection, column, direction = :asc)
    if direction == :asc
      collection.sort {|a,b| a[column] <=> b[column]}
    else
      collection.sort {|a,b| b[column] <=> a[column]}
    end
  end
end
