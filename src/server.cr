require "http/server"
require "./logic/network_statistics.cr"

server = HTTP::Server.new do |context|
  if context.request.path == "/collect_stats"
    body = context.request.body.not_nil!.gets_to_end
    result = NetwrokStatistics.collect_stats(body)

    context.response.content_type = "application/json"
    context.response.print result.to_json
  else
    context.response.content_type = "text/plain"
    context.response.status_code = 404
    context.response.print "Not Found\n"
  end
end

address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
