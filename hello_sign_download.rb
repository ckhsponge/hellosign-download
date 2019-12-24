require 'hello_sign'

# ```bundle install`
# usage: API_KEY=my-key-here bundle exec ruby hello_sign_download.rb

# monkey patch of HelloSign gem - change of method_missing signature
module HelloSign
  module Resource
    class BaseResource
      # Magic method, gives class dynamic methods based on hash keys.
      # If initialized hash has a key which matches the method name, return value of that key.
      # Otherwise, return nil.
      #
      # @param method [Symbol] Method's name
      #
      # @example
      #   resource = BaseResource.new email_address: "me@example.com"
      #   resource.email_address => "me@example.com"
      #   resource.not_in_hash_keys => nil
      def method_missing(method, *args, &block)
        @data.key?(method.to_s) ? @data[method.to_s] : nil
      end
    end
  end
end

class HelloSignDownload
  PAGE_SIZE = 100

  def self.go
    self.new.download_requests
  end

  def client
    raise "Missing API_KEY environment variable" unless ENV['API_KEY'] && ENV['API_KEY'] != ""
    @client ||= HelloSign::Client.new :api_key => ENV['API_KEY']
    @client
  end

  # 2. Obtain the total number of pages of Signature Requests returned from the List Signature Requests endpoint

  # def total_pages
  #   list = client.get_signature_requests(page_size: 100)
  #   puts list.inspect
  #   list.data["list_info"]["num_pages"]
  # end

  # 3. Loop through the pages of the signature requests to combine into one list

  def all_requests
    signature_requests = []
    page = 1
    # count = total_pages

    while true #page < count + 1
      puts "Loading page #{page} of signature requests"
      response = client.get_signature_requests(page_size: PAGE_SIZE, page: page)
      results = response
      signature_requests += results if results
      break if !results || results.count < PAGE_SIZE
      page += 1
    end

    signature_requests
  end

  # 4. Loop through all signature requests and downloads the completed documents

  def download_requests
    requests = all_requests
    puts "Found #{requests.count} signature requests"
    requests.each do |req|
      id = req.signature_request_id || req.transmission_id
      files_url = req.files_url
      # next unless files_url =~ /transmission/
      if !files_url || files_url == ""
        puts "SKIPPING - blank files_url - #{files_url}"
        next
      end
      puts "Downloading #{id}"
      # the below line does not work for transmissions
      # download = client.signature_request_files( signature_request_id: id, file_type: "zip" )
      download, type = download_files(files_url)

      File.open("Download-#{id}.#{type}", "wb") do |file|
        file.write(download)
      end
    end
  end

  # downloads requests or transmissions
  # transmissions are downloaded as PDF
  # requests are downloaded as zip fies
  def download_files(files_url)
    path = files_url.gsub(/^https:\/\/api\.hellosign\.com\/v\d+/,'')
    if path =~ /^\/transmission/
      type = "pdf"
    else
      type = "zip"
      path = "#{path}?file_type=#{type}"
    end
    puts "Path #{path}"
    response = client.get(path)
    # puts "Response #{response.class}"
    # puts "Response #{response[0,100]}"
    return response, type
  end
end

HelloSignDownload.go
