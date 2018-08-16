class ChangePpGoalsAgainstToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :team_statlines, :pp_goals_against, :integer, using: 'pp_goals_against::integer'
  end
end
