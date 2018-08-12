require 'typhoeus/adapters/faraday'

module Clients
  class ApiClient

    def self.get(request, connection = nil)

      Rails.logger.info("<?==?> GET REQUEST: #{request.inspect}")
      connection = Faraday.new request[:base_url] if connection.blank?

      return connection.get do |req|
        req.url request[:api_url]
        req.headers = request[:headers] if request[:headers].present?
        req.params = request[:query_params]
      end
    end

    def self.post(request, connection = nil)

      Rails.logger.info("<?==?> POST REQUEST: #{request.inspect}")
      connection = Faraday.new request[:base_url] if connection.blank?
      return connection.post do |req|
        req.url request[:api_url]
        req.headers = request[:headers] if request[:headers].present?
        req.body = request[:payload_body]
      end
    end

    def self.parallel_requests(base_url, requests)
      connection = Faraday.new(url: base_url) do |faraday|
        faraday.adapter :typhoeus
      end

      responses = []

      connection.in_parallel do
        requests.each do |request|
          responses << ((request[:verb] == :post) ? ApiClient.post(request, connection) :
                                  ApiClient.get(request, connection))
        end
      end

      return responses
    end
  end
end
