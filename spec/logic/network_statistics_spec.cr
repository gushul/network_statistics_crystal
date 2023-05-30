require "../spec_helper"
require "http/client"
require "../../src/logic/network_statistics"

WebMock.allow_net_connect = false

describe "NetworkStatistics" do
  before_each do
    WebMock.reset
  end

  num_requests = 5
  retry_failed = true
  request_body = {
    "endpoints" => [
      {
        "method"  => "POST",
        "url"     => "http://example.com/info",
        "headers" => [
          {
            "name"  => "Cookie",
            "value" => "token=DEADCAFE",
          },
        ],
        "body" => "hello",
      },
    ],
    "num_requests" => num_requests,
    "retry_failed" => retry_failed,
  }.to_json

  it "calculates min, max, avg for successful requests" do
    WebMock.stub(:post, "http://example.com/info").to_return(status: 200, body: "OK")

    stats = NetwrokStatistics.collect_stats(request_body)

    stats[:endpoints].first["min"].should be_a(Float64)
    stats[:endpoints].first["max"].should be_a(Float64)
    stats[:endpoints].first["avg"].should be_a(Float64)
    stats[:endpoints].first["fails"].should eq 0

    stats[:summary]["min"].should be_a(Float64)
    stats[:summary]["max"].should be_a(Float64)
    stats[:summary]["avg"].should be_a(Float64)
    stats[:summary]["fails"].should eq 0
  end

  it "increments fail count for failed requests" do
    WebMock.stub(:post, "http://example.com/info").to_return(status: 500, body: "Internal Server Error")

    stats = NetwrokStatistics.collect_stats(request_body)

    stats[:endpoints].first["fails"].should eq num_requests
  end

  it "returns -1 for all stats if all requests timed out" do
    # Mock the endpoint to raise a timeout error
    WebMock.stub(:post, "http://example.com/info").to_return(status: 408)

    stats = NetwrokStatistics.collect_stats(request_body)

    stats[:endpoints].first["min"].should eq -1
    stats[:endpoints].first["max"].should eq -1
    stats[:endpoints].first["avg"].should eq -1
  end
end
