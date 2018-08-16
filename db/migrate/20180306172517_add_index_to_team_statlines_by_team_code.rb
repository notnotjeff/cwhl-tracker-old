class AddIndexToTeamStatlinesByTeamCode < ActiveRecord::Migration[5.1]
  def change
    add_index :team_statlines, :team_code
  end
end
