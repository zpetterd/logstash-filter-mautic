require 'logstash/devutils/rspec/spec_helper'
require "logstash/filters/mautic"

RUBY_ENGINE == "jruby" and describe LogStash::Filters::Mautic do
  

  describe "Check the id field" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_new": [
    {"lead": {
        "id": 25,
        "points": 0,
        "dateIdentified": "2015-08-26T01:25:36.000Z"
        }
      }
    ]}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('leadid')
      expect(subject['leadid']).to eq(25)
      expect(subject['type']).to eq("lead")
      expect(subject).not_to include('fields')

    end
  end  

  describe "Check when no array is returned field" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_new": 
    {"lead": {
        "id": 80,
        "points": 0
        }
      }
    }'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('leadid')
      expect(subject['leadid']).to eq(80)
      expect(subject).not_to include('fields')

    end
  end  

    describe "Check the firstname field" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_new": [
    {"lead": {
        "id": 25,
        "points": 0,
        "fields": {"core": { "firstname": {"value" : "New"}}}
        }
      }
    ]}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include("firstname")
      expect(subject['firstname']).to eq("New")
      expect(subject).not_to include('fields')

    end
  end

  describe "Check the tags " do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_new": [
    {"lead": {
        "id": 25,
        "points": 0,
        "fields": {"core": {"firstname": {"value": "test"}}},
        "tags": ["test", "test2"]
        }
      }
    ]}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include("mautic_tags")
      expect(subject['mautic_tags'][0]).to eq("test")
      expect(subject['mautic_tags'][1]).to eq("test2")
      expect(subject).not_to include('fields')
      expect(subject).not_to include('fields')
    end
  end


    describe "Check the ip addresses field" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    #entered_fields = LogStash::Fixtures::MauticFixtures.newLeadEntry
    entered_fields = '{ "mautic.lead_post_save_new": [
    {"lead": {
        "id": 25,
        "points": 0,
        "fields": {"core": {"firstname": {"value": "test"}}},
        "ipAddresses" : {
          "123.14.945.113": {
            "ipDetails": {
              "city": "New Prague",
              "region": "Minnesota",
              "country": "United States",
              "latitude": 44.8978,
              "longitude": -93.382,
              "isp": "",
              "organization": "Communications Company, LLC",
              "timezone": "America/Chicago",
              "extra": "",
              "offset": "-5",
              "area_code": "0",
              "dma_code": "0",
              "country_code3": "USA",
              "postal_code": "8989",
              "continent_code": "NA",
              "country_code": "US",
              "region_code": "MN"
            }
          }, "89.14.945.55": {
            "ipDetails": {
              "city": "New Prague",
              "region": "Minnesota",
              "country": "United States",
              "latitude": 44.8978,
              "longitude": -93.382,
              "isp": "",
              "organization": "Communications Company, LLC",
              "timezone": "America/Chicago",
              "extra": "",
              "offset": "-5",
              "area_code": "0",
              "dma_code": "0",
              "country_code3": "USA",
              "postal_code": "8989",
              "continent_code": "NA",
              "country_code": "US",
              "region_code": "MN"
            }
          }
        }
        }
      }
    ]}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include("ipAddresses")
      expect(subject['ipAddresses'][0]).to eq("123.14.945.113")
      expect(subject['ipAddresses'][1]).to eq("89.14.945.55")
      expect(subject).not_to include('fields')
      expect(subject).not_to include('fields')


    end
  end 

  describe "Check multiple events" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_new": [
    {"lead": {
        "id": 25,
        "points": 0,
        "fields": {"core": {"firstname": {"value": "test"}}},
        "tags": ["test", "test2"]
        }
      },
      {"lead": {
        "id": 21,
        "points": 10,
        "fields": {"core": {"firstname": {"value": "test"}}},
        "tags": ["test", "test2"]
        }
      }
    ]}'

    sample entered_fields  do
      expect(subject[0]).to include('leadid')
      expect(subject[1]).to include('leadid')
      expect(subject[0]['leadid']).to eq(25)
      expect(subject[1]['leadid']).to eq(21)
      expect(subject[0]['points']).to eq(0)
      expect(subject[1]['points']).to eq(10)
      expect(subject[1]).not_to include('fields')

    end # end sample
  end


    describe "Check the id field" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{ "mautic.lead_post_save_update": [
    {"lead": {
        "id": 25,
        "points": 0,
        "fields": {"core": {"firstname": {"value": "test"}}},

        "dateIdentified": "2015-08-26T01:25:36.000Z"
        }
      }
    ]}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('leadid')
      expect(subject['leadid']).to eq(25)
      expect(subject).not_to include('fields')
    end
  end


  describe "Check updated lead" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
  "mautic.lead_post_save_update": {
    "lead": {
      "id": 25,
      "points": 0,
      "color": "",
      "fields": {"core": {"firstname": {"value": "test"}}},
      "lastActive": null,
      "owner": {
        "id": 1,
        "username": "drmmr763",
        "firstName": "Chad",
        "lastName": "Windnagle"
      },
      "ipAddresses": [],
      "dateIdentified": "2015-08-26T01:25:36+00:00",
      "preferredProfileImage": "gravatar"
    }
  },
  "timestamp": "2015-11-12T10:40:19+11:00"
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('leadid')
      expect(subject).not_to include('fields')
      expect(subject).to include('firstname')
      expect(subject['leadid']).to eq(25)
      expect(subject['type']).to eq("lead")
      expect(subject['firstname']).to eq("test")
      expect(subject).not_to include('fields')

    end
  end   


    describe "Check changed points" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
  "mautic.lead_points_change": {
    "lead": {
      "id": 26,
      "points": 10,
      "color": null,
      "fields": {},
      "lastActive": "2015-08-26T01:30:35+00:00",
      "owner": null,
      "ipAddresses": {
        "127.0.0.1": []
      },
      "dateIdentified": "2015-08-26T01:30:35+00:00",
      "preferredProfileImage": null
    },
    "points": {
      "old_points": 0,
      "new_points": 10
    }
  },
  "timestamp": "2015-11-13T15:38:10+11:00"
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('leadid')
      expect(subject).not_to include('fields')
      expect(subject['leadid']).to eq(26)
      expect(subject['type']).to eq("lead")
    end
  end          
end
