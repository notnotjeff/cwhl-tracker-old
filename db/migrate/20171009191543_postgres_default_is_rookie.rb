class PostgresDefaultIsRookie < ActiveRecord::Migration[5.1]
  def change
  	change_column :skaters, :is_rookie, :boolean, :null => true
  end
end
