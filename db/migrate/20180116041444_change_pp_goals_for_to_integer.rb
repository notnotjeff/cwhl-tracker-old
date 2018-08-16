class ChangePpGoalsForToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :team_statlines, :pp_goals_for, :integer
  end
end
