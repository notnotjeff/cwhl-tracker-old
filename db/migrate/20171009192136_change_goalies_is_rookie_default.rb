class ChangeGoaliesIsRookieDefault < ActiveRecord::Migration[5.1]
  def change
  	change_column :goalies, :is_rookie, :boolean, :default => nil
  end
end
