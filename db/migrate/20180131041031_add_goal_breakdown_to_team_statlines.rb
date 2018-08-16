class AddGoalBreakdownToTeamStatlines < ActiveRecord::Migration[5.1]
  def change
    add_column :team_statlines, :gf_6v5, :integer
    add_column :team_statlines, :ga_6v5, :integer
    add_column :team_statlines, :gf_5v6, :integer
    add_column :team_statlines, :ga_5v6, :integer
    add_column :team_statlines, :gf_5v5, :integer
    add_column :team_statlines, :ga_5v5, :integer
    add_column :team_statlines, :gf_p_5v5, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :gf_5v4, :integer
    add_column :team_statlines, :ga_5v4, :integer
    add_column :team_statlines, :gf_4v5, :integer
    add_column :team_statlines, :ga_4v5, :integer
    add_column :team_statlines, :gf_4v4, :integer
    add_column :team_statlines, :ga_4v4, :integer
    add_column :team_statlines, :gf_p_4v4, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :gf_4v3, :integer
    add_column :team_statlines, :ga_4v3, :integer
    add_column :team_statlines, :gf_3v4, :integer
    add_column :team_statlines, :ga_3v4, :integer
    add_column :team_statlines, :gf_3v3, :integer
    add_column :team_statlines, :ga_3v3, :integer
    add_column :team_statlines, :gf_p_3v3, :decimal, precision: 5, scale: 2
    add_column :team_statlines, :gf_5v3, :integer
    add_column :team_statlines, :ga_5v3, :integer
    add_column :team_statlines, :gf_3v5, :integer
    add_column :team_statlines, :ga_3v5, :integer
    add_column :team_statlines, :gf_6v3, :integer
    add_column :team_statlines, :ga_6v3, :integer
    add_column :team_statlines, :gf_3v6, :integer
    add_column :team_statlines, :ga_3v6, :integer
    add_column :team_statlines, :gf_6v4, :integer
    add_column :team_statlines, :ga_6v4, :integer
    add_column :team_statlines, :gf_4v6, :integer
    add_column :team_statlines, :ga_4v6, :integer
  end
end
