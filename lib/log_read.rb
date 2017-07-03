#!/usr/bin/env ruby
require 'open-uri'
require 'fileutils'

module LogRead
	
	class ProcessLog
		def initialize
			@matching_array = []
			process_attachment
		end

		def process_attachment
			archived_attachments = Dir["/tmp/foreman_logs/files-sateng.rdu.redhat.com/sosreports/*.xz"]
			archived_attachments.each do |attachment|

				file_name = File.basename attachment

				attachment_metadata = AttachmentMetadata.where(:attachment_label => file_name, :extracted => true)
				if !attachment_metadata.present? #for not to re iterate the logs if already read
					system(" for f in #{attachment}; do tar xf $f; done; ")
					
					prod_logs = []
					prod_logs = Dir["foreman-debug-*/var/log/foreman/production.*"]
	 
					prod_logs.each do |log_file|	
						text = File.open(log_file).read
						text.each_line do |line|
						        if line.match(/(.*Started.*\n)/)
						                @matching_array << line
						        end

						end

						@matching_array.each do |a|
					        regexed_str = a.match(/[0-9-\s:]+\[[a-z]+]\s\[[A-Z]]\sStarted\s(GET|PUT|POST|HEAD|DELETE|PATCH)\s(["'][\a-z]+['"])\s[a-z]+\s([0-9\.]+)\s[a-z]+\s(\d{4}-\d{2}-\d{2}\s[0-9]+:[0-9]+:[0-9]+\s[-+]\d{4})/)
					        begin
						        if regexed_str[2] && !regexed_str[2].match(/html|assets|png/)
							        method = regexed_str[1]
							        url = URI.parse(eval(regexed_str[2]))
							        endpoint = url.path
							        ip = regexed_str[3]
							        timestamp = regexed_str[4]
						        	if method == "GET" && endpoint.match(/hosts|node/)
						        		split_endpoint = endpoint.split("/")
						        		split_endpoint[2] = ":id"
						        		endpoint = split_endpoint.join("/")
						        	elsif endpoint.match(/foreman_tasks\/tasks|foreman_tasks\/dynflow|rhsm\/consumers/)
						        		split_endpoint = endpoint.split("/")
						        		split_endpoint[3] = ":id"
						        		endpoint = split_endpoint.join("/")
						        	elsif endpoint.match(/tasks/)
						        		split_endpoint = endpoint.split("/")
						        		split_endpoint[2] = ":id" if split_endpoint[1] == "tasks"
						        		endpoint = split_endpoint.join("/")
							    	end
							        RequestMetadata.create(:request_method => method, :request_endpoint => endpoint, :request_ip => ip, :request_timestamp => timestamp)
							    end
							rescue Exception => e
								p e 
							end
						end
					end
					AttachmentMetadata.create(:attachment_label => file_name, :extracted => true)
					system(" rm -rf foreman-debug-* ")
				end
			end
		end
	end
	
end

