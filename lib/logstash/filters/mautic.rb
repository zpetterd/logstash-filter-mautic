# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/json"
require "logstash/timestamp"
# This example filter will replace the contents of the default 
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.
class LogStash::Filters::Mautic < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "mautic"
  
  # Replace the message with this value.
  config :source, :validate => :string, :required => true
  config :tag_on_failure, :validate => :array, :default => ["_mauticparsefailure"]
  

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)

    begin
      json_data = LogStash::Json.load(event[@source])
    rescue => e
       tag = "_jsonparsefailure"
       event["tags"] ||= []
       event["tags"] << tag unless event["tags"].include?(tag)
       @logger.warn("Trouble parsing json", :source => @source,
                    :raw => event[@source], :exception => e)
       @logger.warn("Trouble parsing json", :exception => e)
       return
    end
    tag = "_mauticparsefailure"
    if json_data
      # Replace the event message with our message as configured in the
      # config file.
      if json_data.is_a?(Hash)
        matches = json_data.select{|k,v| k =~ /mautic.lead_post_save_update|mautic.lead_post_save_new|mautic.lead_points_change/}
      end
      if matches 
        matches.each do |k,v|
          if v.is_a?(Hash)                    ##############Go here if it is a JSON object
            
            parsed_data = processNewUpdateLead(v,k)

            event_cloned = event.clone
            event_cloned.timestamp = parsed_data['dateAdded']

            parsed_data.each do |k1,v1|       ## Pull in the data
              event_cloned[k1] = v1
            end

            filter_matched(event_cloned)
            yield event_cloned
          else
            v.each do |k2,v2|             ######################## Go here if it is JSON array
           
              parsed_data = processNewUpdateLead(k2,k)

              event_cloned = event.clone
              event_cloned.timestamp = parsed_data['dateAdded']


              parsed_data.each do |k1,v1|       ## Pull in the data
                event_cloned[k1] = v1
              end

              filter_matched(event_cloned)
              yield event_cloned
            end # end loop
          end
        end
      end  # end if

      if json_data['mautic.email_on_open']
        if json_data['mautic.email_on_open'].is_a?(Hash)
          parsed_data = processEmail(json_data['mautic.email_on_open'])
          
          event_cloned = event.clone
          event_cloned.timestamp = parsed_data['dateSent']
          
          parsed_data.each do |k1,v1|       ## Pull in the data
            event_cloned[k1] = v1
          end
          
          filter_matched(event_cloned)
          yield event_cloned
        
        else
          json_data['mautic.email_on_open'].each do |value|
            parsed_data = processEmail(value)

            event_cloned = event.clone
            event_cloned.timestamp = parsed_data['dateSent']
            
            parsed_data.each do |k1,v1|       ## Pull in the data
              event_cloned[k1] = v1
            end
            
            filter_matched(event_cloned)
            yield event_cloned
          
          end # end loop
        end
      end  # end if

      if json_data['mautic.form_on_submit']

        if json_data['mautic.form_on_submit'].is_a?(Array)
          json_data['mautic.form_on_submit'].each do |value|
            parsed_data = processForm(value)

            event_cloned = event.clone
            event_cloned.timestamp = parsed_data['dateSubmitted']

            parsed_data.each do |k1,v1|       ## Pull in the data
              event_cloned[k1] = v1
            end

            filter_matched(event_cloned)
            yield event_cloned
          end # end loop
        else
          parsed_data = processForm(json_data['mautic.form_on_submit'])

          event_cloned = event.clone
          event_cloned.timestamp = parsed_data['dateSubmitted']

          
          parsed_data.each do |k1,v1|       ## Pull in the data
            event_cloned[k1] = v1
          end

          filter_matched(event_cloned)
          yield event_cloned
        end  # end if
      end  # end if

      if json_data['mautic.page_on_hit']
        if json_data['mautic.page_on_hit'].is_a?(Array)
          json_data['mautic.page_on_hit'].each do |value|
            parsed_data = processHit(value)

            event_cloned = event.clone
            event_cloned.timestamp = parsed_data['dateHit']

            parsed_data.each do |k1,v1|       ## Pull in the data
              event_cloned[k1] = v1
            end

            filter_matched(event_cloned)
            yield event_cloned
          end # end loop
        else
          parsed_data = processHit(json_data['mautic.page_on_hit'])

          event_cloned = event.clone
          event_cloned.timestamp = parsed_data['dateHit']
          
          parsed_data.each do |k1,v1|       ## Pull in the data
            event_cloned[k1] = v1
          end
          filter_matched(event_cloned)
          yield event_cloned
        end  # end if
      end

    end # end if

    # filter_matched should go in the last line of our successful code
    event.cancel   #As we have cloned the event we need to cancel the original one
  end # def filter

  def processHit(json_data)
    parsed_data = json_data['hit']
    parsed_data['leadid'] = parsed_data['lead']['id'].to_i
    parsed_data.delete('lead')


    parsed_data['parent'] = parsed_data['leadid']
    parsed_data['type'] = "page_hit"

    if parsed_data['dateHit']
      parsed_data['dateHit'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateHit'])
    end

    if parsed_data['dateLeft']
      parsed_data['dateLeft'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateLeft'])
    end
    return parsed_data
  end

  def processForm(json_data)
    parsed_data = json_data['submission']
    parsed_data['leadid'] = parsed_data['lead']['id'].to_i
    parsed_data['submissionid'] = parsed_data['id']


    parsed_data.delete('id')
    parsed_data.delete('lead')
    parsed_data.delete('ipAddress')

    if parsed_data['dateSubmitted']
      parsed_data['dateSubmitted'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateSubmitted'])
    end

    parsed_data['type'] = "form_submission"
    parsed_data['parent'] = parsed_data['leadid']


    
    # num =0
    # parsed_data["ipAddresses"] = []
    # parsed_data['ipAddresses'].each do |k2,v2|
    #   formData['ipAddresses'][num] = k2
    #   num +=1
    # end  
    return parsed_data
  end

  def processNewUpdateLead(json_data,key)
    parsed_data = newLeadFilter(json_data)
    parsed_data['leadid'] = parsed_data['id'].to_i
    parsed_data['emailAddress'] = parsed_data['email']

    parsed_data.delete('id')
    parsed_data.delete('email')

    if parsed_data['dateIdentified'] != nil
      parsed_data['dateIdentified'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateIdentified'])
    end

    if parsed_data['dateAdded'] != nil
      parsed_data['dateAdded'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateAdded'])
    end

    if parsed_data['dateModified'] != nil
      parsed_data['dateModified'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateModified'])
    end

      parsed_data['type'] = "lead"
    return parsed_data
  end

  def processEmail(json_data)
    parsed_data = json_data['stat']
    parsed_data['leadid'] = parsed_data['lead']['id'].to_i
    parsed_data['emailopenid'] = parsed_data['id']

    parsed_data.delete("lead")
    parsed_data.delete("id")

    parsed_data['type'] = "email"
    parsed_data['parent'] = parsed_data['leadid']


    if parsed_data['dateSent'] != nil
      parsed_data['dateSent'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateSent'])
    end    

    if parsed_data['dateRead'] != nil
      parsed_data['dateRead'] = LogStash::Timestamp.parse_iso8601(parsed_data['dateRead'])
    end
    if parsed_data['lastOpened'] != nil
      parsed_data['lastOpened'] = LogStash::Timestamp.parse_iso8601(parsed_data['lastOpened'])
    end
    
    return parsed_data
  end

  def newLeadFilter(json_data)

    formData = {}
    json_data["lead"].each do |k1,v1|
      if k1 === "ipAddresses"
        num = 0
        formData["ipAddresses"] = []
        v1.each do |k2,v2|
          formData[k1][num] = k2
          num +=1
        end  
      elsif k1 === "tags"
        num =0
        formData["mautic_tags"] = []
        v1.each do |v2|
          formData["mautic_tags"][num] =v2
          num +=1
        end
      elsif v1.is_a?(Hash)
        v1.each do |k2,v2|
          if v2.is_a?(Hash)
            v2.each do |k3,v3|
              if v3.is_a?(Hash)
                v3.each do |k4,v4| 
                  if v4 != nil and k4 === 'value'
                    formData[k3] = v4
                  end
                end
              elsif v3 != nil
                formData[k3] = v3
              end
            end
          elsif v2 != nil and !(k2 === 'fields') and !(k1 === 'owner')
            formData[k2] = v2
          end
        end
      elsif v1 != nil
        formData[k1] = v1
      end
    end
    return formData
  
  end
end # class LogStash::Filters::Mautic
