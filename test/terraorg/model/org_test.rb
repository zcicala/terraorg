require 'minitest/autorun'
require './lib/terraorg/model/org'
require './lib/terraorg/model/people'
require './lib/terraorg/model/squads'
require './lib/terraorg/model/platoons'

class OrgTest < Minitest::Test
    def setup
        gsuite_domain = "gsuite"
        slack_domain = "slack"
        people = People.new
        squads_data = File.read('./examples/squads.json')
        squads = Squads.new(JSON.parse(squads_data), people, gsuite_domain, slack_domain)
        platoons_data = File.read('./examples/platoons.json')
        platoons = Platoons.new(JSON.parse(platoons_data), squads, people, gsuite_domain)
        org_data = File.read('./examples/org.json')
        @org = Org.new(JSON.parse(org_data), platoons, squads, people, gsuite_domain)
      
    end

    def test_org_exists
        assert @org != nil
    end

    def test_org_tg_generation
        tf = @org.generate_tf_org

        puts tf

        assert tf != nil

        # Assert tf contains locale specific okta group
        assert tf.include?('resource "okta_group" "contoso-all-gb" {')

        # Assert tf contains locale specific gsuite group
        assert tf.include?('resource "gsuite_group" "contoso-all-gb" {')
    end
end
