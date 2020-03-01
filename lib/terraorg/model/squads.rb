require 'terraorg/model/squad'

class Squads
  SCHEMA_VERSION = 'v1'.freeze

  def initialize(parsed_data, people, gsuite_domain, slack_domain)
    version = parsed_data.fetch('version')
    raise "Unsupported squads schema version: #{version}" if version != SCHEMA_VERSION

    @squads = {}
    parsed_data.fetch('squads').each do |squad|
      id = squad.fetch('id')
      @squads[id] = Squad.new(id, squad, people, gsuite_domain, slack_domain)
    end
  end

  def all_names
    @squads.keys
  end

  def lookup!(name)
    @squads.fetch(name)
  end

  def to_h
    { 'version' => SCHEMA_VERSION, 'squads' => @squads.values.sort_by(&:id).map(&:to_h) }
  end
end
