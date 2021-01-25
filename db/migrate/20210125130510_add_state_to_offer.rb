class AddStateToOffer < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :state, :integer, default: 0
  end
end
