
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
        
      
    end


    def test_platoons_tf_generation
        org = generate_org($WORKING_ORG, $WORKING_PLATOONS, $WORKING_SQUADS)
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
        org = generate_org($WORKING_ORG, $WORKING_PLATOONS, $WORKING_SQUADS)
        tf = org.generate_tf_org

        #Make sure not null
        assert tf != nil

        # Assert tf contains locale specific okta group
        assert tf.include?('resource "okta_group" "contoso-all-gb" {')

        # Assert tf contains locale specific gsuite group
        assert tf.include?('resource "gsuite_group" "contoso-all-gb" {')
    end

    def test_files_written
        org = generate_org($WORKING_ORG, $WORKING_PLATOONS, $WORKING_SQUADS)
        tf = org.generate_tf

        #Make sure we're generating the files we expect to generate
        assert File.exist?('auto.platoons.tf')
        assert File.exist?('auto.exception_squads.tf')
        assert File.exist?('auto.org.tf')        
    end

    def test_associate_without_squad
        org = generate_org($WORKING_ORG, $WORKING_PLATOONS, $ORPHANED_ASSOCIATE_SQUADS)
        assert_output('', "ERROR: associate1 are associates of squads but not members of any squad\n") {
            org.validate!(strict: false)
        }

        assert_output('', "") {
            org.validate!(strict: false, allow_orhpaned_associates: true)
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

    $WORKING_ORG =  <<-JSON
            {
        "exception_people": [
            {
            "location": "US",
            "members": [
                "exception1"
            ]
            }
        ],
        "exception_squads": [],
        "id": "contoso",
        "manager": "rchen",
        "manager_location": "US",
        "metadata": {},
        "name": "Contoso",
        "platoons": [
            "sprockets",
            "widgets"
        ],
        "version": "v1"
        }
    JSON

    $WORKING_PLATOONS =  <<-JSON
    {
        "platoons": [
          {
            "id": "sprockets",
            "manager": "manager2",
            "name": "Sprockets",
            "squads": [
              "legal",
              "logistics"
            ]
          },
          {
            "id": "widgets",
            "manager": "manager1",
            "name": "Widgets",
            "squads": [
              "marketing",
              "sales"
            ]
          }
        ],
        "version": "v1"
      }
      
    JSON

    $WORKING_SQUADS =  <<-JSON
    {
  "squads": [
    {
      "id": "legal",
      "metadata": {
        "epo": "epo4",
        "manager": "manager5",
        "pm": [
          "pm1"
        ],
        "slack": "#legal",
        "sme": "sme8"
      },
      "name": "Legal",
      "team": [
        {
          "location": "US",
          "members": [
            "member1",
            "member2"
          ]
        }
      ]
    },
    {
      "id": "logistics",
      "metadata": {
        "epo": "epo9",
        "manager": "manager11",
        "pm": [
          "pm9"
        ],
        "slack": "#logistics",
        "sme": "sme9"
      },
      "name": "Logistics",
      "team": [
        {
          "location": "CN",
          "members": [
            "member55",
            "member56"
          ]
        }
      ]
    },
    {
      "id": "marketing",
      "metadata": {
        "manager": "manager2",
        "pm": [
          "pm2"
        ],
        "slack": "#marketing",
        "sme": "sme2"
      },
      "name": "Marketing",
      "team": [
        {
          "location": "FR",
          "members": [
            "member3",
            "member4"
          ]
        }
      ]
    },
    {
      "id": "sales",
      "metadata": {
        "epo": "epo1",
        "manager": "epo2",
        "pm": [
          "pm1"
        ],
        "slack": "#sales",
        "sme": "sme1"
      },
      "name": "Sales",
      "team": [
        {
          "location": "GB",
          "members": [
            "member8",
            "member9"
          ]
        }
      ]
    }
  ],
  "version": "v1"
}

    JSON

    $ORPHANED_ASSOCIATE_SQUADS =  <<-JSON
    {
  "squads": [
    {
      "id": "legal",
      "metadata": {
        "epo": "epo4",
        "manager": "manager5",
        "pm": [
          "pm1"
        ],
        "slack": "#legal",
        "sme": "sme8"
      },
      "name": "Legal",
      "team": [
        {
          "location": "US",
          "members": [
            "member1",
            "member2"
          ]
        }
      ]
    },
    {
      "id": "logistics",
      "metadata": {
        "epo": "epo9",
        "manager": "manager11",
        "pm": [
          "pm9"
        ],
        "slack": "#logistics",
        "sme": "sme9"
      },
      "name": "Logistics",
      "team": [
        {
          "location": "CN",
          "members": [
            "member55",
            "member56"
          ]
        }
      ]
    },
    {
      "id": "marketing",
      "metadata": {
        "manager": "manager2",
        "pm": [
          "pm2"
        ],
        "slack": "#marketing",
        "sme": "sme2"
      },
      "name": "Marketing",
      "team": [
        {
          "location": "FR",
          "associates":[
              "associate1"
          ],
          "members": [
            "member3",
            "member4"
          ]
        }
      ]
    },
    {
      "id": "sales",
      "metadata": {
        "epo": "epo1",
        "manager": "epo2",
        "pm": [
          "pm1"
        ],
        "slack": "#sales",
        "sme": "sme1"
      },
      "name": "Sales",
      "team": [
        {
          "location": "GB",
          "members": [
            "member8",
            "member9"
          ]
        }
      ]
    }
  ],
  "version": "v1"
}

    JSON

end
