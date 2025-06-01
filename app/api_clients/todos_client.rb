require "net/http"

class TodosClient
  # client = TodosClient.new(token: "api_key2")
  # client.todos
  # client.todo(1)
  # client.create_todo(description: "test")

  BASE_URI = "http://localhost:3000"

  attr_reader :token

  def initialize(token:)
    @token = token
  end

  def todos(**kwargs)
    get "/todos", query: kwargs
  end

  def todo(id)
    get "/todos/#{id}"
  end

  def create_todo(description:)
    post "/todos", body: { todo: { description: description } }
  end

  def update_todo(id, description:)
    patch "/todos/#{id}", body: { todo: { description: description } }
  end

  def delete_todo(id)
    delete "/todos/#{id}"
  end

  # def create_todo(**kwargs)
  #   post "/todos", body: kwargs
  # end

  private

  def get(path, query: {})
    make_request Net::HTTP::Get, path, query: query
  end

  def post(path, query: {}, body: {})
    make_request Net::HTTP::Post, path, query: query, body: body
  end

  def put(path, query: {}, body: {})
    make_request Net::HTTP::Put, path, query: query, body: body
  end

  def patch(path, query: {}, body: {})
    make_request Net::HTTP::Patch, path, query: query, body: body
  end

  def delete(path, query: {})
    make_request Net::HTTP::Delete, path, query: query
  end


  def make_request(klass, path, query: {}, headers: {}, body: {})
    uri = URI("#{BASE_URI}#{path}")
    uri.query = Rack::Utils.build_query(query) if query
    # telnet google.com
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.instance_of?(URI::HTTPS)

    request = klass.new(uri.request_uri, {
      "Authorization" => "Bearer #{token}",
      "Accept" => "application/json"
    })

    if body.present?
      request.body = body.to_json
      request["Content-Type"] = "application/json"
    end


    response = http.request(request)
    case response.code
    when 200, 201, 202, 203, 204
      JSON.parse(response.body) if response.body.present?
    else
      raise Error, response.body
    end
  end

  class Error < StandardError; end
end
