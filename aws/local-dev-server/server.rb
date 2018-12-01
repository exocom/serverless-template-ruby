require "socket"
server = TCPServer.new("localhost", 2345)

loop do
  socket = server.accept
  request = socket.gets
  path = request.split(" ")[1]

  STDERR.puts request

  if path == "/hello"
    str = StringIO.new
    $stdout = str

    ARGV[0] = ""
    load("./src/index.rb")

    if $stdout.string.length > 0
      res_hash = JSON.parse($stdout.string)
      body = JSON.generate(res_hash["body"])

      socket.print  "HTTP/1.1 200 OK\r\n" +
                    "Content-Type: applicaiton/json\r\n" +
                    "Content-Length: #{body.bytesize}\r\n" +
                    "Connection: close\r\n"
    end

  else
    ARGV[0] = nil
    body = '{message: "Not Found"}'
    socket.print "HTTP/1.1 404 NOT FOUND\r\n" +
                 "Content-Type: applicaiton/json\r\n" +
                 "Content-Length: #{body.bytesize}\r\n" +
                 "Connection: close\r\n"
  end

  socket.print "\r\n"
  socket.print body
  socket.close
end