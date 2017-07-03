class ProcessLogsController < ApplicationController

	def read_logs
		RequestMetadata.process_log
	end

	def show_log_analytics
		@order = params[:order] || "count"
		@search = params[:search] || nil
		@attachment_count = AttachmentMetadata.count
		@request_metadata = RequestMetadata.search(@search, @order)
	end

	def download_attachments
		system('wget -r -l 0 --accept "foreman*.xz" http://files-sateng.rdu.redhat.com/sosreports/ -P /tmp/foreman_logs')
	end
end