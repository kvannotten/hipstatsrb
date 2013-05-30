#!/usr/bin/env ruby

require 'gruff'
require 'json'

dates = ["2013-05-20", "2013-05-21", "2013-05-22", "2013-05-23", "2013-05-25", "2013-05-26", "2013-05-27", "2013-05-28"]

dataset = Hash.new(0)

dates.each do |date|
  data = JSON.parse IO.read("#{date}.json")
  
  data.each do |datum|
    name = datum["from"]["name"]
    next if name.downcase == "jenkins" or name.downcase == "git" or name.downcase == "linguistgui" or name.downcase == "jira"
    
    unless dataset.include? name then
      dataset[name] = Hash.new
      dates.each do |d|
        dataset[name][d] = 0
      end
    end
    
    dataset[name][date] += 1
  end
end

g = Gruff::StackedArea.new
g.title = "Development Chatting activity per user"
g.labels = {
  0 => '20/05',
  1 => '21/05', 
  2 => '22/05', 
  3 => '23/05', 
  4 => '25/05', 
  5 => '26/05', 
  6 => '27/05', 
  7 => '28/05', 
}
dataset.each do |key, value|
  g.data(key, value.values)
end
g.write "stacked_area_keynote.png"