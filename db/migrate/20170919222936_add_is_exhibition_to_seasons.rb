class AddIsExhibitionToSeasons < ActiveRecord::Migration[5.1]
  def change
    add_column :seasons, :is_exhibition, :boolean
  end
end
