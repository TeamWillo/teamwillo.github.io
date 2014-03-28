require "rubygems"
require "bundler/setup"
require "stringex"

## -- Config -- ##

posts_dir       = "_posts"    # directory for blog files
new_post_ext    = "md"  # default new post file extension when using the new_post task
new_page_ext    = "md"  # default new page file extension when using the new_page task
feature 	= ""#initialize feature


#############################
# Create a new Post or Page #
#############################

# usage rake new_post
desc "Create a new post in #{posts_dir}"
task :new_post, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your post: ")
  end
  filename = "#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  puts filename
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  category = get_stdin("Enter category name to group your post in (leave blank for none): ")
  tags = get_stdin("Enter tags to classify your post (comma separated): ")
  feat = get_stdin("Enter filename you want to use as feature (in <images> folder - 2048px x 512px. Leave blank for none): ")
  feature = "#{Time.now.strftime('%Y/%m')}/#{feat}"
  if File.exist?(feature)
	credit = get_stdin("Enter photo credit:")
	creditlink = get_stdin("Enter credit link(Leave blank if none):")
  else
	feature = ""
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "modified: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    post.puts "category: #{category}"
    post.puts "tags: [#{tags}]"
    post.puts "image:"
    post.puts "  feature: #{feature} "
    post.puts "  credit: #{credit}"
    post.puts "  creditlink: #{creditlink}"
    post.puts "comments: "
    post.puts "share: "
    post.puts "---"
  end
end

# usage rake new_page
desc "Create a new page"
task :new_page, :title do |t, args|
  if args.title
    title = args.title
  else
    title = get_stdin("Enter a title for your page: ")
  end
  filename = "#{title.to_url}.#{new_page_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  tags = get_stdin("Enter tags to classify your page (comma separated): ")
  feat = get_stdin("Enter filename you want to use as feature (in <images> folder - 2048px x 512px. Leave blank for none): ")
  feature = "#{Time.now.strftime('%Y/%m')}/#{feat}"
  puts feature
  if File.exist?(feature)
	puts "file does exist"
	credit = get_stdin("Enter photo credit:")
	creditlink = get_stdin("Enter credit link(Leave blank if none):")
  else 
	puts "file does not exist."
  	feature = ""
  end
  puts "Creating new page: #{filename}"
  open(filename, 'w') do |page|
    page.puts "---"
    page.puts "layout: page"
    page.puts "permalink: /#{title.to_url}/"
    page.puts "title: \"#{title}\""
    page.puts "modified: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    page.puts "tags: [#{tags}]"
    page.puts "image:"
    page.puts "  feature: #{feature} "
    page.puts "  credit: #{credit} "
    page.puts "  creditlink: #{creditlink}"
    page.puts "share: "
    page.puts "---"
  end
end
##############################
# SENDING THE SITE TO GITHUB #
##############################

# usage rake commit
desc "Commit _site/"
task :commit do
  puts "\n## Staging modified files"
  status = system("git add -A .")
  puts status ? "Success" : "Failed"
  puts "\n## Committing a site build at #{Time.now.utc}"
  message = "Build site at #{Time.now.utc}"
  status = system("git commit -m \"#{message}\"")
  puts status ? "Success" : "Failed"
  puts "\n## Pushing commits to teamwillo.github.io"
  status = system("git push origin master")
  puts status ? "Success" : "Failed"
end


def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end
