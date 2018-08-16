class AddLogoUrlToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :logo_url, :string
  end
end
