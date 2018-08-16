class MakeRookieDefaultToNil < ActiveRecord::Migration[5.1]
  def change
  	change_column_default(:skaters, :is_rookie, nil)
  end
end
