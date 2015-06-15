
class Publisher
  attr_accessor :channel
  attr_accessor :connection


  # Sends a message to Rabbit by opening a connection using Bunny and closing it afterwards.
  # Written by Rayo as a quickfix to solve the session-timeout problem before Crunchbase/beta-launch.
  #
  # @author Andreas Rayo Kniep
  # @since 2015-01-31
  # @param routing_key  string, the name of the queue to send to
  # @param task_with_message  hash, task containing :message and :opts hash
  # @returns void
  def self.simple_publish( routing_key, task_with_message )
    Sinatra::Application.settings.logger.info( 'Sending message to Rabbit queue %s: %s' % [routing_key, task_with_message.inspect])
    bunny_session   = Bunny.new( Sinatra::Application.settings.rabbit_url )
    bunny_session.start.with_channel do |rabbit_channel|
      rabbit_channel.default_exchange.publish( task_with_message, routing_key: routing_key )
    end #with_channel do
    bunny_session.close
  end #self.simple_publish()



  # old stuff, currently unused
  # def self.publish(routing_key, message)
  #   channel.default_exchange.publish(message, routing_key: routing_key)
  # end

  # def self.channel
  #   @channel ||= @connection.create_channel
  # end

  # def self.connect(rabbit_url)
  #   @connection ||= Bunny.new(rabbit_url).tap do |c|
  #     c.start
  #   end
  # end
end