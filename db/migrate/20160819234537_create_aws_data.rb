class CreateAwsData < ActiveRecord::Migration
  def change
    create_table :aws_data do |t|
      t.string :aws_access_key
      t.string :aws_secret_key
      t.text :manifest_template

      t.timestamps null: false
    end
  end
end
