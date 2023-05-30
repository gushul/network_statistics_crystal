require "http/client"
require "json"
require "json_mapping"

module Types
  class Header
    JSON.mapping(
      name: String,
      value: String
    )
  end

  class Endpoint
    JSON.mapping(
      method: {type: String, default: "GET"},
      url: String,
      headers: {type: Array(Header), nilable: true},
      body: {type: String, nilable: true}
    )
  end

  class RequestConfig
    JSON.mapping(
      endpoints: Array(Endpoint),
      num_requests: {type: Int32, default: 10},
      retry_failed: {type: Bool, default: false}
    )
  end
end

module NetwrokStatistics
  def self.collect_stats(json_body)
    data = Types::RequestConfig.from_json(json_body)

    endpoint_stats = [] of Hash(String, Float64 | Int32)

    data.endpoints.each do |endpoint|
      endpoint_stat = {"min" => -1.0, "max" => -1.0, "avg" => -1.0, "fails" => 0}
      endpoint_stats = [] of Hash(String, Float64 | Int32)
      total_time = 0.0

      headers = HTTP::Headers.new
      endpoint.headers.try &.each do |header|
        headers.add(header.name, header.value)
      end

      data.num_requests.times do |i|
        begin
          time_before = Time.monotonic
          response = HTTP::Client.exec(endpoint.method, endpoint.url, headers, endpoint.body || "")
          time_after = Time.monotonic
          elapsed = (time_after - time_before).total_milliseconds

          if response.status_code > 299
            endpoint_stat["fails"] += 1
            if !data.retry_failed
              break
            end
          else
            endpoint_stat["min"] = elapsed if elapsed < endpoint_stat["min"]
            endpoint_stat["max"] = elapsed if elapsed > endpoint_stat["max"]
            total_time += elapsed
          end
        end
      end

      endpoint_stat["avg"] = total_time / data.num_requests unless total_time == 0
      endpoint_stats << endpoint_stat
    end

    summary = {"min" => 0.0, "max" => 0.0, "avg" => 0.0, "fails" => 0}

    if endpoint_stats.any?
      summary["min"] = endpoint_stats.map { |e| e["min"] }.reject { |d| d == -1.0 }.min? || -1.0
      summary["max"] = endpoint_stats.map { |e| e["max"] }.max? || -1.0
      summary["avg"] = fetch_summary_avg(endpoint_stats.map { |e| e["avg"] }, endpoint_stats.size)

      summary["fails"] = endpoint_stats.map { |e| e["fails"] }.sum
    end

    {
      endpoints: endpoint_stats,
      summary:   summary,
    }
  end

  def self.fetch_summary_avg(avgs, endpoints_count)
    return -1 if avgs.empty?
    return -1 if avgs.uniq.last? == -1

    avgs.reject { |d| d == -1 }.sum / endpoints_count
  end
end
