Download all your contracts from HelloSign!

**because you can't do that on their site**

This script depends requires Ruby and uses the bundler gem.

###### Usage:
```bash
gem install bundler
bundle install
export API_KEY=YOUR_KEY
bundle exec ruby hello_sign_download.rb
```

Replace YOUR_KEY with your key.

This is based on 
[their docs](https://faq.hellosign.com/hc/en-us/articles/360013597231-How-to-download-all-documents)
with their gem.

Somehow version 3.2 of the hellosign-ruby-sdk gem was used which is old.
There's probably a better way with a more recent version.

Signature requests are downloaded as zip files that include audit history.
Transmissions are downloaded as pdf.

The zips can then be unzipped and all of it can be uploaded to Google Drive or Box to allow searching. 
