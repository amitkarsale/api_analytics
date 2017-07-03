class CreateAttachmentMetadata < ActiveRecord::Migration
  def change
    create_table :attachment_metadata do |t|
		t.string :attachment_label
    	t.boolean :extracted
  		t.timestamps
    end
  end
end
