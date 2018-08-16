class AddPpPointsPgToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :pp_points_pg, :float
  end
end
