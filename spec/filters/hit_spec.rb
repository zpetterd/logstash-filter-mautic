require 'logstash/devutils/rspec/spec_helper'
require "logstash/filters/mautic"

RUBY_ENGINE == "jruby" and describe LogStash::Filters::Mautic do
  

  describe "Check a basic hit" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
  "mautic.page_on_hit": {
    "hit": {
      "dateHit": "2015-08-26T01:32:39+00:00",
      "dateLeft": null,
      "page": {
        "id": 1,
        "title": "PageHit",
        "alias": "pagehit",
        "category": null
      },
      "redirect": null,
      "email": null,
      "lead": {
        "id": 26,
        "points": 10,
        "color": null,
        "fields": {}
      },
      "ipAddress": [],
      "country": null,
      "region": null,
      "city": null,
      "isp": null,
      "organization": null,
      "code": 200,
      "referer": null,
      "url": "http://mautic-gh.com/index_dev.php/pagehit",
      "urlTitle": null,
      "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36",
      "remoteHost": "localhost",
      "pageLanguage": "en",
      "browserLanguages": [
        "en-US",
        "en;q=0.8"
      ],
      "trackingId": "833fecc93e16d37baf1530df643b6a8b10714c65",
      "source": null,
      "sourceId": null
    }
  },
  "timestamp": "2015-11-11T22:42:59+11:00"
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject).to include("leadid")
      expect(subject).not_to include("lead")
      expect(subject).to include("url")
      expect(subject['leadid']).to eq(26)
      expect(subject['code']).to eq(200)
      expect(subject['type']).to eq("page_hit")
    end
  end 

    describe "Check multiple hits" do
    let(:config) do <<-CONFIG
      filter {
        mautic {
          source => "message"
        }
      }
    CONFIG
    end

    entered_fields = '{
  "mautic.page_on_hit": [
    {
      "hit": {
        "dateHit": "2015-08-26T01:32:39+00:00",
        "dateLeft": null,
        "lead": {
          "id": 26,
          "points": 10,
          "color": null
        },
        "code": 200,
        "referer": null,
        "url": "http://mautic-gh.com/index_dev.php/pagehit",
        "urlTitle": null
      }
    },
    {
      "hit": {
        "dateHit": "2015-08-26T01:32:39+00:00",
        "dateLeft": null,
        "lead": {
          "id": 70,
          "points": 10,
          "color": null
        },
        "code": 400,
        "referer": null,
        "url": "http://mautic-gh.com/index_dev.php/pagehit",
        "urlTitle": null
      }
    }
  ]
}'
    #it "should contain points"
    sample entered_fields  do
      #insist { subject["points"] } == 25
      expect(subject[0]).to include("leadid")
      expect(subject[0]).to include("url")
      expect(subject[0]['leadid']).to eq(26)
      expect(subject[0]['code']).to eq(200)
      expect(subject[1]['leadid']).to eq(70)
      expect(subject[1]['code']).to eq(400)
      expect(subject[1]['type']).to eq("page_hit")
    end
  end 


        
end

