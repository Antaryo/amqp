# encoding: utf - 8

$LOAD_PATH.unshift File.expand_path("../../../../lib", __FILE__)

require "amqp"

t = Thread.new { EventMachine.run }
sleep(0.5)

connection = AMQP.connect
channel    = AMQP::Channel.new(connection)

requests_queue = channel.queue("amqpgem.examples.services.time", :exclusive => true, :auto_delete => true)
requests_queue.subscribe(:ack => true) do |metadata, payload|
  puts "[requests] Got a request #{metadata.message_id}. Sending a reply..."
  channel.default_exchange.publish(Time.now.to_s,
                                   :routing_key    => metadata.reply_to,
                                   :correlation_id => metadata.message_id,
                                   :immediate      => true)

  metadata.ack
end



Signal.trap("INT") { connection.close { EventMachine.stop } }
t.join