begin
  require 'aggregate'
  have_aggregate = true
rescue LoadError => e
  warn "W: #{e} skipping #{__FILE__}"
end
require 'test/unit'
require 'raindrops'
require 'io/wait'

class TestLastDataRecv < Test::Unit::TestCase
  def test_accept_nonblock_agg
    s = Socket.new(:INET, :STREAM, 0)
    s.listen(128)
    addr = s.connect_address
    s.extend(Raindrops::Aggregate::LastDataRecv)
    s.raindrops_aggregate = []
    c = Socket.new(:INET, :STREAM, 0)
    c.connect(addr)
    c.write '.' # for TCP_DEFER_ACCEPT
    client, ai = s.accept_nonblock(exception: false)
    assert client.kind_of?(Socket)
    assert ai.kind_of?(Addrinfo)
    assert_equal 1, s.raindrops_aggregate.size
    assert s.raindrops_aggregate[0].instance_of?(Integer)
    client, ai = s.accept_nonblock(exception: false)
    assert_equal :wait_readable, client
    assert_nil ai
    assert_equal 1, s.raindrops_aggregate.size
    assert_raise(IO::WaitReadable) { s.accept_nonblock }
  end

  def test_accept_nonblock_one
    s = TCPServer.new('127.0.0.1', 0)
    s.extend(Raindrops::Aggregate::LastDataRecv)
    s.raindrops_aggregate = []
    addr = s.addr
    c = TCPSocket.new(addr[3], addr[1])
    c.write '.' # for TCP_DEFER_ACCEPT
    client = s.accept_nonblock(exception: false)
    assert client.kind_of?(TCPSocket)
    assert_equal 1, s.raindrops_aggregate.size
    assert s.raindrops_aggregate[0].instance_of?(Integer)
    client = s.accept_nonblock(exception: false)
    assert_equal :wait_readable, client
    assert_equal 1, s.raindrops_aggregate.size
    assert_raise(IO::WaitReadable) { s.accept_nonblock }
  end
end if RUBY_PLATFORM =~ /linux/ && have_aggregate
