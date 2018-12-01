#!./ruby/bin/ruby
require 'json'
# require 'bson'

$headers = {
    :'Access-Control-Allow-Origin' => '*',
    :'Access-Control-Allow-Credentials' => true,
    :'Content-Type' => 'application/json'
}

$changes = [
    {
        id: '5a1b5ae36758c40453e5e024',
        description: 'This is an example'
    },
    {
        id: '5a1b5b176758c40453e5e025',
        description: 'of a simple mock API'
    }
]

def get_changes(event:, context:)
  {
      statusCode: 200,
      body: JSON.generate({data: $changes}),
      headers: $headers
  }
end
