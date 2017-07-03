class RequestMetadata < ActiveRecord::Base
require 'log_read.rb'
include LogRead

	def self.process_log
		LogRead::ProcessLog.new
	end

	def self.search(search,order)
		if search
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").where("request_endpoint like ?", "%#{search}%").group("request_endpoint").order("count DESC") if order == "count"
		
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").where("request_endpoint like ?", "%#{search}%").group("request_endpoint").order("request_method") if order == "method"
		
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").where("request_endpoint like ?", "%#{search}%").group("request_endpoint").order("request_endpoint") if order == "endpoint"
		else
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").group("request_endpoint").order("count DESC") if order == "count"
		
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").group("request_endpoint").order("request_method") if order == "method"
			
			request_metadata = select("request_method, request_ip, request_timestamp, request_endpoint, count(*) as count").group("request_endpoint").order("request_endpoint") if order == "endpoint"
		end
		return request_metadata
	end

end