require 'logstash/devutils/rspec/spec_helper'
require "logstash/filters/mautic"

RUBY_ENGINE == "jruby" and describe LogStash::Filters::Mautic do
  

  describe "Check the top-level fields" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
  "mautic.email_on_open": {
    "stat": {
      "id": 8,
      "emailAddress": "chad.windnagle@websparkinc.com",
      "ipAddress": [],
      "dateSent": "2015-08-26T01:34:37+00:00",
      "isRead": true,
      "isFailed": false,
      "dateRead": "2015-08-26T01:35:53+00:00",
      "retryCount": 0,
      "source": "email",
      "openCount": 1,
      "lastOpened": "2015-08-26T01:35:53+00:00",
      "sourceId": 5,
      "trackingHash": "55dd17adace91",
      "viewedInBrowser": false,
      "lead": {
        "id": 26,
        "points": 10,
        "color": "",
        "fields": {}
      },
      "email": {
        "id": 5,
        "name": "Email",
        "subject": "Email",
        "language": "en",
        "category": null,
        "fromAddress": null,
        "fromName": null,
        "replyToAddress": null,
        "bccAddress": null,
        "publishUp": null,
        "publishDown": null,
        "readCount": 1,
        "sentCount": 3,
        "revision": 1,
        "assetAttachments": [],
        "variantStartDate": null,
        "variantSentCount": 0,
        "variantReadCount": 0,
        "variantParent": null,
        "variantChildren": []
      }
    }
  },
  "timestamp": "2015-11-11T22:44:51+11:00"
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('emailopenid')
      expect(subject).not_to include("lead")
      expect(subject['emailopenid']).to eq(8)
      expect(subject['leadid']).to eq(26)
    end
  end

  describe "Check when not an array" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
      "mautic.email_on_open": {
        "stat": {
          "id": 5745,
          "lead": {"id" : 123}
        }
      }
      }'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('emailopenid')
      expect(subject).not_to include("lead")
      expect(subject['emailopenid']).to eq(5745)
      expect(subject['leadid']).to eq(123)
    end
  end    

  describe "Check when multiple" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
      "mautic.email_on_open": [{
        "stat": {
          "id": 5745,
          "lead": {"id" : 123}
        }
      },
    {
        "stat": {
          "id": 128,
          "lead": {"id" : 153}
        }
      }]
      }'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject[0]).to include('emailopenid')
      expect(subject[0]).not_to include("lead")
      expect(subject[0]['emailopenid']).to eq(5745)
      expect(subject[0]['leadid']).to eq(123)
      expect(subject[1]['emailopenid']).to eq(128)
      expect(subject[1]['leadid']).to eq(153)
    end
  end
end
