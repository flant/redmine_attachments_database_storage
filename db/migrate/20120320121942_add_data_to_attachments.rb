class AddDataToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :data, :binary, :limit => 64.megabyte
    
    puts "Starting to move files from disk to database"
    Attachment.all.each do |attachment|
      print "processing #{attachment.diskfile}..."
      if File.exists? attachment.diskfile
        attachment.data = File.new(attachment.diskfile, "rb").read
        if attachment.save
          puts "success!"
        else
          puts "failed!"
        end        
      else 
        puts "failed! FILE DOESNOT EXIST!" 
      end
    end
  end

  def self.down
    remove_column :attachments, :data
  end
end
