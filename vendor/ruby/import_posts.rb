# frozen_string_literal: true

require 'csv'
require 'byebug'
require 'base64'

CSV_PATH = File.join(__dir__, 'export_posts.csv').freeze
POSTS_PATH = File.join(__dir__, '../../_posts').freeze

def build_post(title, publish_date, categories, content)
  post = String.new("---\n")
  post << "layout: post\n"
  post << "title: '#{title}'\n"
  post << "date: #{publish_date}\n"
  post << "categories: #{categories}\n"
  post << "---\n"
  post << content

  # escapes {{ }} tags
  post.gsub!(/{{(.*)}}/) do
    "{% raw %}{{#{$1}}} {% endraw %}"
  end

  # prepend /assets to images and removes the site url
  post.gsub!(/\[file\].*(\/img\/image-)/) do
    "[file](/assets#{$1}"
  end

  post
end

CSV.foreach(CSV_PATH, headers: true) do |row|
  title = row['title']
  slug = row['slug']
  content = Base64.decode64(row['content'])
  publish_date = row['publish_date']
  categories = row['categories']
  categories = "[" + "'" + categories.split(',').join("',") + "'" + "]"

  file_name = publish_date.split.first + '-' + slug + '.markdown'
  file_path = File.join(POSTS_PATH, file_name)

  content = build_post(title, publish_date, categories, content)

  File.open(file_path, 'w') { |f| f.write(content) }
end

