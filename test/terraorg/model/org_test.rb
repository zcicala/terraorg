
require 'rubygems'
require 'bundler/setup'

Bundler.setup(:default, :test)
require 'minitest/autorun'
require './lib/terraorg/model/org'
require './lib/terraorg/model/people'
require './lib/terraorg/model/squads'
require './lib/terraorg/model/platoons'

class OrgTest < Minitest::Test
    def setup
        
    @working_org =  File.read('./test/fixtures/working_org.json')
    @working_platoons =  File.read('./test/fixtures/working_platoons.json')
    @working_squads =  File.read('./test/fixtures/working_squads.json')
    @orphaned_associates_squads =  File.read('./test/fixtures/orphaned_associates_squads.json')
      
    end


    def test_platoons_tf_generation
        org = generate_org(@working_org, @working_platoons, @working_squads)
        tf = org.generate_tf_platoons

        #Make sure not null
        assert tf != nil

        #Make sure we're producing global squads Okta and Gsuite tf
        assert tf.include?('resource "okta_group" "contoso-squad-sales"')
        assert tf.include?('resource "gsuite_group_members" "contoso-squad-sales"')
        
        #Make sure we're producing locale squads Okta and Gsuite tf
        assert tf.include?('resource "gsuite_group" "contoso-squad-sales-gb"')
        assert tf.include?('resource "gsuite_group_members" "contoso-squad-sales-gb"')
    end

    def test_org_tf_generation
        org = generate_org(@working_org, @working_platoons, @working_squads)
        tf = org.generate_tf_org

        #Make sure not null
        assert tf != nil

        # Assert tf contains locale specific okta group
        assert tf.include?('resource "okta_group" "contoso-all-gb" {')

        # Assert tf contains locale specific gsuite group
        assert tf.include?('resource "gsuite_group" "contoso-all-gb" {')
    end

    def test_files_written
        org = generate_org(@working_org, @working_platoons, @working_squads)
        tf = org.generate_tf

        #Make sure we're generating the files we expect to generate
        assert File.exist?('auto.platoons.tf')
        assert File.exist?('auto.exception_squads.tf')
        assert File.exist?('auto.org.tf')        
    end

    def test_associate_without_squad
        org = generate_org(@working_org, @working_platoons, @orphaned_associates_squads)
        assert_output('', "ERROR: [\"associate1\"] are associates of squads but not members of any squad\n") {
            org.validate!(strict: false)
        }

        assert_output('', "") {
            org.validate!(strict: false, allow_orphaned_associates: true)
        }
            
    end

    def teardown
        FileUtils.rm_f('auto.platoons.tf') if File.exist?('auto.platoons.tf')
        FileUtils.rm_f('auto.exception_squads.tf') if File.exist?('auto.exception_squads.tf')
        FileUtils.rm_f('auto.org.tf') if File.exist?('auto.org.tf')
    end

    def generate_org(org_data, platoons_data, squads_data)
        gsuite_domain = "gsuite"
        slack_domain = "slack"
        people = People.new
        squads = Squads.new(JSON.parse(squads_data), people, gsuite_domain, slack_domain)
        platoons = Platoons.new(JSON.parse(platoons_data), squads, people, gsuite_domain)
        return Org.new(JSON.parse(org_data), platoons, squads, people, gsuite_domain)
    end

end
