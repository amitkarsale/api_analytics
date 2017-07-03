class CreateRequestMetadata < ActiveRecord::Migration
  def change
    create_table :request_metadata do |t|
    	t.string :request_method
    	t.string :request_endpoint
    	t.string :request_ip
    	t.datetime :request_timestamp
  		t.timestamps
    end
  end
end
