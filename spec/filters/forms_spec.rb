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
  "mautic.form_on_submit": {
    "submission": {
      "id": 89,
      "ipAddress": [],
      "form": {
        "id": 4,
        "name": "lead points",
        "alias": "leadpoints",
        "category": null
      },
      "lead": {
        "id": 26,
        "points": 10,
        "color": null,
        "fields": {}
      },
      "trackingId": "dd4adafdabe75184bc206037a15d9f840adb5ec0",
      "dateSubmitted": "2015-08-26T01:30:34+00:00",
      "referer": "http://mautic-gh.com/index_dev.php/s/forms/preview/4",
      "page": null,
      "results": {
        "email": "email@formsubmit.com"
      }
    }
  },
  "timestamp": "2015-11-11T22:37:31+11:00"
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('submissionid')
      expect(subject).not_to include("lead")
      expect(subject).to include("form")
      expect(subject['submissionid']).to eq(89)
      expect(subject['leadid']).to eq(26)
      expect(subject['type']).to eq("form_submission")
      expect(subject['results']['email']).to eq ("email@formsubmit.com")
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
  "mautic.form_on_submit": {
    "submission": {
      "id": 34,
      "ipAddress": [],
      "form": {},
      "lead": {
        "id": 26
      },
      "results": {
        "email": "email@formsubmit.com"
        }
      }
    }   
  }'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include('submissionid')
      expect(subject).not_to include("lead")
      expect(subject).to include("form")
      expect(subject['submissionid']).to eq(34)
      expect(subject['leadid']).to eq(26)
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

    entered_fields = '{
  "mautic.form_on_submit": [
    {
      "submission": {
        "id": 893,
        "ipAddress": {
          "ipDetails": {
          }
        },
        "form": {
          "id": 25,
          "name": "nhkjhjk",
          "alias": "internalwe",
          "category": []
        },
        "lead": {
          "id": 89,
          "points": 0,
          "color": null,
          "fields": {}
        },
        "trackingId": null,
        "dateSubmitted": "2015-11-12T07:55:39+11:00",
        "referer": "http://mautic.ghgjhg.com.au/s/forms/preview/25",
        "page": null,
        "results": {
          "email": "example@afads.com"
        }
      },
      "timestamp": "2015-11-11T20:55:42+00:00"
    },
    {
      "submission": {
        "id": 894,
        "ipAddress": {
          "ipDetails": {
          }
        },
        "form": {
          "id": 25,
          "name": "jhjkhkj",
          "alias": "kjhjk",
          "category": []
        },
        "lead": {
          "id": 897,
          "points": 0,
          "color": null,
          "fields": {}
            
        },
        "trackingId": null,
        "dateSubmitted": "2015-11-12T07:55:42+11:00",
        "referer": "http://mautic.mjhjk.com/s/forms/preview/25",
        "page": null,
        "results": {
          "email": "jkhj@hgjh.com."
        }
      },
      "timestamp": "2015-11-11T20:55:43+00:00"
    }
  ]
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject[0]).to include('submissionid')
      expect(subject[0]).not_to include("lead")
      expect(subject[0]).to include("form")
      expect(subject[0]['submissionid']).to eq(893)
      expect(subject[0]['leadid']).to eq(89)
      expect(subject[0]['type']).to eq("form_submission")
      expect(subject[1]['submissionid']).to eq(894)
      expect(subject[1]['leadid']).to eq(897)
    end
  end  
end
