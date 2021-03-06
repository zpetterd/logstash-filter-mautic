# Logstash Plugin

[![Build
Status](http://build-eu-00.elastic.co/view/LS%20Plugins/view/LS%20Filters/job/logstash-plugin-filter-example-unit/badge/icon)](http://build-eu-00.elastic.co/view/LS%20Plugins/view/LS%20Filters/job/logstash-plugin-filter-example-unit/)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.


1. Install this plugin using 
```
./plugin install logstash-filter-mautic
```


2. Setup your Logstash configuration like so

```
input {
	http {
		host => "127.0.0.1"
		port => "5543"
		type => "mautic-lead"
	}

}
filter {

if [type] == "mautic-lead" {
		mautic {
			source => "message"
			remove_field => ["headers", "message", "host"]
		}
		if [type] == "lead"{
			mutate {
				replace => { "@timestamp" => "%{dateAdded}"}
			}
		}
		if [type] == "form_submission"{
			mutate {
				replace => { "@timestamp" => "%{dateSubmmited}"}
			}
		}
		if [type] == "email"{
			mutate {
				replace => { "@timestamp" => "%{dateSent}"}
			}
		}
		if [type] == "page_hit"{
			mutate {
				replace => { "@timestamp" => "%{dateHit}"}
			}
		}
		
	}

}
output {
	if [type] == "lead" {
		elasticsearch { 
			hosts => ["localhost:9200"] 
			index => ["mautic-leads"]
			#document_id => "%{[leadid]}"
		}
	}
	else if [type] == "form_submission" {
		elasticsearch { 
			hosts => ["localhost:9200"] 
			index => ["mautic-leads"]
			document_id => "F%{[leadid]}-%{[form][id]}-%{[submissionid]}"
			routing => "%{[leadid]}"
		}
	}
	else if [type] == "page_hit" {
		elasticsearch { 
			hosts => ["localhost:9200"] 
			index => ["mautic-leads"]
			routing => "%{[leadid]}"
		}
	}
	else if [type] == "email" {
		elasticsearch { 
			hosts => ["localhost:9200"] 
			index => ["mautic-leads"]
			document_id => "E%{[leadid]}-%{[email][id]}-%{[emailopenid]}"
			routing => "%{[leadid]}"
		}
	}
	}

```