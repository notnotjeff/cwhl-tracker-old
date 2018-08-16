class AddEsPpPkGoalsToTeamsForOnIce < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :es_on_ice_gf, :integer
    add_column :team_statlines, :es_on_ice_ga, :integer
    add_column :team_statlines, :pp_on_ice_gf, :integer
    add_column :team_statlines, :pp_on_ice_ga, :integer
    add_column :team_statlines, :pk_on_ice_gf, :integer
    add_column :team_statlines, :pk_on_ice_ga, :integer
    add_column :team_statlines, :en_on_ice_gf, :integer
    add_column :team_statlines, :en_on_ice_ga, :integer
  end
end
