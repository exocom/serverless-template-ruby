#!./ruby/bin/ruby
require 'json'
require 'bson'

headers = {
    :'Access-Control-Allow-Origin' => '*',
    :'Access-Control-Allow-Credentials' => true,
    :'Content-Type' => 'application/json'
}

changes = [
    {
        id: '5a1b5ae36758c40453e5e024',
        description: 'This is an example'
    },
    {
        id: '5a1b5b176758c40453e5e025',
        description: 'of a simple mock API'
    }
]

get_changes = lambda do |event|
  puts JSON.generate(
      statusCode: 200,
      body: {data: changes},
      headers: headers
  )
end

post_changes = lambda do |event|
  begin
    event = JSON.parse(event)

    begin
      unless event.key?('body')
        raise "missing id"
      end

      body = event['body']

      unless body.key?('description')
        raise "missing description"
      end
      unless body.key?('id')
        raise "missing id"
      end

      id = BSON::ObjectId(body['id'])
    rescue Exception => e
      puts JSON.generate(
          statusCode: 400,
          body: {
              error: {
                  type: 'ApiError',
                  message: 'Invalid change provided. Please provide id and description.' + e.message
              }
          },
          headers: headers
      )
      return
    end

    if changes.find {|c| c[:id] == body['id']}
      puts JSON.generate(
          statusCode: 409,
          body: {
              error: {
                  type: 'ApiError',
                  message: 'A change with that Id already exits.'
              }
          },
          headers: headers
      )
      return
    end

    change = {
        id: body['id'],
        description: body['description']
    }

    changes.push(change)

    puts JSON.generate(
        statusCode: 201,
        body: {data: change},
        headers: headers
    )

  rescue Exception => e
    puts JSON.generate(
        statusCode: 500,
        body: {
            error: {
                type: 'ApiError',
                message: e&.message
            }
        },
        headers: headers
    )
  end
end

get_change = lambda do |event|
  begin
    event = JSON.parse(event)
    unless event.key?('pathParameters') || event['pathParameters'].key('changeId')
      raise "missing changeId"
    end

  rescue Exception => e
    puts JSON.generate(
        statusCode: 400,
        body: {
            error: {
                type: 'ApiError',
                message: 'Invalid change provided. Please provide id and description.' + e.message
            }
        },
        headers: headers
    )
    return
  end

  change_id = event['pathParameters']['changeId']
  change = changes.detect {|c| c[:id] == change_id}
  unless change
    puts JSON.generate(
        statusCode: 404,
        body: {
            error: {
                type: 'ApiError',
                message: 'No change was found with the given id.'
            }
        },
        headers: headers
    )
    return
  end

  puts JSON.generate(
      statusCode: 200,
      body: {data: change},
      headers: headers
  )
end

delete_change = lambda do |event|
  begin
    event = JSON.parse(event)
    unless event.key?('pathParameters') || event['pathParameters'].key('changeId')
      raise "missing changeId"
    end

  rescue Exception => e
    puts JSON.generate(
        statusCode: 400,
        body: {
            error: {
                type: 'ApiError',
                message: 'Invalid change provided. Please provide id and description.' + e.message
            }
        },
        headers: headers
    )
    return
  end

  change_id = event['pathParameters']['changeId']
  change = changes.detect {|c| c[:id] == change_id}
  unless change
    puts JSON.generate(
        statusCode: 404,
        body: {
            error: {
                type: 'ApiError',
                message: 'No change was found with the given id.'
            }
        },
        headers: headers
    )
    return
  end

  changes.delete(change)

  puts JSON.generate(
      statusCode: 204,
      headers: headers
  )
end

handler = eval(ARGV[0])
# TODO : check if handler null and then return error?
handler.call(ARGV[1])