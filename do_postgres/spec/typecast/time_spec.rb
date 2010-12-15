# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'data_objects/spec/typecast/time_spec'

describe 'DataObjects::Postgres with Time' do
  behaves_like 'supporting Time'

  describe 'timestamp subsecond handling' do
    before do
      @connection.create_command(<<-EOF).execute_non_query
        update widgets set release_timestamp = '2010-12-15 14:32:08.49377-08' where id = 1
      EOF
      @connection.create_command(<<-EOF).execute_non_query
        update widgets set release_timestamp = '2010-12-15 14:32:28.942694-08' where id = 2
      EOF

      @command = @connection.create_command("SELECT release_timestamp FROM widgets WHERE id < ? order by id")
      @command.set_types(Time)
      @reader = @command.execute_reader(3)
      @reader.next!
      @values = @reader.values
    end

    it 'should handle variable subsecond lengths properly' do
      @values.first.should == Time.at(1292452328.49377)

      @reader.next!
      @values = @reader.values
      @values.first.should == Time.at(1292452348.942694)
    end
  end
end
