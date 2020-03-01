require 'terraorg/model/platoon'

class Platoons
  SCHEMA_VERSION = 'v1'.freeze

  def initialize(parsed_data, squads, people, gsuite_domain)
    version = parsed_data.fetch('version')
    raise "Unsupported schema version: #{version}" if version != SCHEMA_VERSION

    @platoons = {}
    parsed_data.fetch('platoons').each do |platoon_raw|
      p = Platoon.new(platoon_raw, squads, people, gsuite_domain)
      @platoons[p.id] = p
    end
  end

  def lookup!(name)
    @platoons.fetch(name)
  end

  def validate!
  end

  def all
    @platoons.values
  end

  def all_squad_names
    @platoons.values.map(&:squad_names).flatten
  end

  def all_names
    @platoons.keys
  end

  def members
    @platoons.map(&:members).flatten
  end

  def to_h
    { 'version' => SCHEMA_VERSION , 'platoons' => @platoons.values.sort_by(&:id).map(&:to_h) }
  end
end
