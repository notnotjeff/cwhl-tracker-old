class DeleteSeasonIdColumnFromTeams < ActiveRecord::Migration[5.1]
  def change
  	remove_column :teams, :season_id, :integer
  end
end
