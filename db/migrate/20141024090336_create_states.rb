class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :state
      t.string :color_code
      t.boolean :active
    end

    rename_column :orders, :status, :state_id

    states = {}

    Order.all.each do |order|
      states[order.id] = order.state_id
      order.update_attribute :state_id, nil
    end

    change_column :orders, :state_id, :integer

    State.create([{state: 'Активен', color_code: 'orange', active: true}, {state: 'Подтверждён', color_code: 'blue', active: true}, {state: 'Оплачен', color_code: 'green', active: true}, {state: 'Отменён', color_code: 'red', active: false}, {state: 'Закрыт', color_code: 'black', active: false}])

    states.each do |key, value|
      Order.find(key).update_attribute(:state_id, State.find_by(state: value).try(:id))
    end

  end
end
